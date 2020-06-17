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
  final Image image;
  final String text;
  ImageStore({
    Key key, this.image,this.text 
  }):super(key:key);
   final AuthService _auth = AuthService();
   @override
   Widget build(BuildContext context){
     
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
             child: image),
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
