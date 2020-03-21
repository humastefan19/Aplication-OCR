import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
//Firebase Storage Plugin
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;


class StorageService extends StatefulWidget {
  final _StorageState storageState = _StorageState();
  @override
  _StorageState createState() => _StorageState();


  Widget enableUpload(File sampleImage)
  {
    return Container(
      child: Column(
        children: <Widget>[
          Image.file(sampleImage, height: 300.0,width: 300.0),
          RaisedButton(
            color: Colors.teal[400],
            child: Text('Upload'),
            textColor: Colors.white,
            onPressed: () async {
              uploadImage(sampleImage);
              },//onPresses
          ),
        ],
      ),
    );
  }

  static int index = 0;
  Future uploadImage(File sampleImage) async
  {
    var fileName = p.basename(sampleImage.path);
    final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
    final StorageUploadTask task = firebaseStorageRef.putFile(sampleImage);
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