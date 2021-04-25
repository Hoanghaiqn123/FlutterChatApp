import 'package:chat_app_flutter/helper/authenticate.dart';
import 'package:chat_app_flutter/services/auth.dart';
import 'package:chat_app_flutter/services/database.dart';
import 'package:chat_app_flutter/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchTextEditingController = new TextEditingController();

  QuerySnapshot searchSnapshot;

  Widget searchList(){
    return searchSnapshot != null ?  ListView.builder(
        itemCount: searchSnapshot.documents.length,
          shrinkWrap: true,
          itemBuilder: (context, index){ // itemBuilder is a map, index is a key
          print(searchSnapshot.documents);
          return SearchTile(userName: searchSnapshot.documents[index].data["name"], userEmail: searchSnapshot.documents[index].data["email"],); // searchSnapshot.documents[index].data
          },
    ) : Container(child: Text("Not found"),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Flutter firebase chat app'),
          actions: [
            GestureDetector(
              onTap: (){
                authMethods.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Authenticate()));
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.exit_to_app),
              ),
            )
          ],
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              TextField(
                controller: searchTextEditingController,
                onChanged: (text){
                  databaseMethods.getUserByUserName(text).then((val) {
                    print(val);
                    setState(() {
                      searchSnapshot = val;
                    });
                  });
                },
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white54,
                    size: 25,
                  ),
                  hintText: 'Search User',
                  hintStyle: TextStyle(
                      color: Colors.white54,
                      fontSize: 20
                  ),
                ),
              ),
              searchList()
            ],
          ),
        )
    );
  }
}

class SearchTile extends StatelessWidget {
  final String userName;
  final String userEmail;
  SearchTile({this.userName, this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20
                ),
              ),
              Text(
                userEmail,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20
                ),
              )
            ],
          ),
          Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(30)
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text("Message"),
          )
        ],
      ),
    );
  }
}

