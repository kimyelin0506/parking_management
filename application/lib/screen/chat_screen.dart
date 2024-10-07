import 'dart:ffi';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parcking_management/chat/message.dart';
import 'package:parcking_management/chat/new_message.dart';
import 'package:parcking_management/config/parkingList.dart';
import 'package:parcking_management/screen/appointment_parking_screen.dart';
import 'package:parcking_management/screen/chat_screen.dart';
import 'package:parcking_management/screen/signUp_screen.dart';
import '../config/palette.dart';


class ChatScreen extends StatefulWidget {
  final String sendUid;
  final String rcvUid;
  final String sendid;
  final String rcvid;

  const ChatScreen({
    required this.sendUid,
    required this.sendid,
    required this.rcvUid,
    required this.rcvid,
    super.key});

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState(
      sendUid: sendUid,
      sendid: sendid,
      rcvUid: rcvUid,
      rcvid: rcvid,
      );
}

class _ChatScreenState extends State<ChatScreen> {
  final String sendUid;
  final String rcvUid;
  final String sendid;
  final String rcvid;
  var _enterMessage='';
  final _controller = TextEditingController();

  _ChatScreenState({
    required this.sendUid,
    required this.sendid,
    required this.rcvUid,
    required this.rcvid,
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            child: Column(
              children: [
                Expanded(
                  child: Message(
                    sendUid: sendUid,
                    sendId: sendid,
                    rcvUid: rcvUid,
                    rcvId: rcvid,
                  ),
                ),
                NewMessage(
                    sendUid: sendUid,
                    sendId: sendid,
                    rcvUid: rcvUid,
                    rcvId: rcvid)
              ],
            ),
          )
        ],
      ),
    );
  }
}
