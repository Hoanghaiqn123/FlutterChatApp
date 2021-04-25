import 'package:chat_app_flutter/services/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:translator/translator.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';

class ChatBotConversationScreen extends StatefulWidget {

  final String chatRoomId;
  ChatBotConversationScreen(this.chatRoomId);

  @override
  _ChatBotConversationScreenState createState() => _ChatBotConversationScreenState();
}

class _ChatBotConversationScreenState extends State<ChatBotConversationScreen> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  final LocalStorage storage = new LocalStorage('user_store');
  final translator = GoogleTranslator();
  TextEditingController messageController = new TextEditingController();
  Stream chatMessageStream;

  Widget ChatMessageList(){
    return StreamBuilder(
      stream: chatMessageStream,
      builder: (context, snapshot){
        return snapshot.hasData ? ListView.builder(
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index){
            return MessageTile(snapshot.data.documents[index].data["message"], snapshot.data.documents[index].data["sendBy"]);
          },
        ) : Container();
      },
    );
  }

  sendMessage() async {
    if(messageController.text.isNotEmpty){
      Map<String, dynamic> messageMap = {
        "message": messageController.text,
        "sendBy": storage.getItem('userEmail'),
        "time": DateTime.now().millisecondsSinceEpoch,
      };
      await databaseMethods.addMessages(widget.chatRoomId, messageMap);
      await translator.translate(messageController.text, from: 'vi', to: 'en').then((value) async {
        print(value.toString());
        AuthGoogle authGoogle = await AuthGoogle(fileJson: "assets/service.json").build();
        Dialogflow dialogflow =Dialogflow(authGoogle: authGoogle,language: Language.english);
        AIResponse response = await dialogflow.detectIntent(value.text);
        print(response.getListMessage());
        messageController.text = "";
        await translator.translate(response.getListMessage()[0]["text"]["text"][0].toString(), from: 'en', to: 'vi').then((value) async{
          Map<String, dynamic> chatbotMessageMap = {
            "message": value.toString(),
            "sendBy": "small bot chat",
            "time": DateTime.now().millisecondsSinceEpoch,
          };
          await databaseMethods.addMessages(widget.chatRoomId, chatbotMessageMap);
        });
      });
    }
  }

  @override
  void initState() {
    databaseMethods.getMessages(widget.chatRoomId).then((val) {
      setState(() {
        chatMessageStream = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[300],
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
                      child: ChatMessageList()
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
                              controller: messageController,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20
                              ),
                              decoration: InputDecoration(
                                  hintText: "Message ...",
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
                                sendMessage();
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

class MessageTile extends StatefulWidget {
  final String sendBy;
  final String message;
  MessageTile(this.message, this.sendBy);

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {

  final LocalStorage storage = new LocalStorage('user_store');
  final translator = GoogleTranslator();
  String translateText;
  bool istranslate = false, isFirstTime = true;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        width: MediaQuery.of(context).size.width,
        alignment: widget.sendBy == storage.getItem('userEmail') ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onTap: () async {
            if(isFirstTime == true)  {
              await translator.translate(widget.message, from: 'vi', to: 'en').then((value) {
                setState(() {
                  translateText = value.toString();
                });
                setState(() {
                  isFirstTime = false;
                });
              });
            }
            setState(() {
              istranslate = !istranslate;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
                color: widget.sendBy == storage.getItem('userEmail') ? Colors.blue[800] : Colors.orange[800],
                borderRadius: widget.sendBy == storage.getItem('userEmail') ?
                BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20)
                ) : BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )
            ),
            child: istranslate ? Text(
                translateText,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
                )
            ) :
            Text(
                widget.message,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
                )
            ),
          ),
        ),
      ),
    );
  }
}

