import 'package:chat_app_flutter/views/stackScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';
import 'package:chat_app_flutter/services/database.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfileDetailScreen extends StatefulWidget {
  String email;
  ProfileDetailScreen(this.email);
  @override
  _ProfileDetailScreenState createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  final LocalStorage storage = new LocalStorage('user_store');
  Stream userCurrent;
  bool isEdit = false;
  TextEditingController userNameEditingController = new TextEditingController();

  @override
  void initState() {
    databaseMethods.getUserCurrent(widget.email).then((val) {
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
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    snapshot.data.documents[0]["avatarUrl"],
                                  ),
                                  radius: 50.0,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Row(
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
                                    SizedBox(width: 15,),
                                    PlusIcon(widget.email)
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

class PlusIcon extends StatefulWidget {
  String email;
  PlusIcon(this.email);
  @override
  _PlusIconState createState() => _PlusIconState();
}

class _PlusIconState extends State<PlusIcon> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  final LocalStorage storage = new LocalStorage('user_store');
  Stream userCurrent;
  QuerySnapshot userSnapshot;

  @override
  void initState() {
    databaseMethods.getFollow(storage.getItem('userEmail'), widget.email).then((val) {
      print(val);
      setState(() {
        userCurrent = val;
      });
    });
    super.initState();
  }

  Widget plusIcon(){
    return StreamBuilder(
      stream: userCurrent,
        builder: (context, snapshot){
          if(snapshot.hasData){
            //print(snapshot.data.documents[0]["follow email"]);
            if(snapshot.data.documents.length > 0){
              return GestureDetector(
                onTap: () async{
                  await databaseMethods.getUserByUserEmail(storage.getItem('userEmail')).then((val) {
                    setState(() {
                      userSnapshot = val;
                    });
                    Map<String, dynamic> updateMap = {
                      "follow": userSnapshot.documents[0].data["follow"] - 1
                    };
                    databaseMethods.updateUserByEmail(storage.getItem('userEmail'), updateMap);
                  });
                  await databaseMethods.getUserByUserEmail(widget.email).then((val) {
                    setState(() {
                      userSnapshot = val;
                    });
                    Map<String, dynamic> updateMap2 = {
                      "follower": userSnapshot.documents[0].data["follower"] - 1
                    };
                    databaseMethods.updateUserByEmail(widget.email, updateMap2);
                  });
                  databaseMethods.removeFollow(storage.getItem('userEmail'), widget.email);
                  databaseMethods.removeFollower(widget.email, storage.getItem('userEmail'));
                },
                child: Row(
                  children: [
                    Text("Followed", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 22)),
                    SizedBox(width: 5),
                    Icon(
                        Icons.check,
                        size: 35,
                        color: Colors.white.withOpacity(0.7)
                    ),
                  ],
                ),
              );
            }else{
              return GestureDetector(
                onTap: () async {
                  await databaseMethods.getUserByUserEmail(storage.getItem('userEmail')).then((val) {
                    setState(() {
                      userSnapshot = val;
                    });
                  });
                  Map<String, dynamic> updateMap = {
                    "follow": userSnapshot.documents[0].data["follow"] + 1
                  };
                  databaseMethods.updateUserByEmail(storage.getItem('userEmail'), updateMap);
                  Map<String, dynamic> followMap = {
                    "follow email": widget.email,
                    "date": DateTime.now(),
                  };
                  databaseMethods.createFollow(storage.getItem('userEmail'), followMap);
                  Map<String, dynamic> followerMap = {
                    "follow by": storage.getItem('userEmail'),
                    "date": DateTime.now(),
                  };
                  databaseMethods.createFollower(widget.email, followerMap);
                  await databaseMethods.getUserByUserEmail(widget.email).then((val) {
                    setState(() {
                      userSnapshot = val;
                    });
                    Map<String, dynamic> updateMap2 = {
                      "follower": userSnapshot.documents[0].data["follower"] + 1
                    };
                    databaseMethods.updateUserByEmail(widget.email, updateMap2);
                  });
                },
                child: Row(
                  children: [
                    Text("Follow", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 22)),
                    SizedBox(width: 5,),
                    Icon(
                        Icons.add,
                        size: 35,
                        color: Colors.white.withOpacity(0.7)
                    ),
                  ],
                ),
              );
            }
          }
          return Container();
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return plusIcon();
  }
}

