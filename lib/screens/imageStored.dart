import 'dart:convert';

import 'dart:io';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ocrapplication/services/auth.dart';
import 'package:ocrapplication/services/storage.dart';

import 'package:translator/translator.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:http/http.dart' as http;

class ImageStore extends StatelessWidget{
  final String image;
  ImageStore({
    Key key, this.image
  }):super(key:key);

 final AuthService _auth = AuthService();
   final StorageService _storage = StorageService();
    String text;
   GoogleTranslator translator = new GoogleTranslator();
   Future getImage() async {
     http.Response response = await http.get(
     image,
 );   
 //Uint8List
     var bites = response.bodyBytes;
     File tempImage = new File.fromRawPath(bites);
     final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFilePath(image);
     final TextRecognizer textRecognizer =
         FirebaseVision.instance.textRecognizer();
     final VisionText visionText =
         await textRecognizer.processImage(visionImage);
      text =  visionText.text;
     //await translator.translate(visionText.text, from: 'ro', to: 'en');
     // print(text);
     //text = visionText.text;
    
   }
   @override
   Widget build(BuildContext context){
      getImage();
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
             child: Image.network(image)),
         new Expanded(
           flex: 1,
           child: new SingleChildScrollView(
             child: text != null ? Text(text) : Text(""),
           ),
         ),
       
       ]),
     );
   }
 
  }
