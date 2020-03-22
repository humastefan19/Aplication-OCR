import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:ocrapplication/services/auth.dart';
//Firebase Storage Plugin
import 'package:ocrapplication/services/storage.dart';

class Home extends StatefulWidget {

  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<Home>
{
      final AuthService _auth = AuthService();
      final StorageService _storage = StorageService();
      List<OcrText> _textsOcr = [];
      File sampleImage;
      Future getImage() async
      {
        File tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

        setState(()
        {
          sampleImage = tempImage;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          label: Text('logout')
        )
    ],
    ),
    floatingActionButton: new FloatingActionButton.extended( //get Image button
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal()),
      onPressed: () async {
        await getImage();
        },
      backgroundColor: Colors.teal,
      label: Text('Choose image')
    ),
    body: new ListView(
      children: <Widget>[
        sampleImage == null ? Text('Select image') : _storage.enableUpload(sampleImage),
        RaisedButton(
          onPressed: _read,
          color: Colors.teal,
          child: new Text('READ!'),
        ),
        for(var i = 0; i < _textsOcr.length; i++)
         Text(_textsOcr[i].value),
    
      ]
    ),
    );
  }

    ///
  /// OCR Method
  ///
  Future<Null> _read() async {
    List<OcrText> texts = [];
    try {
      texts = await FlutterMobileVision.read(
        camera: 1,
      );
    } on Exception {
      texts.add(new OcrText('Failed to recognize text.'));
    }

    if (!mounted) return;

    setState(() => _textsOcr = texts);
  }
}