import 'package:chat_app_flutter/helper/authenticate.dart';
import 'package:chat_app_flutter/helper/constants.dart';
import 'package:chat_app_flutter/services/auth.dart';
import 'package:chat_app_flutter/services/database.dart';
import 'package:chat_app_flutter/views/body/userList.dart';
import 'package:chat_app_flutter/views/chatbot_conversation_screen.dart';
import 'package:chat_app_flutter/views/profileScreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DrawerViewer extends StatefulWidget {
  @override
  _DrawerViewerState createState() => _DrawerViewerState();
}

class _DrawerViewerState extends State<DrawerViewer> {

  AuthMethods authMethods = new AuthMethods();
  final LocalStorage storage = new LocalStorage('user_store');
  DatabaseMethods databaseMethods = new DatabaseMethods();
  QuerySnapshot userSnapshot;
  String avatarUrl;

  List<Map> drawerItems=[

    {
      'icon': FontAwesomeIcons.donate,
      'title' : 'Donation'
    },
    {
      'icon': FontAwesomeIcons.plus,
      'title' : 'Save post'
    },
    {
      'icon': Icons.favorite,
      'title' : 'Favorites'
    },
    {
      'icon': Icons.mail,
      'title' : 'Messages'
    },
    {
      'icon': FontAwesomeIcons.userAlt,
      'title' : 'Profile'
    },
  ];

  @override
  void initState() {
    databaseMethods.getUserByUserEmail(storage.getItem('userEmail')).then((val) {
      userSnapshot = val;
      setState(() {
        avatarUrl = userSnapshot.documents[0].data["avatarUrl"];
      });
    });
    super.initState();
  }

  // @override
  // void initState() async {
  //   print(storage.getItem('userEmail'));
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [
                Colors.orange[900],
                Colors.orange[800],
                Colors.orange[400]
              ]
          )
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 60, 0, 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    avatarUrl
                  ),
                ),
                SizedBox(width: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( storage.getItem('userEmail') ,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 20),),
                    Text('Active Status',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 20))
                  ],
                )
              ],
            ),

            Column(
              children: drawerItems.map((element) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    switch(element['title']){
                      case "Profile": {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                      }
                      break;
                      case "Messages": {
                        databaseMethods.getUserByUserEmail(storage.getItem('userEmail')).then((val) async {
                          userSnapshot = val;
                          String chatRoomId = getChatRoomId("small chat bot", userSnapshot.documents[0].data['name']);
                          List<String> user = ["small chat bot", userSnapshot.documents[0].data['name']];
                          Map<String, dynamic> chatRoomMap = {  //String for the key, dynamic for value
                            "user" : user,
                            "chatRoomId" :  chatRoomId
                          };
                          databaseMethods.updateUserStatus("chatting", storage.getItem('userEmail'));
                          databaseMethods.createChatRoom(chatRoomId, chatRoomMap);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatBotConversationScreen(chatRoomId)));
                        });
                      }
                    }
                  },
                  child: Row(
                    children: [
                      Icon(element['icon'],color: Colors.white,size: 30,),
                      SizedBox(width: 10,),
                      Text(element['title'],style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20))
                    ],

                  ),
                ),
              )).toList(),
            ),

            Row(
              children: [
                Icon(Icons.settings,color: Colors.white, size: 20,),
                SizedBox(width: 10,),
                Text('Settings',style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 20),),
                SizedBox(width: 10,),
                Container(width: 2,height: 25,color: Colors.white,),
                SizedBox(width: 10,),
                GestureDetector(
                  onTap: (){
                    authMethods.signOut();
                    databaseMethods.updateUserStatus("NotReadyToChat", storage.getItem('userEmail'));
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Authenticate()));
                  },
                    child: Text('Log out',style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 20),)
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

