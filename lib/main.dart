import 'package:flutter/material.dart';
import 'package:ocrapplication/models/user.dart';
import 'package:ocrapplication/screens/imageStored.dart';
import 'package:ocrapplication/screens/storedfiles.dart';
import 'package:ocrapplication/screens/wrapper.dart';
import 'package:ocrapplication/services/auth.dart';
import 'package:provider/provider.dart';

import 'ml-vision/camera_preview_scanner.dart';
import 'ml-vision/picture_scanner.dart';
import 'screens/image_scan.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
        routes: <String, WidgetBuilder>{
          '/$PictureScanner': (BuildContext context) => PictureScanner(),
          '/$CameraPreviewScanner': (BuildContext context) =>
              CameraPreviewScanner(),
          '/$ImageScan': (BuildContext context) => ImageScan(),
          '/$GalleryDemo': (BuildContext context) => GalleryDemo(),
          '/$ImageStore':(BuildContext context) => ImageStore()
        },
      ),
    );
  }
}
