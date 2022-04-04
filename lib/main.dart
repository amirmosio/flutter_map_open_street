import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map_open_street/flutter_map_open_street.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(Application());
}

class Application extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(child: FlutterMapWidget()));
  }
}
