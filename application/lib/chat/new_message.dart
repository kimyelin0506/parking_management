import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parcking_management/screen/home_screen.dart';
import '../config/palette.dart';
import 'package:uuid/uuid.dart';

class NewMessage extends StatefulWidget {
  final String sendUid;
  final String rcvUid;
  final String sendId;
  final String rcvId;

  const NewMessage({
    required this.sendUid,
    required this.sendId,
    required this.rcvUid,
    required this.rcvId,
    super.key});

  @override
  State<NewMessage> createState() =>
      _NewMessageState(
        sendUid: sendUid,
        sendId: sendId,
        rcvUid: rcvUid,
        rcvId: rcvId,
      );
}

class _NewMessageState extends State<NewMessage> {
  final String sendUid;
  final String rcvUid;
  final String sendId;
  final String rcvId;
  var _enterMessage='';
  String randomId = '';
  final _controller = TextEditingController();

  _NewMessageState({
    required this.sendUid,
    required this.sendId,
    required this.rcvUid,
    required this.rcvId,
  });

  void _sendMessage() async {
    randomId = Uuid().v1();
    FocusScope.of(context).unfocus();

     await FirebaseFirestore.instance
         .collection('chat').doc(randomId).set({
       'message': _enterMessage,
       'time': Timestamp.now(),
       'sendUid': sendUid,
       'rcvUid': rcvUid,
       'sendId': sendId,
       'rcvId': rcvId,
       'likeMessage': false,
       'chatId' : randomId,
     });

    _controller.clear();
    randomId ='';
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(child:
            TextField(
              maxLines: null,
              controller: _controller,
              decoration: InputDecoration(
                  labelText: '메세지 보내기'
              ),
              onChanged: (value){
                setState(() {
                  _enterMessage= value;
                });
              },
            ),
            ),
            IconButton(
                onPressed: (){
                  _enterMessage.trim().isEmpty ? null : _sendMessage();
                },
                icon: Icon(Icons.send, color: Colors.blue,))
          ],
        ),
      ),
    );
  }
}
