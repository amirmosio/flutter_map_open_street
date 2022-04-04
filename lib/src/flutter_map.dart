import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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
  final List<Marker> initialMarkers;
  final List<List<LatLng>> initialPolygons;
  final List<List<LatLng>> backgroundPolygons;
  final void Function(MapObjectWrapper)? onMapObjectsChange;
  final bool enableOperations;
  final bool enablePolygonButton;
  final bool enableLocationButton;
  final bool enableDeleteButton;

  FlutterMapWidget(
      {this.initialMarkers = const [],
      this.onMapObjectsChange,
      this.initialPolygons = const [],
      this.backgroundPolygons = const [],
      this.enableOperations = true,
      this.enablePolygonButton = true,
      this.enableLocationButton = true,
      this.enableDeleteButton = true})
      : super(key: UniqueKey());

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<FlutterMapWidget> {
  final MapStateBloc mapStateBloc = MapStateBloc();
  LatLng tehranLatLng = LatLng(35.69968630125204, 51.337394714355476);
  MapController mapController = MapController();
  final double maxZoom = 15;
  final double minZoom = 3;

  /// draw polygon variables
  List<LatLng> _drawingMarkersPosList = [];

  List<LatLng> get _copyDrawingMakersPosList {
    return _drawingMarkersPosList.map((e) => e).toList();
  }

  List<Marker> get _drawingPolygonMarkers {
    return _drawingMarkersPosList
        .map((e) => createDrawingMarker(e,
            onTap: _drawingMarkersPosList.length >= 3 &&
                    e == _drawingMarkersPosList.first
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

  Polyline get _drawingPolyLine =>
      createDrawingPolyLine(_drawingMarkersPosList);

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

  Polygon createPolygon(List<LatLng> latLng, {bool withBorder = false}) {
    return withBorder
        ? Polygon(
            points: latLng,
            color: Color.fromARGB(50, 0, 150, 255),
            borderColor: Theme.of(context).primaryColorDark,
            borderStrokeWidth: 2)
        : Polygon(points: latLng, color: Color.fromARGB(50, 0, 150, 255));
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
      var poly = _mapObjectWrapper.polygons.removeWhere((polygonPoints) =>
          MapUtil.getInstance().isGeoPointInPolygon(latLng, polygonPoints));
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
          .toList();

  @override
  void initState() {
    _mapObjectWrapper.polygons.addAll(widget.initialPolygons);
    _mapObjectWrapper.markers.addAll(widget.initialMarkers);
    mapStateBloc.mapStateStream.listen((event) {
      _clearIncompleteDrawings();
    });
    super.initState();
  }

  LatLngBounds fitInitialBounds() {
    LatLngBounds bound = LatLngBounds();
    _mapObjectWrapper.markers.forEach((marker) {
      bound.extend(marker.point);
    });
    (_mapObjectWrapper.polygons + widget.backgroundPolygons).forEach((polygon) {
      polygon.forEach((point) {
        bound.extend(point);
      });
    });
    if (_mapObjectWrapper.polygons.length +
            widget.backgroundPolygons.length +
            _mapObjectWrapper.markers.length ==
        0) {
      bound.extend(tehranLatLng);
    }

    return bound;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        flutterMap(),
        MapButtonOverlay(
          onPlusTap: () {
            if (mapController.zoom + 1 <= maxZoom)
              mapController.move(mapController.center, mapController.zoom + 1);
          },
          onMinusTap: () {
            if (mapController.zoom - 1 >= minZoom)
              mapController.move(mapController.center, mapController.zoom - 1);
          },
          mapStateBloc: mapStateBloc,
          enableOperations: widget.enableOperations,
          enablePolygonButton: widget.enablePolygonButton,
          enableLocationButton: widget.enableLocationButton,
          enableDeleteButton: widget.enableDeleteButton,
        )
      ],
    );
  }

  Widget flutterMap() {
    return FlutterMap(
      options: MapOptions(
          center: tehranLatLng,
          bounds: fitInitialBounds(),
          onTap: (LatLng latLng) {
            if (mapStateBloc.isDrawingPolygon) {
              _onPolygonDrawLine(latLng);
            } else if (mapStateBloc.isSelectingLocation) {
              _drawMarkerForSelectedLocation(latLng);
            } else if (mapStateBloc.isDeletingPolygon) {
              _deleteTappedPolygon(latLng);
            }
          },
          allowPanning: true,
          controller: mapController,
          zoom: 13,
          maxZoom: maxZoom,
          minZoom: minZoom),
      mapController: mapController,
      layers: [
        TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
        PolygonLayerOptions(polygons: _filterPolygons, polygonCulling: true),
        PolylineLayerOptions(
            polylines: [_drawingPolyLine], polylineCulling: true),
        MarkerLayerOptions(
          markers: _mapObjectWrapper.markers + _drawingPolygonMarkers,
        ),
      ],
    );
  }
}
