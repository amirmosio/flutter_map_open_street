import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map_open_street/flutter_map_open_street.dart';
import 'package:latlong2/latlong.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(Application());
}

class Application extends StatefulWidget {
  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  @override
  void initState() {
    // LocationUtils.getInstance().locationStream.listen((event) {
    //   print("listening to events");
    //   if (event is SearchingForLocation) {
    //     print("SearchingForLocation");
    //   } else if (event is LocationReceived) {
    //     print("LocationReceived");
    //   } else if (event is PermissionDeniedStatus) {
    //     print("PermissionDeniedStatus");
    //   } else if (event is ServiceUnavailableStatus) {
    //     print("ServiceUnavailableStatus");
    //   } else if (event is LibraryErrorStatus) {
    //     print("LibraryErrorStatus");
    //   }
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Directionality(
            textDirection: TextDirection.ltr,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    child: Text("map"),
                  ),
                  Builder(
                    builder: (context) {
                      return Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: FlutterMapWidget(
                            initialPolygons: [
                              [LatLng(35, 50), LatLng(35, 51), LatLng(36, 51), LatLng(35, 50)],
                            ],
                            activeRegions: [
                              [
                                LatLng(34.7, 49.7),
                                LatLng(34.7, 51.2),
                                LatLng(36.6, 51.2),
                                LatLng(34.7, 49.7)
                              ],
                              [
                                LatLng(33.7, 49.7),
                                LatLng(33.7, 51.2),
                                LatLng(34.6, 51.2),
                                LatLng(33.7, 49.7)
                              ]
                            ],
                            // initialZoomOnCurrentLocation: false,
                            enableMyLocationButton: true,
                            // initializeLocationOnInitState: false,
                            onFieldOfViewChange: (p0) {},
                          ));
                    },
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
