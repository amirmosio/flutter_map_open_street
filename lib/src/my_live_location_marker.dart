// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_map_open_street/src/LocationUtils.dart';
// import 'package:latlong2/latlong.dart';
//
// class LiveLocationMarker extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<LocationReceived>(
//         stream: LocationUtils.getInstance()
//             .locationStream
//             .where((event) => event is LocationReceived)
//             .cast<LocationReceived>(),
//         builder: (context, snapshot) {
//           if (snapshot.hasData)
//             return MarkerLayer(
//               key: ValueKey(snapshot),
//               markers: [
//                 Marker(
//                   point: LatLng(snapshot.data!.locationData.latitude!,
//                       snapshot.data!.locationData.longitude!),
//                   builder: (context) {
//                     return Icon(
//                       Icons.my_location_rounded,
//                       color: Theme.of(context).primaryColor,
//                     );
//                   },
//                 )
//               ],
//             );
//           else
//             return SizedBox();
//         });
//   }
// }
