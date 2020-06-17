

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ocrapplication/models/user.dart';
import 'package:ocrapplication/screens/imageStored.dart';
import 'package:ocrapplication/screens/image_scan.dart';
import 'package:provider/provider.dart';

class GalleryDemo extends StatelessWidget {
  GalleryDemo({Key key}) : super(key: key);
  final Firestore fb = Firestore.instance;
  Future<QuerySnapshot> getImages(User user) {
    return fb.collection("images").where('uid',isEqualTo: user.uid).getDocuments();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Image Gallery Example"),
        ),
       body: Container(
        padding: EdgeInsets.all(10.0),
        child: FutureBuilder(
          future: getImages(user),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      onTap: () {
                                    Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageStore(image: snapshot.data.documents[index].data["url"],text: snapshot.data.documents[index].data["text"]),
                            ),
                          );
                        
                        
                      },
                      contentPadding: EdgeInsets.all(8.0),
                      title:
                          Text(snapshot.data.documents[index].data["name"]),
                      leading: Image.network(
                          snapshot.data.documents[index].data["url"],
                          fit: BoxFit.fill),
                    );
                  });
            } else if (snapshot.connectionState == ConnectionState.none) {
              return Text("No data");
            }
            return CircularProgressIndicator();
          },
        ),
      )
      );
      }

/// code here
  
}