import 'package:chat_app_flutter/views/body/comment.dart';
import 'package:chat_app_flutter/views/body/profileDetailScreen.dart';
import 'package:chat_app_flutter/views/home.dart';
import 'package:chat_app_flutter/views/postScreen.dart';
import 'package:chat_app_flutter/views/profileScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';
import 'package:chat_app_flutter/services/database.dart';
import 'package:uuid/uuid.dart';
import 'package:animations/animations.dart';

class HomeBody extends StatefulWidget {
  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  final LocalStorage storage = new LocalStorage('user_store');
  final transitionType = ContainerTransitionType.fade;
  Stream post;
  int typePost = 1;

  @override
  void initState() {
    databaseMethods.getAllPost().then((val) {
      setState(() {
        post = val;
      });
    });
    super.initState();
  }

  Widget postList(){
    return StreamBuilder(
      stream: post,
        builder: (context, snapshot){
        if(snapshot.hasData){
          if(snapshot.data.documents.length > 0){
            print("Follow length 2: ${snapshot.data.documents.length}");
            return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  return PostContent(snapshot.data.documents[index]["post by"], snapshot.data.documents[index]["content"], snapshot.data.documents[index]["imgUrl"], snapshot.data.documents[index]["postId"], snapshot.data.documents[index]["like"], snapshot.data.documents[index]["comment"]);
                },
              );
          }
          else{
            return Container();
          }
        }
        else{
          return Container();
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment:  MainAxisAlignment.center,
        children: <Widget>[
          OpenContainer(
            transitionType: transitionType,
            transitionDuration: Duration(milliseconds: 800),
            openBuilder: (context, _) => PostScreen(),
            closedBuilder: (context, VoidCallback openContainer) => Container(
              width: MediaQuery.of(context).size.width*1,
              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[600]),
                color: Colors.grey[300],
              ),
              child: Text(
                "What are you thinking",
                style: TextStyle(
                    color: Colors.grey[500]
                ),
              ),
            ),
          ),
          SizedBox(height: 30,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    typePost = 1;
                  });
                },
                child: Container(
                  width:  120,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: typePost == 1 ? Colors.orange[700] : Colors.grey[500],
                  ),
                    child: Center(child: Text(
                      "All Post",
                      style: TextStyle(
                        fontSize: 18
                      ),
                    ))
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    typePost = 2;
                  });
                },
                child: Container(
                    width:  120,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: typePost == 2 ? Colors.orange[700] : Colors.grey[500],
                    ),
                    child: Center(
                      child: Text(
                          "Your follow",
                        style: TextStyle(
                            fontSize: 18
                        ),
                      ),
                    )
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    typePost = 3;
                  });
                },
                child: Container(
                    width:  120,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: typePost == 3 ? Colors.orange[700] : Colors.grey[500],
                    ),
                    child: Center(
                        child: Text(
                          "Save Post",
                          style: TextStyle(
                              fontSize: 18
                          ),
                        )
                    )
                ),
              ),
            ],
          ),
          typePost == 1 ? postList() : typePost == 2 ? FollowPostList() : SavePost()
        ],
      ),
    );
  }
}

class SavePost extends StatefulWidget {
  @override
  _SavePostState createState() => _SavePostState();
}

class _SavePostState extends State<SavePost> {

  QuerySnapshot userSnapshot, postSnapshot;
  DatabaseMethods databaseMethods = new DatabaseMethods();
  final LocalStorage storage = new LocalStorage('user_store');
  String postId;

  @override
  void initState() {
    databaseMethods.getSavePost(storage.getItem('userEmail')).then((val) {
      setState(() {
        postSnapshot = val;
      });
    });
    super.initState();
  }

