import 'package:flutter/material.dart';
import 'package:chat_app_flutter/views/home.dart';
import 'package:chat_app_flutter/views/drawer.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class StackScreen extends StatefulWidget {
  @override
  _StackScreenState createState() => _StackScreenState();
}

class _StackScreenState extends State<StackScreen> {

  bool isNav = true;
  int bar = 0;

  void setNav() {
    setState(() {
      isNav = !isNav;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          DrawerViewer(),
          Home(setNav, bar)
        ],
      ),
      bottomNavigationBar: AnimatedOpacity(
        opacity: isNav ? 1.0 : 0.0,
        duration: Duration(milliseconds: 400),
        child: CurvedNavigationBar(
          backgroundColor: Colors.grey[300],
          color: Colors.orange[800],
          buttonBackgroundColor: Colors.white,
          animationDuration: Duration(
            milliseconds: 300
          ),
          //animationCurve: Curves.decelerate,
          items: <Widget>[
            Icon(Icons.home, size: 20, color: Colors.black,),
            Icon(Icons.message, size: 20, color: Colors.black,),
            Icon(Icons.notifications, size: 20, color: Colors.black,)
          ],
          onTap: (index){
            setState(() {
              bar = index;
            });
          },
        ),
      )
    );
  }
}

