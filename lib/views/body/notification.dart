import 'package:chat_app_flutter/services/database.dart';
import 'package:chat_app_flutter/views/body/comment.dart';
import 'package:chat_app_flutter/views/commentAnswer.dart';
import 'package:chat_app_flutter/views/postDetail.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationBody extends StatefulWidget {
  @override
  _NotificationBodyState createState() => _NotificationBodyState();
}

class _NotificationBodyState extends State<NotificationBody> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  final LocalStorage storage = new LocalStorage('user_store');
  QuerySnapshot userSnapshot;
  Stream notifications;

  @override
  void initState() {
    databaseMethods.getAllNotifications(storage.getItem('userEmail')).then((val) {
      setState(() {
        userSnapshot = val;
      });
    });
    super.initState();
  }

  Widget notificationsList(){
    return userSnapshot != null && userSnapshot.documents != null ? ListView.builder(
        itemCount: userSnapshot.documents.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index){
          return userSnapshot.documents[index].data["content"] == "commented your post" ? NotificationCommentCard(
              userSnapshot.documents[index].data["content"],
              userSnapshot.documents[index].data["comment email"],
              userSnapshot.documents[index].data["postId"],
              userSnapshot.documents[index].data["commentId"],
              userSnapshot.documents[index].data["status"]
          ) : userSnapshot.documents[index].data["content"] == "answered your comment" ? NotificationCommentAnswerCard(
            userSnapshot.documents[index].data["content"],
            userSnapshot.documents[index].data["answer email"],
            userSnapshot.documents[index].data["postId"],
            userSnapshot.documents[index].data["commentId"],
            userSnapshot.documents[index].data["answerId"],
            userSnapshot.documents[index].data["status"],
          ) : userSnapshot.documents[index].data["content"] == "reported this post" ? NotificationReportCard(
              userSnapshot.documents[index].data["postId"],
              userSnapshot.documents[index].data["email report"],
              userSnapshot.documents[index].data["content"]
          ) : Container();
        },
      ): Container(
          child: Text("You've not any notifications yet!")
      );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
          child: notificationsList()
      ),
    );
  }
}

class NotificationCommentCard extends StatefulWidget {
  String content, email, postId, commentId, status;
  NotificationCommentCard(this.content, this.email, this.postId, this.commentId, this.status);
  @override
  _NotificationCommentCardState createState() => _NotificationCommentCardState();
}
class _NotificationCommentCardState extends State<NotificationCommentCard> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  final LocalStorage storage = new LocalStorage('user_store');
  QuerySnapshot userSnapshot, postSnapshot;

  @override
  void initState() {
    databaseMethods.getUserByUserEmail(widget.email).then((val) {
      setState(() {
        userSnapshot = val;
      });
    });
    databaseMethods.getPostDocumentById(widget.postId).then((val) {
      setState(() {
        postSnapshot = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => CommentWidget(widget.postId, postSnapshot.documents[0].data['comment'])));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        height: 50,
        width: MediaQuery.of(context).size.width*1,
        color: Colors.white,
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(
                userSnapshot.documents[0].data['avatarUrl'],
              ),
              radius: 20,
            ),
            SizedBox(width: 10),
            Row(
              children: [
                Text("${userSnapshot.documents[0].data['name']} ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.content),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class NotificationCommentAnswerCard extends StatefulWidget {
  String content, email, postId, commentId, answerId, status;
  NotificationCommentAnswerCard(this.content, this.email, this.postId, this.commentId, this.answerId, this.status);
  @override
  _NotificationCommentAnswerCardState createState() => _NotificationCommentAnswerCardState();
}

class _NotificationCommentAnswerCardState extends State<NotificationCommentAnswerCard> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  final LocalStorage storage = new LocalStorage('user_store');
  QuerySnapshot userSnapshot, commentSnapshot;

  @override
  void initState() {
    databaseMethods.getUserByUserEmail(widget.email).then((val) {
      setState(() {
        userSnapshot = val;
      });
    });
    databaseMethods.getCommentDocumentDetail(widget.postId, widget.commentId).then((val) {
      setState(() {
        commentSnapshot = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => CommentAnswerIdWidget(widget.postId, widget.commentId, storage.getItem('userEmail'), commentSnapshot.documents[0].data['content']) ));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        height: 50,
        width: MediaQuery.of(context).size.width*1,
        color: Colors.white,
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(
                userSnapshot.documents[0].data['avatarUrl'],
              ),
              radius: 20,
            ),
            SizedBox(width: 10),
            Row(
              children: [
                Text("${userSnapshot.documents[0].data['name']} ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.content),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class NotificationReportCard extends StatefulWidget {
  String postId, email, content;
  NotificationReportCard(this.postId, this.email, this.content);
  @override
  _NotificationReportCardState createState() => _NotificationReportCardState();
}

class _NotificationReportCardState extends State<NotificationReportCard> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  final LocalStorage storage = new LocalStorage('user_store');
  QuerySnapshot userSnapshot, commentSnapshot;

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
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailView(widget.postId) ));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        height: 50,
        width: MediaQuery.of(context).size.width*1,
        color: Colors.white,
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(
                userSnapshot.documents[0].data['avatarUrl'],
              ),
              radius: 20,
            ),
            SizedBox(width: 10),
            Row(
              children: [
                Text("${userSnapshot.documents[0].data['name']} ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.content),
              ],
            )
          ],
        ),
      ),
    );
  }
}