  Widget SavePostList(){
    if(postSnapshot != null && postSnapshot.documents.length > 0){
      return ListView.builder(
        itemCount: postSnapshot.documents.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index){
            //return PostDetail(storage.getItem('userEmail'));
            return PostDetail(postSnapshot.documents[index].data["postId"]);
          }
      );
    }
    return Container(
      child: Text("You have not save any thing yet !!!"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SavePostList();
  }
}

class PostDetail extends StatefulWidget {
  String postId;
  PostDetail(this.postId);
  @override
  _PostDetailState createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {

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
    return postDetailInfo();
  }
}



class Avatar extends StatefulWidget {
  String email, postId ;
  Avatar(this.email, this.postId);
  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {

  QuerySnapshot userSnapshot, postSnapshot, adminSnapshot, adminRoleSnapshot;
  DatabaseMethods databaseMethods = new DatabaseMethods();
  final LocalStorage storage = new LocalStorage('user_store');

  @override
  void initState()  {
    databaseMethods.getUserByUserEmail(widget.email).then((val) {
      setState(() {
        userSnapshot = val;
      });
    });
    databaseMethods.getUserByUserEmail(storage.getItem('userEmail')).then((val) {
      setState(() {
        adminRoleSnapshot = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return userSnapshot != null ? Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: (){
                if(widget.email == storage.getItem('userEmail')){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                }
                else{
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileDetailScreen(widget.email)));
                }
              },
              child: Hero(
                tag: userSnapshot.documents[0].data["avatarUrl"],
                child: CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(userSnapshot.documents[0].data["avatarUrl"]),
                ),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userSnapshot.documents[0].data["name"],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userSnapshot.documents[0].data["email"],
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500]),
                ),
              ],
            )
          ],
        ),
        //Icon(Icons.more_vert)
        PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (result) {
              if(result == 0){
                databaseMethods.getAdmin().then((val){
                  adminSnapshot = val;
                  //print(adminSnapshot.documents[0].data["email"]);
                  for(var i = 0; i< adminSnapshot.documents.length; i++){
                    print(adminSnapshot.documents[i].data["email"]);
                    databaseMethods.userReportNotification(adminSnapshot.documents[i].data["email"], storage.getItem('userEmail'), widget.postId);
                  }
                });
              }
              if(result == 1){
                databaseMethods.userActivityCheckSavePost(storage.getItem('userEmail'), widget.postId).then((val) {
                  postSnapshot = val;
                  if(postSnapshot.documents.length == 0){
                    databaseMethods.userActivitySavePost(storage.getItem('userEmail'), widget.postId);
                  }
                });
              }
              if(result == 2){
                databaseMethods.deletePost(widget.postId);
              }
            },
            itemBuilder:  (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.flag ,size: 20, color: Colors.grey,),
                  title: Text("Report", style: TextStyle(color: Colors.black, fontSize: 20),),
                ),
                value: 0,
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.add ,size: 20, color: Colors.grey,),
                  title: Text("Save", style: TextStyle(color: Colors.black, fontSize: 20),),
                ),
                value: 1,
              ),
              PopupMenuItem(
                child: widget.email == storage.getItem('userEmail') || adminRoleSnapshot.documents[0].data["role"] == "admin" ?  ListTile(
                  leading: Icon(Icons.delete, size: 20, color: Colors.grey,),
                  title: Text("Delete", style: TextStyle(color: Colors.black, fontSize: 20),),
                ) : Container(),
                value:  widget.email == storage.getItem('userEmail') || adminRoleSnapshot.documents[0].data["role"] == "admin" ? 2 : null,
              ),
            ],
        ),
      ],
    ) : Container();
  }
}

//

class Like extends StatefulWidget {
  String postId;
  int like;
  Like(this.postId, this.like);

  @override
  _LikeState createState() => _LikeState();
}

