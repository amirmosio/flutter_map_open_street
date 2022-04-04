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
  final bool enableOperations;
  final bool enablePolygonButton;
  final bool enableLocationButton;
  final bool enableDeleteButton;
  final MapStateBloc mapStateBloc;

  const MapButtonOverlay({
    Key? key,
    required this.onPlusTap,
    required this.onMinusTap,
    required this.mapStateBloc,
    this.onPolygonTap,
    this.onLocationTap,
    this.onDeleteTap,
    this.enableOperations = true,
    this.enableDeleteButton = true,
    this.enableLocationButton = true,
    this.enablePolygonButton = true,
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
              style: TextStyle(fontSize: 22, color: ColorRes.blueGray),
            ),
            onTap: () {
              this.widget.onPlusTap();
            }),
        mapButtons(
            child: Text(
              "-",
              style: TextStyle(fontSize: 22, color: ColorRes.blueGray),
            ),
            onTap: this.widget.onMinusTap),
        widget.enableOperations
            ? StreamBuilder<MapStateWrapper>(
                initialData: widget.mapStateBloc.currentMapState,
                stream: widget.mapStateBloc.mapStateStream,
                builder: (BuildContext context,
                    AsyncSnapshot<MapStateWrapper> snapshot) {
                  return Column(
                      children: (widget.enablePolygonButton
                              ? [
                                  mapButtons(
                                      child: Icon(
                                        FIcons.polygon,
                                        color: ColorRes.blueGray,
                                      ),
                                      onTap: () {
                                        widget.mapStateBloc.toggleMapState(
                                            MapState.DrawingPolygon);
                                        widget.onPolygonTap?.call();
                                      },
                                      active: snapshot.data?.mapState ==
                                          MapState.DrawingPolygon)
                                ]
                              : <Widget>[]) +
                          (widget.enableLocationButton
                              ? [
                                  mapButtons(
                                      child: Icon(
                                        Icons.location_on,
                                        color: ColorRes.blueGray,
                                      ),
                                      onTap: () {
                                        widget.mapStateBloc.toggleMapState(
                                            MapState.SelectingALocation);
                                        widget.onLocationTap?.call();
                                      },
                                      active: snapshot.data?.mapState ==
                                          MapState.SelectingALocation)
                                ]
                              : <Widget>[]) +
                          (widget.enableDeleteButton
                              ? [
                                  mapButtons(
                                      child: Icon(
                                        Icons.delete_outline,
                                        color: ColorRes.blueGray,
                                      ),
                                      onTap: () {
                                        widget.mapStateBloc.toggleMapState(
                                            MapState.DeletingPolygon);
                                        widget.onDeleteTap?.call();
                                      },
                                      active: snapshot.data?.mapState ==
                                          MapState.DeletingPolygon),
                                ]
                              : <Widget>[]));
                },
              )
            : SizedBox(),
      ],
    );
  }

  Widget mapButtons(
      {required Widget child,
      required Function()? onTap,
      bool active = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: SizedBox(
        width: 30,
        height: 30,
        child: Material(
          borderRadius: BorderRadius.circular(8.0),
          color: active
              ? ColorRes.filterChipSelectedColor
              : ColorRes.secondaryColor,
          child: InkWell(
            borderRadius: BorderRadius.circular(8.0),
            onTap: onTap,
            mouseCursor: SystemMouseCursors.click,
            hoverColor: ColorRes.gray1,
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
