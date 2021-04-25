import 'package:chat_app_flutter/services/database.dart';
import 'package:chat_app_flutter/views/commentAnswer.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentWidget extends StatefulWidget {
  String postId;
  int comment;
  CommentWidget(this.postId, this.comment);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {

  TextEditingController commentController = new TextEditingController();
  final LocalStorage storage = new LocalStorage('user_store');
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Stream commentPost;
  QuerySnapshot userSnapshot, postSnapshot;
  var uuid = Uuid();

  @override
  void initState() {
    databaseMethods.getComment(widget.postId).then((val) {
      setState(() {
        commentPost = val;
      });
    });
    super.initState();
  }

  Widget commentStream(){
    return StreamBuilder(
        stream: commentPost,
        builder: (context, snapshot){
          return snapshot.hasData ? ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index){
                return Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width*1,
                      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Avatar(snapshot.data.documents[index]["commentBy"]),
                          SizedBox(width: 10,),
                          Column(
                            mainAxisAlignment:  MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              UserName(snapshot.data.documents[index]["commentBy"]),
                              SizedBox(height: 10,),
                              Text(
                                '''${snapshot.data.documents[index]["content"]}''',
                                style: TextStyle(
                                  fontSize: 20
                                  //fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5,),
                    Container(
                      width: MediaQuery.of(context).size.width*1,
                      margin: EdgeInsets.symmetric( horizontal: 75),
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                Like(widget.postId, snapshot.data.documents[index]["commentId"], snapshot.data.documents[index]["like"]),
                                SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => CommentAnswerIdWidget(widget.postId, snapshot.data.documents[index]["commentId"], snapshot.data.documents[index]["commentBy"], snapshot.data.documents[index]["content"] ) ));
                                  },
                                    child: Text("Answer")
                                )
                              ],
                            ),
                          ),
                          LikeIcon(widget.postId, snapshot.data.documents[index]["commentId"])
                          //Icon(Icons.favorite)
                        ],
                      ),
                    ),
                    SizedBox(height: 20,)
                  ],
                );
              }
          ) : Container();
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
                  Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 70),
                      child: commentStream()
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      //color: Color(0x54FFFFFF),
                      color: Colors.orange,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20
                              ),
                              decoration: InputDecoration(
                                  hintText: "Comment ...",
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none
                              ),
                            ),
                          ),
                          GestureDetector(
                              onTap: (){
                                if(commentController.text.length > 0){
                                  String commentId = uuid.v1();
                                  Map<String, dynamic> commentMap ={
                                    "commentId": commentId,
                                    "date": DateTime.now(),
                                    "commentBy": storage.getItem('userEmail'),
                                    "content": commentController.text,
                                    "like": 0
                                  };
                                  Map<String, dynamic> updateMap = {
                                    "comment": widget.comment + 1
                                  };
                                  databaseMethods.createCommentPostCollection(widget.postId, commentMap);
                                  databaseMethods.postUpdate(widget.postId, updateMap);
                                  databaseMethods.userActivityComment(storage.getItem('userEmail'), widget.postId, commentId);
                                  databaseMethods.getPostByPostId(widget.postId).then((val) {
                                    setState(() {
                                      postSnapshot = val;
                                    });
                                    databaseMethods.userCommentNotification(storage.getItem('userEmail'), postSnapshot.documents[0].data["post by"], widget.postId, commentId);
                                  });
                                  commentController.text = "";
                                }
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                          const Color(0x36FFFFFF),
                                          const Color(0x0FFFFFFF)
                                        ],
                                        begin: FractionalOffset.topLeft,
                                        end: FractionalOffset.bottomRight
                                    ),
                                    borderRadius: BorderRadius.circular(40)
                                ),
                                padding: EdgeInsets.all(12),
                                child: Icon(Icons.send, size: 20, color: Colors.white),
                              )
                          )
                        ],
                      ),
                    ),
                  ),
                ]
            )
        )
    );
  }
}