class _LikeState extends State<Like> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  final LocalStorage storage = new LocalStorage('user_store');
  Stream postSnapshot;

  @override
  void initState() {
    databaseMethods.isLiked(widget.postId, storage.getItem('userEmail')).then((val) {
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
        if(snapshot.hasData){
          if(snapshot.data.documents.length > 0){
            return GestureDetector(
              onTap: (){
                Map<String, dynamic> updateMap = {
                  "like": widget.like - 1
                };
                databaseMethods.postUpdate(widget.postId, updateMap);
                databaseMethods.notLiked(widget.postId, storage.getItem('userEmail'));
              },
              child: Icon(
                  Icons.favorite,
                  size: 35,
                  color: Colors.white.withOpacity(0.7)
              ),
            );
          }else{
            return GestureDetector(
              onTap: (){
                Map<String, dynamic> updateMap = {
                  "like": widget.like + 1
                };
                databaseMethods.postUpdate(widget.postId, updateMap);
                Map<String, dynamic> likeMap = {
                  "likeBy": storage.getItem('userEmail'),
                  "date": DateTime.now()
                };
                databaseMethods.createLikePostCollection(widget.postId, likeMap);
              },
              child: Icon(
                  Icons.favorite_border,
                  size: 35,
                  color: Colors.white.withOpacity(0.7)
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
    return likeIcon();
  }
}

//

class PostContent extends StatefulWidget {
  String postBy, content, imgUrl, postId;
  int like, comment;
  PostContent(this.postBy, this.content, this.imgUrl, this.postId, this.like, this.comment);
  @override
  _PostContentState createState() => _PostContentState();
}

class _PostContentState extends State<PostContent> {

  TextEditingController commentController = new TextEditingController();
  final LocalStorage storage = new LocalStorage('user_store');
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Stream commentPost;
  final transitionType = ContainerTransitionType.fade;
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


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Avatar(widget.postBy, widget.postId),
          SizedBox(
            height: 10,
          ),
          Text(
              '''${widget.content}'''
          ),
          SizedBox(
            height: 10,
          ),
          widget.imgUrl != null ? Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.width - 70,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                    image: DecorationImage(
                      fit: BoxFit.fitHeight,
                      image: NetworkImage(widget.imgUrl),
                    )),
              ),
              Positioned(
                  bottom: 20,
                  right: 20,
                  child: Like(widget.postId, widget.like)
              )
            ],
          ) : Container(),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.like.toString()} like',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800]),
              ),
              OpenContainer(
                transitionType: transitionType,
                transitionDuration: Duration(milliseconds: 1000),
                openBuilder: (context, _) => CommentWidget(widget.postId, widget.comment),
                closedColor: Colors.grey[350],
                closedBuilder: (context, VoidCallback openContainer) => Container(
                  color: Colors.grey[360],
                  child: Text(
                    "${widget.comment} Comment",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800]),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
class MenuItem{
  String menuVal;
  IconData iconVal;
  int value;

  MenuItem(this.menuVal, this.iconVal, this.value);
}


//

class FollowPost extends StatefulWidget {
  String email;
  FollowPost(this.email);
  @override
  _FollowPostState createState() => _FollowPostState();
}

class _FollowPostState extends State<FollowPost> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  final LocalStorage storage = new LocalStorage('user_store');
  Stream postFollow;

  @override
  void initState() {
    print("Widget.email: ${widget.email}");
    databaseMethods.getPostByEmail(widget.email).then((val) {
      postFollow = val;
    });
    super.initState();
  }

  Widget followPostList(){
    return StreamBuilder(
        stream: postFollow,
        builder: (context, snapshot){
          if(snapshot.hasData){
            if(snapshot.data.documents.length > 0){
              print(snapshot.data.documents.length);
              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  return PostContent(snapshot.data.documents[index]["post by"], snapshot.data.documents[index]["content"], snapshot.data.documents[index]["imgUrl"], snapshot.data.documents[index]["postId"], snapshot.data.documents[index]["like"], snapshot.data.documents[index]["comment"]);
                },
              );
            }
            else{
              return Container();
            }
          }
          else{
            return Container();
          }
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        followPostList(),
      ],
    );
  }
}

class FollowPostList extends StatefulWidget {
  @override
  _FollowPostListState createState() => _FollowPostListState();
}

class _FollowPostListState extends State<FollowPostList> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  final LocalStorage storage = new LocalStorage('user_store');
  Stream allFollow;

  @override
  void initState() {
    databaseMethods.getAllFollow(storage.getItem('userEmail')).then((val) {
      setState(() {
        allFollow = val;
      });
    });
    super.initState();
  }

  Widget followPostList(){
    return StreamBuilder(
        stream: allFollow,
        builder: (context, snapshot){
          if(snapshot.hasData){
            if(snapshot.data.documents.length > 0){
              print("Follow length: ${snapshot.data.documents.length}");
              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  return FollowPost(snapshot.data.documents[index]["follow email"]);
                },
              );
            }
            else{
              return Text("you are not follow any one");
            }
          }
          return Container(child: Text("dit cu"),);
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    return followPostList();
  }
}
