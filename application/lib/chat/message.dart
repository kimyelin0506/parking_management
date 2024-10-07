import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:parcking_management/chat/chat_bubble.dart';
import 'package:parcking_management/screen/home_screen.dart';
import '../config/palette.dart';

class Message extends StatefulWidget {
  final String sendUid;
  final String rcvUid;
  final String sendId;
  final String rcvId;

  const Message({
    required this.sendUid,
    required this.sendId,
    required this.rcvUid,
    required this.rcvId,
    super.key});

  @override
  State<Message> createState() => _MessageState(
    sendUid: sendUid,
    sendId: sendId,
    rcvUid: rcvUid,
    rcvId: rcvId,
  );
}

class _MessageState extends State<Message> {
  final String sendUid;
  final String sendId;
  final String rcvUid;
  final String rcvId;
  final ScrollController _scrollController = ScrollController();

  _MessageState({
    required this.sendUid,
    required this.sendId,
    required this.rcvUid,
    required this.rcvId,
});
  AppBar AppBarStyle(){
    return AppBar(
      backgroundColor: Colors.blueGrey,
      title: Text('$rcvId 와 채팅하기', style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarStyle(),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('chat')
              .orderBy('time', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
            if(snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final chatDocs = snapshot.data!.docs;
            // 스크롤을 맨 아래로 이동시키는 함수
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController
                    .jumpTo(_scrollController.position.maxScrollExtent);
              }
            });
            return ListView.builder(
                controller: _scrollController,
                itemCount: chatDocs.length,
                itemBuilder: (context, index){
                  int ix = chatDocs.length - index-1;
                  Timestamp time = chatDocs[index]['time'];
                  DateTime dt = DateTime.fromMicrosecondsSinceEpoch(time.microsecondsSinceEpoch);
                  // 관련된 이용자들과의 채팅 내용 찾기 - 상대방에게 내가 보냈을 때
                  if ((sendId == chatDocs[ix]['sendId'].toString())
                      && (rcvId == chatDocs[ix]['rcvId'].toString())) {
                    return ChatBubbles(
                        sendUid: sendUid,
                        sendId: sendId,
                        rcvUid: rcvUid,
                        rcvId: rcvId,
                        isMe: true,
                        time: dt,
                        message: chatDocs[ix]['message'],
                        chatId: chatDocs[ix]['chatId']);
                  }
                  // 관련된 이용자들과의 채팅 내용 찾기 - 상대방에게 내가 받았을 때
                  if ((rcvId == chatDocs[ix]['sendId'].toString())
                      && sendId == chatDocs[ix]['rcvId'].toString()){
                    return ChatBubbles(
                        sendUid: rcvId,
                        sendId: sendId,
                        rcvUid: rcvUid,
                        rcvId: rcvId,
                        isMe: false,
                        time: dt,
                        message: chatDocs[ix]['message'],
                        chatId: chatDocs[ix]['chatId']
                    );
                  }
                  return Container();
                });
          }
      ),
    );
  }
}