//

class Avatar extends StatefulWidget {
  var email;
  Avatar(this.email);
  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {

  QuerySnapshot userSnapshot;
  DatabaseMethods databaseMethods = new DatabaseMethods();

  @override
  void initState()  {
    databaseMethods.getUserByUserEmail(widget.email).then((val) {
      setState(() {
        userSnapshot = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return userSnapshot != null ? Hero(
      tag: userSnapshot.documents[0].data["avatarUrl"],
      child: CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(userSnapshot.documents[0].data["avatarUrl"]),
      ),
    ) : CircleAvatar(radius: 22,);
  }
}

class Like extends StatefulWidget {
  String postId, commentId;
  int like;
  Like(this.postId, this.commentId, this.like);

  @override
  _LikeState createState() => _LikeState();
}

class _LikeState extends State<Like> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  final LocalStorage storage = new LocalStorage('user_store');
  Stream postSnapshot;

  @override
  void initState() {
    databaseMethods.isCommentLiked(widget.postId, widget.commentId, storage.getItem('userEmail')).then((val) {
      setState(() {
        postSnapshot = val;
      });
    });
    super.initState();
  }

  Widget likeText(){
    return StreamBuilder(
        stream: postSnapshot,
        builder: (context, snapshot){
          if(snapshot.hasData){
            if(snapshot.data.documents.length > 0){
              return GestureDetector(
                onTap: (){
                  Map<String, dynamic> updateMap = {
                    "like": widget.like - 1
                  };
                  databaseMethods.commentLikeUpdate(widget.postId, widget.commentId, updateMap);
                  databaseMethods.commentNotLiked(widget.postId, widget.commentId, storage.getItem('userEmail'));
                },
                child: Text(
                  "Like",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange
                  ),
                )
              );
            }else{
              return GestureDetector(
                onTap: (){
                  Map<String, dynamic> updateMap = {
                    "like": widget.like + 1
                  };
                  databaseMethods.commentLikeUpdate(widget.postId, widget.commentId, updateMap);
                  Map<String, dynamic> likeMap = {
                    "likeBy": storage.getItem('userEmail'),
                    "date": DateTime.now()
                  };
                  databaseMethods.createLikeCommentCollection(widget.postId, widget.commentId, likeMap);
                },
                child: Text(
                  "Like",
                )
              );
            }
          }
          return Container();
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return likeText();
  }
}

class LikeIcon extends StatefulWidget {
  String postId, commentId;
  LikeIcon(this.postId, this.commentId);

  @override
  _LikeIconState createState() => _LikeIconState();
}

class _LikeIconState extends State<LikeIcon> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  final LocalStorage storage = new LocalStorage('user_store');
  Stream postSnapshot;

  @override
  void initState() {
    databaseMethods.getCommentDetail(widget.postId, widget.commentId).then((val) {
      setState(() {
        postSnapshot = val;
      });
    });
    super.initState();
  }

  Widget likeIcon(){
    return StreamBuilder(
        stream: postSnapshot,
        builder: (context, snapshot){
          if(snapshot.hasData) {
            return snapshot.data.documents[0]["like"] > 0 ?  Container(
              child: Row(
                children: [
                  Text(snapshot.data.documents[0]["like"].toString()),
                  SizedBox(width: 10),
                  Icon(
                      Icons.favorite,
                    color: Colors.orange,
                  )
                ],
              ),
            ) : Container();
          }
          return Container();
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return likeIcon();
  }
}

class UserName extends StatefulWidget {
  String email;
  UserName(this.email);
  @override
  _UserNameState createState() => _UserNameState();
}

class _UserNameState extends State<UserName> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  QuerySnapshot userSnapshot;

  @override
  void initState() {
    databaseMethods.getUserByUserEmail(widget.email).then((val) {
      setState(() {
        userSnapshot = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      userSnapshot.documents[0].data['name'],
      style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold
      ),
    );
  }
}


