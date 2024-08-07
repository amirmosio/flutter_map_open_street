import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_open_street/src/map_state_bloc.dart';
import 'package:flutter_map_open_street/src/map_utils.dart';
import 'package:latlong2/latlong.dart';

import 'map_button_overlay.dart';

class MapObjectWrapper {
  List<List<LatLng>> polygons;
  List<Marker> markers;

  MapObjectWrapper(this.polygons, this.markers);
}

class FlutterMapWidget extends StatefulWidget {
  // ignore: non_constant_identifier_names
  static List<LatLng> WHOLE_WORLD_POLYGON = [
    LatLng(-90, 180),
    LatLng(90, 180),
    LatLng(90, -180),
    LatLng(-90, -180),
  ];

  // ignore: non_constant_identifier_names
  static LatLng TEHRAN_LAT_LONG = LatLng(35.69968630125204, 51.337394714355476);

  final List<Marker> initialMarkers;
  final List<List<LatLng>> initialPolygons;
  final List<List<LatLng>> backgroundPolygons;
  final List<List<LatLng>> activeRegions;
  final void Function(MapObjectWrapper)? onMapObjectsChange;
  final void Function(List<LatLng>)? onFieldOfViewChange;
  final bool enableOperations;
  final bool enablePolygonButton;
  final bool enableLocationButton;
  final bool enableDeleteButton;
  final bool enableMyLocationButton;

  // final bool initializeLocationOnInitState;
  // final bool initialZoomOnCurrentLocation;

