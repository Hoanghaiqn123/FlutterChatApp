import 'package:chat_app_flutter/services/database.dart';
import 'package:chat_app_flutter/views/body/homeBody.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostDetailView extends StatefulWidget {
  String postId;
  PostDetailView(this.postId);
  @override
  _PostDetailViewState createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {

  QuerySnapshot userSnapshot, postSnapshot;
  DatabaseMethods databaseMethods = new DatabaseMethods();
  final LocalStorage storage = new LocalStorage('user_store');
  Stream postDetail;

  @override
  void initState() {
    databaseMethods.getPostByPostId(widget.postId).then((val) {
      setState(() {
        postDetail = val;
      });
    });
    super.initState();
  }

  Widget postDetailInfo(){
    return StreamBuilder(
        stream: postDetail,
        builder: (context, snapshot){
          if(snapshot.hasData){
            if(snapshot.data.documents.length > 0){
              return PostContent(snapshot.data.documents[0]["post by"], snapshot.data.documents[0]["content"], snapshot.data.documents[0]["imgUrl"], snapshot.data.documents[0]["postId"], snapshot.data.documents[0]["like"], snapshot.data.documents[0]["comment"]);
            }
          }
          return Container();
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text(
          "Comment",
          style: TextStyle(
              color: Colors.orange
          ),
        ),
        //backgroundColor: Colors.grey[800],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300]
        ),
        child: Stack(
          children: [
            postDetailInfo(),
          ],
        ),
      ),
    );
  }
}
