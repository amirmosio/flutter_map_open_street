import 'package:latlong2/latlong.dart';

class MapUtil {
  static MapUtil? _utility;

  static MapUtil getInstance() {
    if (_utility == null) {
      _utility = MapUtil();
    }
    return _utility!;
  }

  bool isGeoPointInPolygon(LatLng l, List<LatLng> polygon) {
    var isInPolygon = false;

    for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      if ((((polygon[i].latitude <= l.latitude) && (l.latitude < polygon[j].latitude)) ||
              ((polygon[j].latitude <= l.latitude) && (l.latitude < polygon[i].latitude))) &&
          (l.longitude <
              (polygon[j].longitude - polygon[i].longitude) *
                      (l.latitude - polygon[i].latitude) /
                      (polygon[j].latitude - polygon[i].latitude) +
                  polygon[i].longitude)) isInPolygon = !isInPolygon;
    }
    return isInPolygon;
  }

  bool isGeoPointInMultipolygon(LatLng l, List<List<LatLng>> multipolygon) {
    return multipolygon.any((element) => isGeoPointInPolygon(l, element));
  }
}
