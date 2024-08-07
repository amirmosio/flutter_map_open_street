// import 'dart:async';
//
// import 'package:location/location.dart';
// import 'package:rxdart/subjects.dart';
//
// class LocationUtils {
//   static LocationUtils? _utility;
//
//   static LocationUtils getInstance() {
//     if (_utility == null) {
//       _utility = LocationUtils();
//     }
//     return _utility!;
//   }
//
//   LocationData? lastKnownLocationData;
//
//   StreamSubscription? _locationStreamSubscription;
//   BehaviorSubject<LocationStatusInfo> _localeSubject = BehaviorSubject<LocationStatusInfo>();
//
//   StreamSink<LocationStatusInfo> get _locationSink => _localeSubject.sink;
//
//   Stream<LocationStatusInfo> get locationStream => _localeSubject.asBroadcastStream();
//
//   dispose() {
//     _locationStreamSubscription?.cancel();
//     _localeSubject.close();
//   }
//
//   initSubject() {
//     _localeSubject = BehaviorSubject<LocationStatusInfo>();
//   }
//
//   Future<bool> checkAndRequestServiceAndPermission(Location locationService) async {
//     // locationService.enableBackgroundMode(enable: true);
//     // bool _serviceEnabled = await locationService.serviceEnabled();
//     // if (!_serviceEnabled) {
//     //   _serviceEnabled = await locationService.requestService();
//     //   if (!_serviceEnabled) {
//     //     _locationSink.add(ServiceUnavailableStatus());
//     //     return false;
//     //   }
//     // }
//     //
//     // PermissionStatus _permissionGranted = await locationService.hasPermission();
//     // if (_permissionGranted == PermissionStatus.denied) {
//     //   _permissionGranted = await locationService.requestPermission();
//     //   if (_permissionGranted != PermissionStatus.granted) {
//     //     _locationSink.add(PermissionDeniedStatus());
//     //     return false;
//     //   }
//     // }
//     print("check successful");
//     return true;
//   }
//
//   Future<LocationData?> getLocation() async {
//     Location locationService = new Location();
//     bool accessGranted = await checkAndRequestServiceAndPermission(locationService);
//     if (!accessGranted) return null;
//
//     if (_locationStreamSubscription == null || lastKnownLocationData == null) {
//       _locationSink.add(SearchingForLocation());
//       LocationData _locationData = await locationService.getLocation();
//       if (_locationData.longitude == null || _locationData.latitude == null) {
//         _locationSink.add(LibraryErrorStatus());
//         return null;
//       }
//       lastKnownLocationData = _locationData;
//       _locationSink.add(LocationReceived(_locationData));
//     }
//
//     return lastKnownLocationData;
//   }
//
//   Future<void> initializeLocationStream() async {
//     if (_locationStreamSubscription == null) {
//       Location locationService = new Location();
//       bool accessGranted = await checkAndRequestServiceAndPermission(locationService);
//       if (!accessGranted) return null;
//       _locationSink.add(SearchingForLocation());
//       _locationStreamSubscription = locationService.onLocationChanged.listen((event) {
//         lastKnownLocationData = event;
//         _locationSink.add(LocationReceived(event));
//       });
//     }
//   }
// }
//
// abstract class LocationStatusInfo {}
//
// class SearchingForLocation extends LocationStatusInfo {
//   SearchingForLocation();
// }
//
// class LocationReceived extends LocationStatusInfo {
//   final LocationData locationData;
//
//   LocationReceived(this.locationData);
// }
//
// class PermissionDeniedStatus extends LocationStatusInfo {}
//
// class ServiceUnavailableStatus extends LocationStatusInfo {}
//
// class LibraryErrorStatus extends LocationStatusInfo {}
