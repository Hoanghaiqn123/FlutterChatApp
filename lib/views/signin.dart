import 'package:chat_app_flutter/services/auth.dart';
import 'package:chat_app_flutter/services/database.dart';
import 'package:chat_app_flutter/views/FadeAnimation.dart';
import 'package:chat_app_flutter/views/charRoomScreen.dart';
import 'package:chat_app_flutter/views/stackScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  SignIn(this.toggleView);
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  final LocalStorage storage = new LocalStorage('user_store');
  QuerySnapshot userSnapshot;

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  signIn() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      await authMethods.signInWithEmailAndPassword(emailEditingController.text, passwordEditingController.text).then((respone) async {
        if(respone != null){
          await databaseMethods.getUserByUserEmail(emailEditingController.text).then((val) {
            userSnapshot = val;
            storage.setItem('userEmail', userSnapshot.documents[0].data['email']);
          });
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => StackScreen()));
        }
        else{
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? Center(
         child: Container(
           width: double.infinity,
           height: double.infinity,
           decoration: BoxDecoration(
               gradient: LinearGradient(
                   begin: Alignment.topCenter,
                   colors: [
                     Colors.orange[900],
                     Colors.orange[800],
                     Colors.orange[400]
                   ]
               )
           ),
           child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              CircularProgressIndicator(),
              SizedBox(width: 10),
              Text(
                "Loading",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 50
                ),
              )
            ],
          ),
        ),
       ) : Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [
                  Colors.orange[900],
                  Colors.orange[800],
                  Colors.orange[400]
                ]
            )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 80,),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeAnimation(1, Text("Login", style: TextStyle(color: Colors.white, fontSize: 40),)),
                  SizedBox(height: 10,),
                  FadeAnimation(1.3, Text("Welcome Back", style: TextStyle(color: Colors.white, fontSize: 18),)),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60))
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 60,),
                        FadeAnimation(1.4, Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(
                                  color: Color.fromRGBO(225, 95, 27, .3),
                                  blurRadius: 20,
                                  offset: Offset(0, 10)
                              )]
                          ),
                          child: Form(
                            key: formKey,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Colors.grey[200]))
                                  ),
                                  child: TextFormField(
                                    validator: (val){
                                      return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val) ? null : "Please provide correct email";
                                    },
                                    controller: emailEditingController,
                                    decoration: InputDecoration(
                                        hintText: "Email",
                                        hintStyle: TextStyle(color: Colors.grey),
                                        border: InputBorder.none
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Colors.grey[200]))
                                  ),
                                  child: TextFormField(
                                    validator: (val){
                                     return val.length > 6 ? null : "Enter Password 6+ characters";
                                   },
                                   obscureText: true,
                                   controller: passwordEditingController,
                                    decoration: InputDecoration(
                                        hintText: "Password",
                                        hintStyle: TextStyle(color: Colors.grey),
                                        border: InputBorder.none
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                        SizedBox(height: 40,),
                        FadeAnimation(1.5, Text("Forgot Password?", style: TextStyle(color: Colors.grey),)),
                        SizedBox(height: 40,),
                        FadeAnimation(
                            1.6,
                            GestureDetector(
                            onTap: (){
                              signIn();
                            },
                              child: Container(
                                height: 50,
                                margin: EdgeInsets.symmetric(horizontal: 50),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.orange[900]
                                ),
                                child: Center(
                                  child: Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                ),
                              ),
                            )),
                        SizedBox(height: 20,),
                        FadeAnimation(1.7, Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                widget.toggleView();
                              },
                              child: Text(
                                "Register now",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  decoration: TextDecoration.underline
                                ),
                              ),
                            )
                          ],
                        )),
                        SizedBox(height: 25),
                        FadeAnimation(1.7, Text("Continue with social media", style: TextStyle(color: Colors.grey),)),
                        SizedBox(height: 30,),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: FadeAnimation(1.8, Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.blue
                                ),
                                child: Center(
                                  child: Text("Facebook", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                ),
                              )),
                            ),
                            SizedBox(width: 30,),
                            Expanded(
                              child: FadeAnimation(1.9, Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.black
                                ),
                                child: Center(
                                  child: Text("Github", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                ),
                              )),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

//Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: appbarMain(context),
//       body: isLoading ? Center(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(width: 10),
//             Text(
//               "Loading",
//               style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 50
//               ),
//             )
//           ],
//         ),
//       ) : Container(
//         alignment: Alignment.bottomCenter,
//         padding: EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Form(
//               key: formKey,
//               child: Column(
//                 children: [
//                   TextFormField(
//                     validator: (val){
//                       return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val) ? null : "Please provide correct email";
//                     },
//                     controller: emailEditingController,
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16
//                     ),
//                     decoration: InputDecoration(
//                         hintText: "email",
//                         prefixIcon: Icon(
//                           Icons.email_outlined,
//                           color: Colors.white54,
//                           size: 20.0,
//                         ),
//                         hintStyle: TextStyle(
//                             color: Colors.white54
//                         ),
//                         focusedBorder: UnderlineInputBorder(
//                             borderSide: BorderSide(color: Colors.blue)
//                         ),
//                         enabledBorder: UnderlineInputBorder(
//                             borderSide: BorderSide(color: Colors.white)
//                         ),
//                     ),
//                   ),
//                   TextFormField(
//                     validator: (val){
//                       return val.length > 6 ? null : "Enter Password 6+ characters";
//                     },
//                     obscureText: true,
//                     controller: passwordEditingController,
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16
//                     ),
//                     decoration: InputDecoration(
//                       hintText: "password",
//                       prefixIcon: Icon(
//                         Icons.lock,
//                         color: Colors.white54,
//                         size: 20.0,
//                       ),
//                       hintStyle: TextStyle(
//                           color: Colors.white54
//                       ),
//                       focusedBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(color: Colors.blue)
//                       ),
//                       enabledBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(color: Colors.white)
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20.0,),
//             Container(
//               alignment: Alignment.centerRight,
//               child: Text(
//                 'Forgot password?',
//                 style: TextStyle(
//                   fontSize: 16.0,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.0,),
//             GestureDetector(
//               onTap: (){
//                 signIn();
//               },
//               child: Container(
//                 //padding: EdgeInsets.symmetric(vertical: 20),
//                 height: 50,
//                 width: MediaQuery.of(context).size.width,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       const Color(0xff007EF4),
//                       const Color(0xff2A75BC)
//                     ]
//                   ),
//                   borderRadius: BorderRadius.circular(25),
//                 ),
//                 child: Center(
//                   child: Text(
//                     'Sign In',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             Container(
//               //padding: EdgeInsets.symmetric(vertical: 20),
//               height: 50,
//               width: MediaQuery.of(context).size.width,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(25),
//               ),
//               child: Center(
//                 child: Text(
//                   'Sign In With Google',
//                   style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 16
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.0),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Text(
//                   "Don't have an account? ",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: (){
//                     widget.toggleView();
//                   },
//                   child: Text(
//                     "Register now",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       decoration: TextDecoration.underline
//                     ),
//                   ),
//                 )
//               ],
//             ),
//             SizedBox(height: 60,)
//           ],
//         ),
//       ),
//     );
//   }
