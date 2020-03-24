import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocrapplication/ml-vision/camera_preview_scanner.dart';
import 'package:ocrapplication/ml-vision/material_barcode_scanner.dart';
import 'package:ocrapplication/ml-vision/picture_scanner.dart';
import 'package:ocrapplication/screens/image_scan.dart';
import 'package:ocrapplication/services/auth.dart';
//Firebase Storage Plugin
import 'package:ocrapplication/services/storage.dart';
import 'package:translator/translator.dart';

class Home extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<Home> {
  final AuthService _auth = AuthService();
  final StorageService _storage = StorageService();
  File sampleImage;
  Future getImage() async {
    File tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      sampleImage = tempImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('home created');

    final List<String> _exampleWidgetNames = <String>[
      '$ImageScan',
      '$CameraPreviewScanner'
    ];

    return Scaffold(
      backgroundColor: Colors.tealAccent[50],
      appBar: AppBar(
        title: Text('OCR Application'),
        backgroundColor: Colors.teal[400],
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () async {
                await _auth.signOut();
              },
              icon: Icon(Icons.person),
              label: Text('logout'))
        ],
      ),
      floatingActionButton: new FloatingActionButton.extended(
          //get Image button
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.horizontal()),
          onPressed: () async {
            await getImage();
          },
          backgroundColor: Colors.teal,
          label: Text('Choose image')),
      body: ListView.builder(
        itemCount: _exampleWidgetNames.length,
        itemBuilder: (BuildContext context, int index) {
          final String widgetName = _exampleWidgetNames[index];

          return Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
            child: ListTile(
              title: Text(widgetName),
              onTap: () => Navigator.pushNamed(context, '/$widgetName'),
            ),
          );
        },
      ),
    );
  }
}
