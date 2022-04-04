import 'dart:async';

import 'package:rxdart/rxdart.dart';

enum MapState { Idle, DrawingPolygon, SelectingALocation, DeletingPolygon }

class MapStateBloc {
  MapState _mapState = MapState.Idle;

  MapStateWrapper get currentMapState => MapStateWrapper(_mapState);

  bool get isIdle => _mapState == MapState.Idle;

  bool get isDrawingPolygon => _mapState == MapState.DrawingPolygon;

  bool get isSelectingLocation => _mapState == MapState.SelectingALocation;

  bool get isDeletingPolygon => _mapState == MapState.DeletingPolygon;

  PublishSubject<MapStateWrapper> _mapStateSubject =
      PublishSubject<MapStateWrapper>();

  StreamSink<MapStateWrapper> get _mapStateSink => _mapStateSubject.sink;

  Stream<MapStateWrapper> get mapStateStream => _mapStateSubject.stream;

  MapStateBloc({MapState? mapState}) {
    _mapState = mapState ?? MapState.Idle;
  }

  toggleMapState(MapState mapState) {
    if (_mapState == mapState) {
      _mapState = MapState.Idle;
      _mapStateSink.add(MapStateWrapper(MapState.Idle));
    } else {
      _mapState = mapState;
      _mapStateSink.add(MapStateWrapper(mapState));
    }
  }

  setMapStateIdle() {
    _mapState = MapState.Idle;
    _mapStateSink.add(MapStateWrapper(MapState.Idle));
  }

  void dispose() {
    _mapStateSubject.close();
  }
}

class MapStateWrapper {
  final MapState mapState;

  MapStateWrapper(this.mapState);
}
