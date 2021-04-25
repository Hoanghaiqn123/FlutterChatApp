import 'package:chat_app_flutter/services/database.dart';
import 'package:chat_app_flutter/views/body/homeBody.dart';
import 'package:chat_app_flutter/views/body/notification.dart';
import 'package:chat_app_flutter/views/body/userList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:localstorage/localstorage.dart';


class Home extends StatefulWidget {

  final Function setNav;
  int bar;

  Home(this.setNav, this.bar);


  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  final LocalStorage storage = new LocalStorage('user_store');

  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;

  bool isDrawerOpen = false;

  @override
  Widget build(BuildContext context) {
    switch(widget.bar){
      case 1:{
        databaseMethods.updateUserStatus("waitingToChat", storage.getItem('userEmail'));
      }
      break;

      default:{
        databaseMethods.updateUserStatus("NotReadyToChat", storage.getItem('userEmail'));
      }

    }
    return AnimatedContainer(
      transform: Matrix4.translationValues(xOffset, yOffset, 0)
        ..scale(scaleFactor)..rotateY(isDrawerOpen? -0.5:0),
      duration: Duration(milliseconds: 250),
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          color: Colors.grey[300],

          borderRadius: BorderRadius.circular(isDrawerOpen?40:0.0)

      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  isDrawerOpen?IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: (){
                      setState(() {
                        xOffset=0;
                        yOffset=0;
                        scaleFactor=1;
                        isDrawerOpen=false;
                        widget.setNav();
                      });
                    },

                  ): IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: () {
                        setState(() {
                          xOffset = 230;
                          yOffset = 150;
                          scaleFactor = 0.6;
                          isDrawerOpen=true;
                          widget.setNav();
                        });
                      }),
                  Text(
                    "Flutter Chat App",
                    style: TextStyle(color: Colors.orange[800], fontSize: 20, fontWeight: FontWeight.w700),
                  )
                ],
              ),
            ),
            SizedBox(height: 10,),
            Container(
              width: double.infinity,
              height: 1,
              decoration: BoxDecoration(
                color: Colors.grey[500]
              ),
            ),
            Container(
              child: widget.bar == 0 ? HomeBody() : widget.bar == 1 ? UserList() : NotificationBody()
            )
          ],
        ),
      ),
    );
  }
}
