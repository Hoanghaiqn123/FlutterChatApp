import 'package:chat_app_flutter/views/stackScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';
import 'package:chat_app_flutter/services/database.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  final LocalStorage storage = new LocalStorage('user_store');
  Stream userCurrent;
  bool isEdit = false;
  TextEditingController userNameEditingController = new TextEditingController();

  @override
  void initState() {
    databaseMethods.getUserCurrent(storage.getItem('userEmail')).then((val) {
      setState(() {
        userCurrent = val;
      });
    });
    super.initState();
  }

  uploadPic() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    String fileName = basename(image.path);
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(image);
    StorageTaskSnapshot taskSnapshot=await uploadTask.onComplete;
    print(fileName);
    databaseMethods.loadImage(fileName).then((val) {
      Map<String, dynamic> updateMap = {
        "avatarUrl": val.toString()
      };
      databaseMethods.updateUserByEmail(storage.getItem('userEmail'), updateMap);
      print(val.toString());
    });
  }

  Widget profile(){
    return StreamBuilder(
      stream: userCurrent,
        builder: (context, snapshot){
          return snapshot.hasData ? Column(
            children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.orange[900],
                            Colors.orange[800],
                            Colors.orange[400]]
                      )
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context, MaterialPageRoute(builder: (context) => StackScreen()));
                            }
                        ),
                        Container(
                          width: double.infinity,
                          height: 350.0,
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        snapshot.data.documents[0]["avatarUrl"],
                                      ),
                                      radius: 50.0,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 70.0),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.camera_alt_outlined,
                                          size: 30.0,
                                        ),
                                        onPressed: () {
                                          uploadPic();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                isEdit ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width*0.6,
                                      child: TextFormField(
                                        controller: userNameEditingController,
                                      ),
                                    ),
                                    IconButton(
                                        icon: Icon(Icons.save_alt),
                                        onPressed: () {
                                          if(userNameEditingController.text.length == 0){
                                            setState(() {
                                              isEdit = false;
                                            });
                                          }else{
                                            setState(() {
                                              isEdit = false;
                                            });
                                            Map<String, dynamic> updateMap = {
                                              "name": userNameEditingController.text
                                            };
                                            databaseMethods.updateUserByEmail(storage.getItem('userEmail'), updateMap);
                                          }
                                        }
                                    )
                                  ],
                                ) : Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      snapshot.data.documents[0]["name"],
                                      style: TextStyle(
                                        fontSize: 22.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          size: 22.0,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isEdit = true;
                                          });
                                          userNameEditingController.text = "";
                                        }
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Card(
                                  margin: EdgeInsets.symmetric(horizontal: 20.0,vertical: 5.0),
                                  clipBehavior: Clip.antiAlias,
                                  color: Colors.white,
                                  elevation: 5.0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 22.0),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Column(

                                            children: <Widget>[
                                              Text(
                                                "Posts",
                                                style: TextStyle(
                                                  color: Colors.orange[600],
                                                  fontSize: 22.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                              Text(
                                                snapshot.data.documents[0]["post"].toString(),
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  color: Colors.orange[600],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(

                                            children: <Widget>[
                                              Text(
                                                "Followers",
                                                style: TextStyle(
                                                  color: Colors.orange[600],
                                                  fontSize: 22.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                              Text(
                                                snapshot.data.documents[0]["follower"].toString(),
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  color: Colors.orange[600],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(

                                            children: <Widget>[
                                              Text(
                                                "Follow",
                                                style: TextStyle(
                                                  color: Colors.orange[600],
                                                  fontSize: 22.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                              Text(
                                                snapshot.data.documents[0]["follow"].toString(),
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  color: Colors.orange[600],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
              ),
            ],
          ) : Container() ;
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(child: profile())
    );
  }
}
