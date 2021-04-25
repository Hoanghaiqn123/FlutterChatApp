import 'package:chat_app_flutter/services/database.dart';
import 'package:chat_app_flutter/views/chatbot_conversation_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';
import 'package:chat_app_flutter/views/conversation_screen.dart';

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  QuerySnapshot userSnapshot, inviteInfo;
  final LocalStorage storage = new LocalStorage('user_store');
  Stream userWaiting, userChatting, userInvited;
  bool isInvite = false;
  String userNameInvite, userEmailInvite;
  Map<String, dynamic> chatRoomMapState;


  List<Map> listSnapshot = [] ;

  @override
  void initState() {
    databaseMethods.getAllUserWaitingToChat().then((val) {
      setState(() {
        userWaiting = val;
      });
    });
    databaseMethods.getUserChatting().then((val) {
      setState(() {
        userChatting = val;
      });
    });
    databaseMethods.getUserInvited().then((val) {
      setState(() {
        userInvited = val;
      });
    });
    super.initState();
  }

  Widget approveInvite(){
    return StreamBuilder(
      stream: userInvited,
        builder: (context, snapshot){
          if(snapshot.hasData){
            if(snapshot.data.documents.length > 0){
              for(var i = 0; i < snapshot.data.documents.length; i++){
                if(snapshot.data.documents[i]["email"] == storage.getItem('userEmail')){
                  //inviteInfo =  databaseMethods.getInviteInfo(storage.getItem('userEmail'));
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "invite you to chat",
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 15
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          databaseMethods.getInviteInfo(storage.getItem('userEmail')).then((val) async {
                            inviteInfo = val;
                            Map<String, dynamic> chatRoomMap = {
                              "chatRoomId": inviteInfo.documents[0].data["chatRoomId"],
                              "user": inviteInfo.documents[0].data["user"]
                            };
                            databaseMethods.createChatRoom(inviteInfo.documents[0].data["chatRoomId"], chatRoomMap);
                            databaseMethods.updateUserStatus("chatting", storage.getItem('userEmail'));
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationScreen(inviteInfo.documents[0].data["chatRoomId"])));
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.orange[800]
                          ),
                          child: Text("Accept"),
                        ),
                      ),
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap: (){
                          databaseMethods.deleteInviteInfo(storage.getItem('userEmail'));
                          databaseMethods.updateUserStatus("waitingToChat", storage.getItem('userEmail'));
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange[800],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text("Deny"),
                        ),
                      )
                    ],
                  );
                }
              }
            }
            return Container(child: Text(""),);
          }
          return Container();
        }
    );
  }

  Widget loadingScreen(){
    return StreamBuilder(
      stream: userWaiting,
        builder: (context, snapshot){
          if(snapshot.hasData){
            if(snapshot.data.documents.length > 0){
              for(var i = 0; i < snapshot.data.documents.length; i++){
                if(snapshot.data.documents[i]["email"] == userEmailInvite){
                  return ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed))
                            return Colors.orange[800];
                          return null; // Use the component's default.
                        },
                      ),

                    ),
                    onPressed: () {
                      setState(() {
                        isInvite = false;
                      });
                      databaseMethods.updateUserStatus("waitingToChat", storage.getItem('userEmail'));
                    },
                    child: Text("$userNameInvite deny you"),
                  );
                }
              }
              return Container(
                padding: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width*1,
                //width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      backgroundColor: Colors.orange[800],
                    ),
                    SizedBox(width: 10,),
                    Container(
                      //padding: EdgeInsets.all(20),
                      child: Flexible(
                        child: Text(
                          '''Waiting ${userNameInvite} approve your invite''',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.orange[800]
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Container(
              padding: EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width*1,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    backgroundColor: Colors.orange[800],
                  ),
                  SizedBox(width: 5,),
                  Container(
                    //padding: EdgeInsets.all(20),

                    child: Flexible(
                      child: Text(
                        '''Waiting ${userNameInvite} approve your invite.''',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.orange[800]
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Container(
            padding: EdgeInsets.all(20),
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  backgroundColor: Colors.orange[800],
                ),
                SizedBox(width: 10,),
                Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width*0.5,
                  child: Flexible(
                    child: Text(
                      "Waiting ${userNameInvite} approve your invite",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.orange[800]
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  Widget alertBox(){
    return StreamBuilder(
      stream: userChatting,
        builder: (context, snapshot){
          if(snapshot.hasData){
            if(snapshot.data.documents.length > 0){
              for(var i = 0; i < snapshot.data.documents.length; i++){
                if(snapshot.data.documents[i]["email"] == userEmailInvite){
                  return ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed))
                            return Colors.orange[800];
                          return null; // Use the component's default.
                        },
                      ),

                    ),
                    onPressed: () {
                      setState(() {
                        isInvite = false;
                      });
                      databaseMethods.updateUserStatus("chatting", storage.getItem('userEmail'));
                      databaseMethods.createChatRoom(chatRoomMapState["chatRoomId"], chatRoomMapState);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationScreen(chatRoomMapState["chatRoomId"])));
                      setState(() {
                        isInvite = false;
                      });
                    },
                    child: Text("Join chat room"),
                  );
                }
              }
              return Text("${snapshot.data.documents.length} in chat room");
            }
            return  loadingScreen();
          }
          return Container();
        }
    );
  }


  createChatRoom(){
    databaseMethods.getUserByUserEmail(storage.getItem('userEmail')).then((val) async {
      userSnapshot = val;
      String chatRoomId = getChatRoomId(userNameInvite, userSnapshot.documents[0].data['name']);
      List<String> user = [userEmailInvite, userSnapshot.documents[0].data['name']];
      Map<String, dynamic> chatRoomMap = {  //String for the key, dynamic for value
        "user" : user,
        "chatRoomId" :  chatRoomId
      };
      setState(() {
        chatRoomMapState = chatRoomMap;
      });
      setState(() {
        isInvite = true;
      });
      //await storage.setItem("emailInvite",email);
      await databaseMethods.updateUserStatus("invited", userEmailInvite);
      Map<String, dynamic> inviteInfoMap = {
        "email": userEmailInvite,
        "chatRoomId" :  chatRoomId,
        "user" : user,
        "sendBy" : storage.getItem('userEmail'),
      };
      databaseMethods.createInviteInfo(chatRoomId, inviteInfoMap);
    });
  }


  Widget userList(){
    return StreamBuilder(
      stream: userWaiting,
        builder: (context, snapshot){
        //print(snapshot.hasData);
          return snapshot.hasData ? ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index){ // itemBuilder is a map, index is a key
                  //print(searchSnapshot.documents);
                  //return SearchTile(userName: snapshot.data.documents[index]["name"], userEmail: snapshot.data.documents[index]["email"]); // searchSnapshot.documents[index].data
                  return snapshot.data.documents[index]["email"] != storage.getItem('userEmail') ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapshot.data.documents[index]["name"],
                              style: TextStyle(
                                  color: Colors.orange[800],
                                  fontSize: 20
                              ),
                            ),
                            Text(
                              snapshot.data.documents[index]["email"],
                              style: TextStyle(
                                  color: Colors.orange[800],
                                  fontSize: 20
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              userNameInvite = snapshot.data.documents[index]["name"];
                            });
                            setState(() {
                              userEmailInvite = snapshot.data.documents[index]["email"];
                            });
                            createChatRoom();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.orange[900],
                                borderRadius: BorderRadius.circular(30)
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: isInvite ? CircularProgressIndicator() : Text(
                              "Message",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ) : Container();
                },
              ) : Container(child: Text("No one in chat room waiting yet"),);
        }
    );
    // return listSnapshot != null ?  ListView.builder(
    //   physics: const NeverScrollableScrollPhysics(),
    //   itemCount: listSnapshot.length,
    //   shrinkWrap: true,
    //   itemBuilder: (context, index){ // itemBuilder is a map, index is a key
    //     //print(searchSnapshot.documents);
    //     return SearchTile(userName: listSnapshot[index]["name"], userEmail: listSnapshot[index]["email"]); // searchSnapshot.documents[index].data
    //   },
    // ) : Container(child: Text("Not found"),);

  }

  @override
  Widget build(BuildContext context) {
    return isInvite ? Padding(
      padding: const EdgeInsets.fromLTRB(8, 200, 8, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          alertBox(),
        ],
      ),
    ) : Column(
      children: [
        approveInvite(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Small Chat bot",
                    style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 20
                    ),
                  ),
                  Text(
                    "No one to chat? chat with me",
                    style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 15
                    ),
                  ),
                ],
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
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
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.orange[900],
                      borderRadius: BorderRadius.circular(30)
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: isInvite ? CircularProgressIndicator() : Text(
                    "Message",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
        SingleChildScrollView(
          child: userList(),
          //child: userList(),
        ),
      ],
    );
  }
}

