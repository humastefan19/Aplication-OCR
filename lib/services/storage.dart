

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
//Firebase Storage Plugin
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ocrapplication/models/user.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';


class StorageService extends StatefulWidget {
  final _StorageState storageState = _StorageState();
  @override
  _StorageState createState() => _StorageState();


  Widget enableUpload(File sampleImage, BuildContext context,String text)
  {
    var user = Provider.of<User>(context);
    return Container(
      child: Column(
        children: <Widget>[
          Image.file(sampleImage, height: 300.0,width: 300.0),
          RaisedButton(
            color: Colors.teal[400],
            child: Text('Upload'),
            textColor: Colors.white,
            onPressed: () async {
              uploadImage(sampleImage, user, text);
              },//onPresses
          ),
        ],
      ),
    );
  }

  static int index = 0;
  Future uploadImage(File sampleImage, User user, String text) async
  {
    var fileName = p.basename(sampleImage.path);
    final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);

    StorageTaskSnapshot snapshot = await firebaseStorageRef
              .putFile(sampleImage)
              .onComplete;
    if(snapshot.error == null){
      final downloadUrl =  await snapshot.ref.getDownloadURL();
      await Firestore.instance.collection("images").add({"uid":user.uid,"name":fileName,"url":downloadUrl,'text':text});
    }
    
  }

}

class _StorageState extends State<StorageService> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.tealAccent[100],
        appBar:AppBar(
        backgroundColor: Colors.teal[400],
        elevation: 0.0,
        title:Text('Upload Image'),
    )
    );
  }

}