  FlutterMapWidget({
    this.initialMarkers = const [],
    this.onMapObjectsChange,
    this.initialPolygons = const [],
    this.backgroundPolygons = const [],
    this.activeRegions = const [],
    this.enableOperations = true,
    this.enablePolygonButton = true,
    this.enableLocationButton = true,
    this.enableDeleteButton = true,
    this.onFieldOfViewChange,
    this.enableMyLocationButton = true,
    // this.initializeLocationOnInitState = true,
    // this.initialZoomOnCurrentLocation = false,
  }) : super(key: UniqueKey()) {
    // assert(enableMyLocationButton || !initialZoomOnCurrentLocation);
    // assert(enableMyLocationButton || !initializeLocationOnInitState);
  }

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<FlutterMapWidget> {
  final MapStateBloc mapStateBloc = MapStateBloc();

  // final LocationUtils locationUtils = LocationUtils.getInstance();
  final MapController mapController = MapController();

  late FollowOnLocationUpdate _followOnLocationUpdate;
  late StreamController<double?> _followCurrentLocationStreamController;

  final double maxZoom = 18.4;
  final double minZoom = 3;

  /// draw polygon variables
  List<LatLng> _drawingMarkersPosList = [];

  List<LatLng> get _copyDrawingMakersPosList {
    return _drawingMarkersPosList.map((e) => e).toList();
  }

  List<Marker> get _drawingPolygonMarkers {
    return _drawingMarkersPosList
        .map((e) => createDrawingMarker(e,
            onTap: _drawingMarkersPosList.length >= 3 && e == _drawingMarkersPosList.first
                ? () {
                    _drawingMarkersPosList.add(e);
                    _mapObjectWrapper.polygons.add(_copyDrawingMakersPosList);
                    mapStateBloc.setMapStateIdle();
                    _clearIncompleteDrawings();
                    setState(() {});
                    widget.onMapObjectsChange?.call(_mapObjectWrapper);
                  }
                : null))
        .toList();
  }

  Polyline? get _drawingPolyLine =>
      _drawingMarkersPosList.isNotEmpty ? createDrawingPolyLine(_drawingMarkersPosList) : null;

  _clearIncompleteDrawings() {
    _drawingMarkersPosList.clear();
  }

  _onPolygonDrawLine(LatLng latLng) async {
    try {
      // Add new point to list.
      _drawingMarkersPosList.add(latLng);
    } catch (e) {
      print(" error painting $e");
    }
    setState(() {});
  }

  Polygon createPolygon(List<LatLng> latLng,
      {bool withBorder = false,
      List<List<LatLng>>? holePointsList,
      Color color = const Color.fromARGB(50, 0, 150, 255)}) {
    return withBorder
        ? Polygon(
            points: latLng,
            isFilled: true,
            holePointsList: holePointsList,
            color: color,
            borderColor: Theme.of(context).primaryColorDark,
            borderStrokeWidth: 2)
        : Polygon(points: latLng, color: color, isFilled: true, holePointsList: holePointsList);
  }

  Polyline createDrawingPolyLine(List<LatLng> latLng) {
    return Polyline(
      points: latLng,
      color: Colors.blue,
      strokeWidth: 4,
      isDotted: true,
    );
  }

  Marker createDrawingMarker(LatLng latLng, {Function()? onTap}) {
    return Marker(
        point: latLng,
        builder: (context) {
          return InkWell(
            onTap: onTap,
            hoverColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.crop_square_rounded,
                color: Theme.of(context).primaryColorDark,
                size: 10,
              ),
            ),
          );
        });
  }

  /// delete polygon variables
  _deleteTappedPolygon(LatLng latLng) {
    setState(() {
      var poly = _mapObjectWrapper.polygons.removeWhere(
          (polygonPoints) => MapUtil.getInstance().isGeoPointInPolygon(latLng, polygonPoints));
      widget.onMapObjectsChange?.call(_mapObjectWrapper);
    });
  }

  /// draw marker for selected location
  _drawMarkerForSelectedLocation(LatLng latLng) {
    setState(() {
      _mapObjectWrapper.markers = [
        Marker(
            builder: (BuildContext context) {
              return Icon(
                Icons.location_on,
                color: Theme.of(context).primaryColor,
              );
            },
            point: latLng)
      ];
      widget.onMapObjectsChange?.call(_mapObjectWrapper);
    });
  }

  /// initial variables
  MapObjectWrapper _mapObjectWrapper = MapObjectWrapper([], []);

  List<Polygon> get _filterPolygons =>
      (_mapObjectWrapper.polygons + widget.backgroundPolygons)
          .map((e) => createPolygon(e, withBorder: true))
          .toList() +
      (widget.activeRegions.isEmpty
          ? []
          : [
              createPolygon(FlutterMapWidget.WHOLE_WORLD_POLYGON,
                  withBorder: false,
                  holePointsList: widget.activeRegions,
                  color: Color.fromARGB(150, 0, 0, 0))
            ]);

  @override
  void initState() {
    _mapObjectWrapper.polygons.addAll(widget.initialPolygons);
    _mapObjectWrapper.markers.addAll(widget.initialMarkers);
    mapStateBloc.mapStateStream.listen((event) {
      _clearIncompleteDrawings();
    });
    mapController.mapEventStream.listen((event) {
      if (mapController.bounds != null)
        widget.onFieldOfViewChange?.call([
          mapController.bounds!.northWest,
          mapController.bounds!.northEast!,
          mapController.bounds!.southEast,
          mapController.bounds!.southWest!,
          mapController.bounds!.northWest
        ]);
    });

    // if (widget.initialZoomOnCurrentLocation) {
    //   onMyLocationTap();
    // } else if (widget.initializeLocationOnInitState) {
    //   locationUtils.initializeLocationStream().then((_) {});
    // }
    _followOnLocationUpdate = FollowOnLocationUpdate.never;
    _followCurrentLocationStreamController = StreamController<double?>();
    super.initState();
  }

  LatLngBounds? fitInitialBounds() {
    if (_mapObjectWrapper.polygons.length +
            widget.backgroundPolygons.length +
            _mapObjectWrapper.markers.length +
            widget.activeRegions.length ==
        0) {
      return null;
    }
    List<LatLng> boundPoints = _mapObjectWrapper.markers.map((e) => e.point).toList();
    (_mapObjectWrapper.polygons + widget.backgroundPolygons + widget.activeRegions)
        .forEach((polygon) {
      polygon.forEach((point) {
        boundPoints.add(point);
      });
    });
    if (boundPoints.isNotEmpty) {
      return LatLngBounds.fromPoints(boundPoints);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        flutterMap(),
        MapButtonOverlay(
          onPlusTap: () {
            if (mapController.zoom + 1 <= maxZoom) {
              mapController.move(mapController.center, round(mapController.zoom + 1, decimals: 0));
            } else {
              mapController.move(mapController.center, maxZoom);
            }
          },
          onMinusTap: () {
            if (mapController.zoom - 1 >= minZoom) {
              mapController.move(mapController.center, round(mapController.zoom - 1, decimals: 0));
            } else {
              mapController.move(mapController.center, minZoom);
            }
          },
          onMyLocationTap: onMyLocationTap,
          mapStateBloc: mapStateBloc,
          enableOperations: widget.enableOperations,
          enablePolygonButton: widget.enablePolygonButton,
          enableLocationButton: widget.enableLocationButton,
          enableDeleteButton: widget.enableDeleteButton,
          enableMyLocationButton: widget.enableMyLocationButton,
        )
      ],
    );
  }

  onMyLocationTap() {
    // locationUtils.initializeLocationStream().then((value) {
    //   locationUtils.getLocation().then((value) {
    //     if (value != null) {
    //       mapController.move(LatLng(value.latitude!, value.longitude!), 17);
    //     }
    //   });
    // });
    // Follow the location marker on the map when location updated until user interact with the map.
    setState(
      () => _followOnLocationUpdate = FollowOnLocationUpdate.always,
    );
    // Follow the location marker on the map and zoom the map to level 18.
    _followCurrentLocationStreamController.add(18);
  }

  Widget flutterMap() {
    return FlutterMap(
      options: MapOptions(
          center: FlutterMapWidget.TEHRAN_LAT_LONG,
          bounds: fitInitialBounds(),
          onTap: (TapPosition pos, LatLng latLng) {
            if (mapStateBloc.isDrawingPolygon) {
              _onPolygonDrawLine(latLng);
            } else if (mapStateBloc.isSelectingLocation) {
              bool isInActiveRegion = widget.activeRegions.isEmpty ||
                  MapUtil.getInstance().isGeoPointInMultipolygon(latLng, widget.activeRegions);
              if (isInActiveRegion) _drawMarkerForSelectedLocation(latLng);
            } else if (mapStateBloc.isDeletingPolygon) {
              _deleteTappedPolygon(latLng);
            }
          },
          // allowPanningOnScrollingParent: false,
          enableScrollWheel: false,
          // allowPanning: true,
          zoom: 12,
          onPositionChanged: (MapPosition position, bool hasGesture) {
            if (hasGesture) {
              setState(
                () => _followOnLocationUpdate = FollowOnLocationUpdate.never,
              );
            }
          },
          onMapReady: () {
            if (mapController.bounds != null)
              widget.onFieldOfViewChange?.call([
                mapController.bounds!.northWest,
                mapController.bounds!.northEast,
                mapController.bounds!.southEast,
                mapController.bounds!.southWest,
                mapController.bounds!.northWest
              ]);
          },
          maxZoom: maxZoom,
          minZoom: minZoom),
      mapController: mapController,
      children: [
        TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
        PolygonLayer(polygons: _filterPolygons, polygonCulling: true),
        _drawingPolyLine == null
            ? SizedBox()
            : PolylineLayer(polylines: [_drawingPolyLine!], polylineCulling: true),
        // LiveLocationMarker(),
        widget.enableMyLocationButton
            ? CurrentLocationLayer(
                followCurrentLocationStream: _followCurrentLocationStreamController.stream,
                followOnLocationUpdate: _followOnLocationUpdate,
                turnOnHeadingUpdate: TurnOnHeadingUpdate.never,
                style: LocationMarkerStyle(
                  marker: const DefaultLocationMarker(
                    child: Icon(
                      Icons.navigation,
                      color: Colors.white,
                    ),
                  ),
                  markerSize: const Size(40, 40),
                  markerDirection: MarkerDirection.heading,
                ),
              )
            : SizedBox(),
        MarkerLayer(
          markers: _mapObjectWrapper.markers + _drawingPolygonMarkers,
        )
      ],
    );
  }
}