class SearchTile extends StatefulWidget {
  final String userName;
  final String userEmail;
  SearchTile({this.userName, this.userEmail});

  @override
  _SearchTileState createState() => _SearchTileState();
}

class _SearchTileState extends State<SearchTile> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  QuerySnapshot userSnapshot;
  final LocalStorage storage = new LocalStorage('user_store');
  bool isInvite = false;
  Stream userStatus;


  createChatRoom(String userName){
    databaseMethods.getUserByUserEmail(storage.getItem('userEmail')).then((val) async {
      userSnapshot = val;
      String chatRoomId = getChatRoomId(userName, userSnapshot.documents[0].data['name']);
      List<String> user = [userName, userSnapshot.documents[0].data['name']];
      Map<String, dynamic> chatRoomMap = {  //String for the key, dynamic for value
        "user" : user,
        "chatRoomId" :  chatRoomId
      };
      setState(() {
        isInvite = true;
      });
      await storage.setItem("emailInvite", widget.userEmail);
      await databaseMethods.updateUserStatus("invited", widget.userEmail);
      // await databaseMethods.createChatRoom(chatRoomId, chatRoomMap);
      // Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationScreen(chatRoomId)));
      // setState(() {
      //   isInvite = false;
      // });
    });
  }

  @override
  void initState() {
    databaseMethods.getUserChatting().then((val) {
      setState(() {
        userStatus = val;
      });
    });
    super.initState();
  }

  // Widget alertBox(){
  //   return StreamBuilder(
  //     stream: userStatus,
  //       builder: (context, snapshot){
  //         if(snapshot.data.documents.length == 0){
  //           return Text("snapshot.length = 0");
  //         }
  //         return Text("snapshot co du lieu");
  //         //if(snapshot.hasData){
  //           //for(var i = 0; i < snapshot.data.documents.length; i++){
  //             //if(snapshot.data.documents[i]["email"] == widget.userEmail){
  //               //print("ok con de");
  //               //return Text("Dit cu");
  //               // showDialog(
  //               //     context: context,
  //               //     builder: (context){
  //               //       return AlertDialog(
  //               //         title: Text("${widget.userName} has approve your invite"),
  //               //         content: Text("click join to join the room chat or cancel to cancel join room chat"),
  //               //         actions: <Widget>[
  //               //           FlatButton(
  //               //               onPressed: () {},
  //               //               child: Text("Join")
  //               //           ),
  //               //           FlatButton(
  //               //               onPressed: () {},
  //               //               child: Text("Cancel")
  //               //           )
  //               //         ],
  //               //       );
  //               //     }
  //               // );
  //             //}
  //           //}
  //           //return Text("Ko co ai giong yeu cau");
  //         //}
  //         //return Text("Ko co ai");
  //       }
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return widget.userEmail != storage.getItem('userEmail') ? Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userName,
                style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: 20
                ),
              ),
              Text(
                widget.userEmail,
                style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: 20
                ),
              ),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              createChatRoom(widget.userName);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.orange[900],
                  borderRadius: BorderRadius.circular(30)
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: isInvite ? CircularProgressIndicator() : Text(
                  "Message",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    ) : Container();
  }
}

getChatRoomId(String a, String b) {
  var UTF8A = 0, UTF8B = 0;
  for(var i = 0; i < a.length; i++){
    UTF8A = a.codeUnitAt(i) + UTF8A;
  }
  for(var i = 0; i < b.length; i++){
    UTF8B = b.codeUnitAt(i) + UTF8B;
  }
  //print("UTF-A: $UTF8A , UTF8-B: $UTF8B");
  if (UTF8A > UTF8B) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}
