import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseMethods{

  getUserByUserName(String username) async {
    return await Firestore.instance.collection("user").where("name", isEqualTo: username ).getDocuments(); // return QuerySnapshot value.
  }
  getUserByUserEmail(String email) async {
    try{
      return await Firestore.instance.collection("user").where("email", isEqualTo: email ).getDocuments(); // return QuerySnapshot value.
    }catch(e){
      print(e.toString());
    }
  }
  getAdmin() async {
    try{
      return await Firestore.instance.collection("user").where("role", isEqualTo: "admin" ).getDocuments(); // return QuerySnapshot value.
    }catch(e){
      print(e.toString());
    }
  }
  getUserCurrent(String email) async {
    try{
      return await Firestore.instance.collection("user").where("email", isEqualTo: email ).snapshots(); // return QuerySnapshot value.
    }catch(e){
      print(e.toString());
    }
  }
  getAllUserWaitingToChat() async {
    try{
      return await Firestore.instance.collection("user").where("status", isEqualTo: "waitingToChat").snapshots();
    }catch(e){
      print(e.toString());
    }
  }
  uploadUserInfo(String email, userMap){
    Firestore.instance.collection("user").document(email).setData(userMap);
  }
  createChatRoom(String chatRoomId, chatRoomMap){
    Firestore.instance.collection("ChatRoom").document(chatRoomId).setData(chatRoomMap).catchError((onError) {print(onError.toString());});
  }
  addMessages(String chatRoomId, messageMap){
    Firestore.instance.collection("ChatRoom").document(chatRoomId).collection("chats").add(messageMap).catchError((e) {print(e.toString());});
  }
  getMessages(String chatRoomId) async {
    try{
      return await Firestore.instance.collection("ChatRoom").document(chatRoomId).collection("chats").orderBy("time", descending: false).snapshots(); // snapshot & document ???
    }catch(e){
      print(e.toString());
    }
  }
  updateUserStatus(String status, String email){
    Map<String, dynamic> data ={
      "status": status
    };
    Firestore.instance.collection("user").document(email).updateData(data);
  }
  updateUserByEmail(String email, updateMap){
    Firestore.instance.collection("user").document(email).updateData(updateMap);
  }
  createInviteInfo(String chatRoomId, inviteInfoMap){
    String docId = "Invite to $chatRoomId";
    Firestore.instance.collection("inviteInfo").document(docId).setData(inviteInfoMap).catchError((onError) {print(onError.toString());});
  }
  getInviteInfo(email) async {
    return await Firestore.instance.collection("inviteInfo").where("email", isEqualTo: email).getDocuments();
  }
  getUserInvited() async {
    try{
      return await Firestore.instance.collection("user").where("status", isEqualTo: "invited").snapshots();
    }catch(e){
      print(e.toString());
    }
  }
  getUserChatting() async {
    try{
      return await Firestore.instance.collection("user").where("status", isEqualTo: "chatting").snapshots();
    }catch(e){
      print(e.toString());
    }
  }
  deleteInviteInfo(String email){
    Firestore.instance.collection("inviteInfo").where("email", isEqualTo: email).getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents){
        ds.reference.delete();
      }
    });
  }
  loadImage(String imageName) async {
    return await FirebaseStorage.instance.ref().child(imageName).getDownloadURL();
  }
  createNewPost(String docId, postMap){
    Firestore.instance.collection("Post").document(docId).setData(postMap).catchError((onError) {print(onError.toString());});
  }
  getAllPost() async {
    return await Firestore.instance.collection("Post").snapshots();
  }
  getPostByEmail(String email) async {
    return await Firestore.instance.collection("Post").where("post by", isEqualTo: email).snapshots();
  }
  getPostByPostId(String postId) async {
    return await Firestore.instance.collection("Post").where("postId", isEqualTo: postId).snapshots();
  }
  createLikePostCollection(String postId, likeMap) async {
    Firestore.instance.collection("Post").document(postId).collection("like").document(likeMap["likeBy"]).setData(likeMap).catchError((e) {print(e.toString());});
  }
  isLiked(String postId, email) async {
    try{
      return await Firestore.instance.collection("Post").document(postId).collection("like").where("likeBy", isEqualTo: email).snapshots();
    }catch(e){
      print(e.toString());
    }
  }
  notLiked(String postId, email){
    Firestore.instance.collection("Post").document(postId).collection("like").document(email).delete();
  }
  postUpdate(String postId, updateMap){
    Firestore.instance.collection("Post").document(postId).updateData(updateMap);
  }
  getPostById(String postId){
    return Firestore.instance.collection("Post").where("postId", isEqualTo: postId).snapshots();
  }
  getPostDocumentById(String postId){
    return Firestore.instance.collection("Post").where("postId", isEqualTo: postId).getDocuments();
  }
  deletePost(String postId){
    Firestore.instance.collection("Post").document(postId).delete();
  }
  createCommentPostCollection(String postId, commentMap) async {
    Firestore.instance.collection("Post").document(postId).collection("comment").document(commentMap["commentId"]).setData(commentMap).catchError((e) {print(e.toString());});
  }
  getComment(String postId) async {
    try {
      return await Firestore.instance.collection("Post")
          .document(postId)
          .collection("comment")
          .snapshots();
    }
    catch(e){
      print(e.toString());
    }
  }
  getCommentDetail(String postId, String commentId) async {
    return await Firestore.instance.collection("Post").document(postId).collection("comment").where("commentId", isEqualTo: commentId).snapshots();
  }
  getCommentDocumentDetail(String postId, String commentId) async {
    return await Firestore.instance.collection("Post").document(postId).collection("comment").where("commentId", isEqualTo: commentId).getDocuments();
  }
  commentLikeUpdate(String postId, String commentId, updateMap){
    Firestore.instance.collection("Post").document(postId).collection("comment").document(commentId).updateData(updateMap);
  }
  createLikeCommentCollection(String postId, String commentId, likeMap) async {
    Firestore.instance.collection("Post").document(postId).collection("comment").document(commentId).collection("like").document(likeMap["likeBy"]).setData(likeMap).catchError((e) {print(e.toString());});
  }
  isCommentLiked(String postId, String commentId, email) async {
    try{
      return Firestore.instance.collection("Post").document(postId).collection("comment").document(commentId).collection("like").where("likeBy", isEqualTo: email).snapshots();
    }catch(e){
      print(e.toString());
    }
  }
  commentNotLiked(String postId, String commentId, email){
    Firestore.instance.collection("Post").document(postId).collection("comment").document(commentId).collection("like").document(email).delete();
  }

  // comment answer
  createCommentAnswerCollection(String postId, String commentId, answerMap) async {
    Firestore.instance.collection("Post").document(postId).collection("comment").document(commentId).collection("answer").document(answerMap["answerId"]).setData(answerMap).catchError((e) {print(e.toString());});
  }
  getCommentAnswer(String postId, String commentId) async {
    return await Firestore.instance.collection("Post").document(postId).collection("comment").document(commentId).collection("answer").snapshots();
  }
  getCommentAnswerDetail(String postId, String commentId, String answerId) async {
    return await Firestore.instance.collection("Post").document(postId).collection("comment").document(commentId).collection("answer").where("answerId", isEqualTo: answerId).snapshots();
  }
  commentAnswerLikeUpdate(String postId, String commentId, String answerId, updateMap){
    Firestore.instance.collection("Post").document(postId).collection("comment").document(commentId).collection("answer").document(answerId).updateData(updateMap);
  }
  createLikeCommentAnswerCollection(String postId, String commentId, String answerId, likeMap) async {
    Firestore.instance.collection("Post").document(postId).collection("comment").document(commentId).collection("answer").document(answerId).collection("like").document(likeMap["likeBy"]).setData(likeMap).catchError((e) {print(e.toString());});
  }
  isCommentAnswerLiked(String postId, String commentId, String answerId, email) async {
    try{
      return Firestore.instance.collection("Post").document(postId).collection("comment").document(commentId).collection("answer").document(answerId).collection("like").where("likeBy", isEqualTo: email).snapshots();
    }catch(e){
      print(e.toString());
    }
  }
  commentAnswerNotLiked(String postId, String commentId, String answerId, email){
    Firestore.instance.collection("Post").document(postId).collection("comment").document(commentId).collection("answer").document(answerId).collection("like").document(email).delete();
  }

  // follow / follower
  createFollow(String email, followMap){
    Firestore.instance.collection("user").document(email).collection("follow").document(followMap["follow email"]).setData(followMap);
  }
  removeFollow(String email, String followEmail){
    Firestore.instance.collection("user").document(email).collection("follow").document(followEmail).delete();
  }
  createFollower(String email, followerMap){
    Firestore.instance.collection("user").document(email).collection("follower").document(followerMap["follow by"]).setData(followerMap);
  }
  removeFollower(String email, String followBy){
    Firestore.instance.collection("user").document(email).collection("follower").document(followBy).delete();
  }
  getFollow(String currentEmail, String followEmail) async {
    return await Firestore.instance.collection("user").document(currentEmail).collection("follow").where("follow email", isEqualTo:  followEmail).snapshots();
  }
  getAllFollow(String email) async {
    return await Firestore.instance.collection("user").document(email).collection("follow").snapshots();
  }

  // user active

  userActivityPost(String email, String postId) async {
    Firestore.instance.collection("user").document(email).collection("activity").document("activity").collection("post").document(postId).setData({"postId": postId});
  }
  userActivitySavePost(String email, String postId) async {
    Firestore.instance.collection("user").document(email).collection("activity").document("activity").collection("save post").document(postId).setData({"postId": postId});
  }
  userActivityCheckSavePost(String email, String postId) async {
    return Firestore.instance.collection("user").document(email).collection("activity").document("activity").collection("save post").where("postId", isEqualTo:  postId).getDocuments();
  }
  getSavePost(String email){
    return Firestore.instance.collection("user").document(email).collection("activity").document("activity").collection("save post").getDocuments();
  }
  userActivityComment(String email, String postId, String commentId) async {
    Firestore.instance.collection("user").document(email).collection("activity").document("activity").collection("comment").document(commentId).setData({"postId": postId, "commentId": commentId});
  }
  userActivityCommentAnswer(String email, String postId, String commentId, String answerId) async {
    Firestore.instance.collection("user").document(email).collection("activity").document("activity").collection("comment answer").document(answerId).setData({"postId": postId, "commentId": commentId, "answerId": answerId});
  }

  //notifications

  userReportNotification(String adminEmail, String emailReport, String postId){
    Map<String, dynamic> notification = {
      "content": "reported this post",
      "email report": emailReport,
      "postId": postId,
      "commentId": postId,
      "status": "not seen"
    };
    Firestore.instance.collection("user").document(adminEmail).collection("notifications").document(postId).setData(notification);
  }

  userCommentNotification(String emailComment, String emailPost, String postId, String commentId){
    Map<String, dynamic> notification = {
      "content": "commented your post",
      "comment email": emailComment,
      "postId": postId,
      "commentId": commentId,
      "status": "not seen"
    };
    Firestore.instance.collection("user").document(emailPost).collection("notifications").document(commentId).setData(notification);
  }
  userCommentAnswerNotification(String emailComment, String emailCommentAnswer, String postId, String commentId, String answerId){
    Map<String, dynamic> notification = {
      "content": "answered your comment",
      "answer email": emailCommentAnswer,
      "postId": postId,
      "commentId": commentId,
      "answerId": answerId,
      "status": "not seen"
    };
    Firestore.instance.collection("user").document(emailComment).collection("notifications").document(answerId).setData(notification);
  }
  getAllNotifications(String email){
    try{
      return Firestore.instance.collection("user").document(email).collection("notifications").getDocuments();
    }catch(e){
      print(e.toString());
    }
    //return Firestore.instance.collection("user").document(email).collection("notifications").snapshots();
  }
}