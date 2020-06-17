import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:ocrapplication/models/user.dart';
import 'package:ocrapplication/services/auth.dart';
//Firebase Storage Plugin
import 'package:ocrapplication/services/storage.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';

class ImageScan extends StatefulWidget {
  @override
  ImageScanPageState createState() => new ImageScanPageState();
}

class ImageScanPageState extends State<ImageScan> {
  final AuthService _auth = AuthService();
  final StorageService _storage = StorageService();
  File sampleImage;
  String text;
  GoogleTranslator translator = new GoogleTranslator();
  Future getImage() async {
    File tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(tempImage);
    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);
     text =  visionText.text;
    //await translator.translate(visionText.text, from: 'ro', to: 'en');
    // print(text);
    //text = visionText.text;
    setState(() {
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
              label: Text('logout'))
        ],
      ),
      // floatingActionButton: new FloatingActionButton.extended( //get Image button
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal()),
      //   onPressed: () async {
      //     await getImage();
      //     },
      //   backgroundColor: Colors.teal,
      //   label: Text('Choose image')
      // ),
      body: new Column(children: <Widget>[
        new Center(
            child: sampleImage == null
                ? Text('Select image')
                : _storage.enableUpload(sampleImage,context)),
        new Expanded(
          flex: 1,
          child: new SingleChildScrollView(
            child: text != null ? Text(text) : Text(""),
          ),
        ),
        new Center(
            child: FlatButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.horizontal()),
          onPressed: () async {
            await getImage();
          },
          child: Text("Select Image"),
          color: Colors.teal,
        ))
      ]),
    );
  }
}
