import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_open_street/src/map_state_bloc.dart';

import 'colors.dart';
import 'farsan_icons.dart';

class MapButtonOverlay extends StatefulWidget {
  final Function() onPlusTap;
  final Function() onMinusTap;
  final Function()? onPolygonTap;
  final Function()? onLocationTap;
  final Function()? onDeleteTap;
  final Function()? onMyLocationTap;
  final bool enableOperations;
  final bool enablePolygonButton;
  final bool enableLocationButton;
  final bool enableDeleteButton;
  final bool enableMyLocationButton;
  final MapStateBloc mapStateBloc;

  const MapButtonOverlay({
    Key? key,
    required this.onPlusTap,
    required this.onMinusTap,
    required this.mapStateBloc,
    this.onPolygonTap,
    this.onLocationTap,
    this.onDeleteTap,
    this.onMyLocationTap,
    this.enableOperations = true,
    this.enableDeleteButton = true,
    this.enableLocationButton = true,
    this.enablePolygonButton = true,
    this.enableMyLocationButton = true,
  }) : super(key: key);

  @override
  _MapButtonOverlayState createState() => _MapButtonOverlayState();
}

class _MapButtonOverlayState extends State<MapButtonOverlay> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        mapButtons(
            child: Text(
              "+",
              style: TextStyle(fontSize: 22, color: FColor.blueGray),
            ),
            onTap: () {
              this.widget.onPlusTap();
            }),
        mapButtons(
            child: Text(
              "-",
              style: TextStyle(fontSize: 22, color: FColor.blueGray),
            ),
            onTap: this.widget.onMinusTap),
        (widget.enableMyLocationButton
            ? mapButtons(
                child: Icon(
                  Icons.my_location_outlined,
                  color: FColor.blueGray,
                ),
                onTap: () {
                  widget.onMyLocationTap?.call();
                },
                active: false)
            : SizedBox()),
        widget.enableOperations
            ? StreamBuilder<MapStateWrapper>(
                initialData: widget.mapStateBloc.currentMapState,
                stream: widget.mapStateBloc.mapStateStream,
                builder: (BuildContext context, AsyncSnapshot<MapStateWrapper> snapshot) {
                  return Column(
                      children: (widget.enablePolygonButton
                              ? [
                                  mapButtons(
                                      child: Icon(
                                        FIcons.polygon,
                                        color: FColor.blueGray,
                                      ),
                                      onTap: () {
                                        widget.mapStateBloc.toggleMapState(MapState.DrawingPolygon);
                                        widget.onPolygonTap?.call();
                                      },
                                      active: snapshot.data?.mapState == MapState.DrawingPolygon)
                                ]
                              : <Widget>[]) +
                          (widget.enableLocationButton
                              ? [
                                  mapButtons(
                                      child: Icon(
                                        Icons.location_on,
                                        color: FColor.blueGray,
                                      ),
                                      onTap: () {
                                        widget.mapStateBloc
                                            .toggleMapState(MapState.SelectingALocation);
                                        widget.onLocationTap?.call();
                                      },
                                      active:
                                          snapshot.data?.mapState == MapState.SelectingALocation)
                                ]
                              : <Widget>[]) +
                          (widget.enableDeleteButton
                              ? [
                                  mapButtons(
                                      child: Icon(
                                        Icons.delete_outline,
                                        color: FColor.blueGray,
                                      ),
                                      onTap: () {
                                        widget.mapStateBloc
                                            .toggleMapState(MapState.DeletingPolygon);
                                        widget.onDeleteTap?.call();
                                      },
                                      active: snapshot.data?.mapState == MapState.DeletingPolygon),
                                ]
                              : <Widget>[]));
                },
              )
            : SizedBox(),
      ],
    );
  }

  Widget mapButtons({required Widget child, required Function()? onTap, bool active = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: SizedBox(
        width: 30,
        height: 30,
        child: Material(
          borderRadius: BorderRadius.circular(8.0),
          color: active ? FColor.filterChipSelectedColor : FColor.secondaryColor,
          child: InkWell(
            borderRadius: BorderRadius.circular(8.0),
            onTap: onTap,
            mouseCursor: SystemMouseCursors.click,
            hoverColor: FColor.gray1,
            splashFactory: InkSplash.splashFactory,
            child: Container(
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
