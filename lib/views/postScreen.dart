import 'package:chat_app_flutter/services/database.dart';
import 'package:chat_app_flutter/views/stackScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {

  TextEditingController contentTextEditingController = new TextEditingController();
  final LocalStorage storage = new LocalStorage('user_store');
  DatabaseMethods databaseMethods = new DatabaseMethods();
  QuerySnapshot userSnapshot;
  bool  isContent = false, isImage = false, isLoad = false;
  var _image;
  var uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text(
          "Create new post",
          style: TextStyle(
              fontSize: 20
          ),
        ),
        actions: [
          isLoad ? Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            width: 100,
            height: 50,
            padding: EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.orange[800],
            ),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ) : isContent || isImage ? GestureDetector(
            onTap: () async {
              if(_image == null){
                setState(() {
                  isLoad = true;
                });
                String postId = uuid.v1();
                Map<String, dynamic> postMap ={
                  "postId": postId,
                  "post by": storage.getItem('userEmail'),
                  "content": contentTextEditingController.text,
                  "like": 0,
                  "comment": 0
                };
                await databaseMethods.createNewPost(postId, postMap);
                databaseMethods.getUserByUserEmail(storage.getItem('userEmail')).then((val) async {
                  userSnapshot = val;
                  Map<String, int> updateMap = {
                  "post": userSnapshot.documents[0].data['post'] + 1
                  };
                  await databaseMethods.updateUserByEmail(storage.getItem('userEmail'), updateMap);
                  await databaseMethods.userActivityPost(storage.getItem('userEmail'), postId);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StackScreen()));
                });
              }else{
                String fileName = basename(_image.path);
                StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
                StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
                StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
                setState(() {
                  isLoad = true;
                });
                databaseMethods.loadImage(fileName).then((val) async {
                  String postId = uuid.v1();
                  Map<String, dynamic> postMap ={
                    "postId": postId,
                    "post by": storage.getItem('userEmail'),
                    "content": contentTextEditingController.text,
                    "imgUrl": val.toString(),
                    "like": 0,
                    "comment": 0
                  };
                  await databaseMethods.createNewPost(postId, postMap);
                  databaseMethods.getUserByUserEmail(storage.getItem('userEmail')).then((val) async {
                    userSnapshot = val;
                    Map<String, int> updateMap = {
                      "post": userSnapshot.documents[0].data['post'] + 1
                    };
                    await databaseMethods.updateUserByEmail(storage.getItem('userEmail'), updateMap);
                    await databaseMethods.userActivityPost(storage.getItem('userEmail'), postId);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StackScreen()));
                  });
                });
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              width: 100,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.orange[800],
              ),
              child: Center(
                child: Text(
                  "Post",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white
                  ),
                ),
              ),
            ),
          ) : Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            width: 100,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.grey[400],
            ),
            child: Center(
              child: Text(
                "Post",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600]
                ),
              ),
            ),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey[300],
                Colors.grey[400]
                ]
            )
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height*1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Container(
                    width: double.infinity,
                    height: 1,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[600]),
                      color: Colors.grey[300],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            width: MediaQuery.of(context).size.width*1,
                            height: 200,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.orange[900],
                                      Colors.orange[800],
                                      Colors.orange[400]]
                                )
                            ),
                            child: Center(
                              child: Container(
                                width: MediaQuery.of(context).size.width*0.8,
                                child: TextField(
                                  controller: contentTextEditingController,
                                  onChanged: (text) {
                                    if(text.length != 0){
                                      setState(() {
                                        isContent = true;
                                      });
                                    }else{
                                      setState(() {
                                        isContent = false;
                                      });
                                    }
                                  },
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20
                                  ),
                                  cursorColor: Colors.white,
                                  cursorWidth: 3,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: "What are you thinking",
                                    hintStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          isImage ? GestureDetector(
                            onTap: () {
                              setState(() {
                                isImage = false;
                              });
                              setState(() {
                                _image =null;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              width: MediaQuery.of(context).size.width*1,
                              height: 200,
                              child: Image.file(_image, fit: BoxFit.fitHeight),
                            ),
                          ) : GestureDetector(
                            onTap: () async {
                              var image = await ImagePicker.pickImage(source: ImageSource.gallery);
                              setState(() {
                                _image = image;
                              });
                              if(_image != null){
                                setState(() {
                                  isImage = true;
                                });
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              width: MediaQuery.of(context).size.width*1,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.orange[800],
                              ),
                              child: Center(
                                child: Text(
                                  "New image",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
