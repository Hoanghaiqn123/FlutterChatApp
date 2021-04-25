import 'package:chat_app_flutter/services/database.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentAnswerIdWidget extends StatefulWidget {
  String postId, commentId, email, content;
  CommentAnswerIdWidget(this.postId, this.commentId, this.email, this.content);

  @override
  _CommentAnswerIdWidgetState createState() => _CommentAnswerIdWidgetState();
}

class _CommentAnswerIdWidgetState extends State<CommentAnswerIdWidget> {

  TextEditingController commentController = new TextEditingController();
  final LocalStorage storage = new LocalStorage('user_store');
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Stream commentPost;
  QuerySnapshot userSnapshot;
  var uuid = Uuid();

  @override
  void initState() {
    databaseMethods.getCommentAnswer(widget.postId, widget.commentId).then((val) {
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
                      //margin: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      margin: EdgeInsets.fromLTRB(50, 2, 10, 2),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Avatar(snapshot.data.documents[index]["answerBy"]),
                          SizedBox(width: 10,),
                          Column(
                            mainAxisAlignment:  MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              UserName(snapshot.data.documents[index]["answerBy"]),
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  UserNameRespone(widget.email),
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
                        ],
                      ),
                    ),
                    SizedBox(height: 5,),
                    Container(
                      width: MediaQuery.of(context).size.width*1,
                      margin: EdgeInsets.symmetric( horizontal: 115),
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                Like(widget.postId, widget.commentId, snapshot.data.documents[index]["answerId"], snapshot.data.documents[index]["like"]),
                              ],
                            ),
                          ),
                          LikeIcon(widget.postId, widget.commentId, snapshot.data.documents[index]["answerId"])
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
                  SingleChildScrollView(
                    child: Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 70),
                        child: Column(
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
                                  Avatar(widget.email),
                                  SizedBox(width: 10,),
                                  Column(
                                    mainAxisAlignment:  MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      UserName(widget.email),
                                      SizedBox(height: 10,),
                                      Text(
                                        '''${widget.content}''',
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
                            SizedBox(height: 20,),
                            commentStream(),
                          ],
                        )
                    ),
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
                                  Map<String, dynamic> answerMap ={
                                    "answerId": commentId,
                                    "date": DateTime.now(),
                                    "answerBy": storage.getItem('userEmail'),
                                    "content": commentController.text,
                                    "like": 0
                                  };
                                  // Map<String, dynamic> updateMap = {
                                  //   "comment": widget.comment + 1
                                  // };
                                  databaseMethods.createCommentAnswerCollection(widget.postId, widget.commentId, answerMap);
                                  databaseMethods .userActivityCommentAnswer(storage.getItem('userEmail'), widget.postId, widget.commentId, commentId);
                                  databaseMethods.userCommentAnswerNotification(widget.email, storage.getItem('userEmail'), widget.postId, widget.commentId, commentId);
                                  //databaseMethods.postUpdate(widget.postId, updateMap);
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
  String postId, commentId, answerId;
  int like;
  Like(this.postId, this.commentId, this.answerId, this.like);

  @override
  _LikeState createState() => _LikeState();
}

class _LikeState extends State<Like> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  final LocalStorage storage = new LocalStorage('user_store');
  Stream postSnapshot;

  @override
  void initState() {
    databaseMethods.isCommentAnswerLiked(widget.postId, widget.commentId, widget.answerId, storage.getItem('userEmail')).then((val) {
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
                    databaseMethods.commentAnswerLikeUpdate(widget.postId, widget.commentId, widget.answerId, updateMap);
                    databaseMethods.commentAnswerNotLiked(widget.postId, widget.commentId, widget.answerId, storage.getItem('userEmail'));
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
                    databaseMethods.commentAnswerLikeUpdate(widget.postId, widget.commentId, widget.answerId, updateMap);
                    Map<String, dynamic> likeMap = {
                      "likeBy": storage.getItem('userEmail'),
                      "date": DateTime.now()
                    };
                    databaseMethods.createLikeCommentAnswerCollection(widget.postId, widget.commentId, widget.answerId, likeMap);
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
  String postId, commentId, answerId;
  LikeIcon(this.postId, this.commentId, this.answerId);

  @override
  _LikeIconState createState() => _LikeIconState();
}

class _LikeIconState extends State<LikeIcon> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  final LocalStorage storage = new LocalStorage('user_store');
  Stream postSnapshot;

  @override
  void initState() {
    databaseMethods.getCommentAnswerDetail(widget.postId, widget.commentId, widget.answerId).then((val) {
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

//

class UserNameRespone extends StatefulWidget {
  String email;
  UserNameRespone(this.email);
  @override
  _UserNameResponeState createState() => _UserNameResponeState();
}

class _UserNameResponeState extends State<UserNameRespone> {

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
      "@${userSnapshot.documents[0].data['name']} ",
      style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline
      ),
    );
  }
}


