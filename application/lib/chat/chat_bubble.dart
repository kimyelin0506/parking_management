import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parcking_management/screen/home_screen.dart';
import '../config/palette.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';



class ChatBubbles extends StatefulWidget {
  final String sendUid;
  final String rcvUid;
  final bool isMe;
  final DateTime time;
  final String message;
  final String chatId;
  final String sendId;
  final String rcvId;

  const ChatBubbles({
    required this.rcvId,
    required this.sendId,
    required this.sendUid,
    required this.rcvUid,
    required this.isMe,
    required this.time,
    required this.message,
    required this.chatId,
    super.key});

  @override
  State<ChatBubbles> createState() => _ChatBubblesState(
    sendUid: sendUid,
    sendId: sendId,
    rcvUid: rcvUid,
    rcvId: rcvId,
    isMe: isMe,
    time: time,
    message: message,
    chatId: chatId,
  );
}

class _ChatBubblesState extends State<ChatBubbles> {
  String sendUid;
  String rcvUid;
  String sendId;
  String rcvId;
  bool isMe;
  DateTime time;
  String message;
  String chatId;
  bool likeMessage = false;
  String _userProfileImg = '';
  bool _isProfile = false;

  _ChatBubblesState({
    required this.sendId,
    required this.rcvId,
    required this.sendUid,
    required this.rcvUid,
    required this.isMe,
    required this.time,
    required this.message,
    required this.chatId,
});
  
  // 유저의 프로필 사진이 셋팅되어 있는 경우
  void setUserProfile() async {
    await FirebaseFirestore.instance.collection('user')
        .where('userIDs', arrayContains: sendId)
        .get().then((value) {
          for(var snap in value.docs){
            if(snap['profileUrl'].toString() != ''){
              if(this.mounted){
                setState(() {
                  _userProfileImg = snap['profileUrl'];
                  _isProfile = true;
                });
              }
            }
          }
    });
    print('------profile------');
  }

  // 유저가 이전에 메세지 좋아요를 눌렀는 지 확인하는 코드
  void searchLike() async {
    await FirebaseFirestore.instance.collection('chat')
        .where('chatId', isEqualTo: chatId)
        .get().then((value) {
          print('---like message---');
          for(var snap in value.docs){
            if(this.mounted){
              setState(() {
                likeMessage = snap['likeMessage'];
              });
            }
          }
          (e) => print('Error');
    });
  }
  void getUserIds() async {
    await FirebaseFirestore.instance.collection('chat').where('chatId', isEqualTo: chatId).get().then((value) {
      for(var snap in value.docs){
        setState(() {
          rcvId = snap['rcvId'];
          sendId = snap['sendId'];
        });
      }
    });
  }

  @override
  void initState(){
    searchLike();
    setUserProfile();
    //getUserIds();
    super.initState();
    print('rcvId: $rcvId');
    print('sendId: $sendId');

  }

  @override
  void dispose() {
    searchLike();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        // 보낸 사람이 나일 때
        if (isMe)
          Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                  child: ChatBubble(
                    clipper: ChatBubbleClipper1(type: BubbleType.sendBubble),
                    alignment: Alignment.bottomRight,
                    margin: EdgeInsets.only(top: 20),
                    backGroundColor: Colors.blue,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width *0.7,
                      ),
                      child: Column(
                        crossAxisAlignment: isMe?
                        CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            sendId!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 20,),
                          Text(message,style: TextStyle(color: Colors.white),)
                        ],
                      ),
                    ),
                  )
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 23, 0),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width*0.7,
                    ),
                    child: Text('${time.year}년 ${time.month}월 ${time.day}일 ${time.hour}시 ${time.minute}분',
                    style: TextStyle(fontSize: 15, color: Colors.black87),),
                  ),
                  )
                ]
              )

            ],
          ),
        if (!isMe)
          Stack(
            children: [
              if (_isProfile)
                Positioned(
                  top: 20,
                    left: 8,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(_userProfileImg),)
                ),
              if (!_isProfile)
                Positioned(
                  left: 8,
                  child: CircleAvatar(
                    backgroundImage: AssetImage('asset/image/profile.png'),
                ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(padding: EdgeInsets.fromLTRB(50, 0, 0, 0),
                        child: ChatBubble(
                          clipper: ChatBubbleClipper8(
                              type: BubbleType.receiverBubble),
                          backGroundColor: Color(0xffE7E7ED),
                          margin: EdgeInsets.only(top: 20),
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width *0.7,
                            ),
                            child: Column(
                              crossAxisAlignment: isMe?
                              CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rcvId!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  message,
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                          onDoubleTap: () {
                            if (!likeMessage) {
                              setState(() {
                                Map<String, bool> map = {'likeMessage': true};
                                FirebaseFirestore.instance
                                    .collection('chat')
                                    .where('chatId', isEqualTo: chatId)
                                    .get()
                                    .then((value) {
                                  print('---like message---');
                                  for (var snap in value.docs) {
                                 setState(() {
                                   FirebaseFirestore.instance
                                       .collection('chat')
                                       .doc(chatId)
                                       .update(map);
                                   likeMessage = snap['likeMessage'];
                                 });
                                  }
                                });
                              });
                            }
                            if (likeMessage) {
                              setState(() {
                                Map<String, bool> map = {'likeMessage': false};
                                FirebaseFirestore.instance
                                    .collection('chat')
                                    .where('chatId', isEqualTo: chatId)
                                    .get()
                                    .then((value) {
                                  print('---like message---');
                                  for (var snap in value.docs) {
                                    setState(() {
                                      FirebaseFirestore.instance
                                          .collection('chat')
                                          .doc(chatId)
                                          .update(map);
                                      likeMessage = snap['likeMessage'];
                                    });
                                  }
                                });
                              });

                            }
                          },
                          child: likeMessage?
                          Container(
                            child: Icon(Icons.favorite, color: Colors.red,),
                          ) :
                          Container(
                            child: Icon(Icons.favorite_border, color: Colors.black87,),
                          )
                      ),
                    ],
                  ),
                  SizedBox(width: 5,),
                  Padding(padding: EdgeInsets.fromLTRB(40, 0, 0,0),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width*0.7,
                      ),
                      child: Text('${time.year}년 ${time.month}월 ${time.day}일 ${time.hour}시 ${time.minute}분',
                        style: TextStyle(fontSize: 15, color: Colors.black87),),
                    ),
                  )
                ],
              ),
            ],
          )
      ],
    );
  }
}
