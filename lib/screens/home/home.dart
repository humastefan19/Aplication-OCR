import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translator/translator.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
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
      final translator = new GoogleTranslator();
      final StorageService _storage = StorageService();
      File sampleImage;
      String text;

      Future getImage() async
      {
        File tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
        final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(tempImage);
        final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
        final VisionText visionText = await textRecognizer.processImage(visionImage);
        String tempText = visionText.text;

        tempText = await translator.translate(tempText, to: 'ro');
        
        print(tempText);

        setState(()
        {
          sampleImage = tempImage;
          text = tempText;
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
    body: new Center(
      child: sampleImage == null ? Text('Select image') : _storage.enableUpload(sampleImage),
    ),
    );
  }


}