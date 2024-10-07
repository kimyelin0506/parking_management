import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parcking_management/screen/chat_list_screen.dart';
import 'package:parcking_management/screen/chat_screen.dart';
import 'package:parcking_management/screen/home_screen.dart';
import 'package:uuid/uuid.dart';
import '../config/palette.dart';

class GroupMessageScreen extends StatefulWidget {
  final String carNum;
  final String sendId;

  const GroupMessageScreen({
    required this.carNum,
    required this.sendId,
    super.key});

  @override
  State<GroupMessageScreen> createState() =>
      _GroupMessageScreenState(
        carNum: carNum,
        sendId: sendId,
      );
}

class _GroupMessageScreenState extends State<GroupMessageScreen> {
  final String carNum;
  final String sendId;
  String? rcvUid;
  String? sendUid;
  List rcvUserIds = [];
  final _controller = TextEditingController();
  var _enterMessage = '';
  String? randomId;

  _GroupMessageScreenState({
    required this.carNum,
    required this.sendId,
});

  void getCurrentUserData() async {
    await FirebaseFirestore.instance.collection('user')
        .where('userIDs', arrayContains: sendId)
        .get().then((value) {
      for(var snap in value.docs){
        setState(() {
          sendUid = snap['Uid'];
        });
      }
    });
  }

  void getRcvUserData() async {
    print('-----$carNum ------');
    await FirebaseFirestore.instance.collection('user')
        .where('carNum', isEqualTo: carNum)
        .get().then((value) {
          for(var snap in value.docs){
           // print(snap['carNum']);
            for(var i in snap['userIDs']){
              rcvUserIds.add(i);
            }
          }
    });
    print('-------');
    print(rcvUserIds);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRcvUserData();
    getCurrentUserData();
  }

  AppBar AppBarStyle(){
    return AppBar(
      title: Text('메세지 보내기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black26),),
      centerTitle: true,
      backgroundColor: Colors.white10,
    );
  }

  void sendMessage() async {
    randomId = Uuid().v1();
    FocusScope.of(context).unfocus();

    for(var ids in rcvUserIds){
      randomId = Uuid().v1();
      await FirebaseFirestore.instance.collection('chat')
          .doc(randomId).set({
        'message': _enterMessage,
        'time': Timestamp.now(),
        'sendUid': sendUid,
        'rcvUid': rcvUid,
        'sendId': sendId,
        'rcvId': ids,
        'likeMessage': false,
        'chatId' : randomId,
      });
    }
    return showDialogComplete();
  }

  void showDialogComplete() {

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: AlertDialog(
              title: Center(child: Text('메세지 전송 완료', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),)),
              content:Container(
                color: Colors.blueGrey,
                height: MediaQuery.of(context).size.height-300,
                width: MediaQuery.of(context).size.width-100,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Column(
                              children: [
                                SizedBox(height: 20,),
                                Text('보낸 유저',style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                                SizedBox(height: 10,),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                                    child: Text('${sendId}', style: TextStyle(fontSize: 20),),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                              child: Column(
                                children: [
                                  SizedBox(height: 20,),
                                  Text('전송한 내용',style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                                  SizedBox(height: 10,),
                                  SingleChildScrollView(
                                    child: Container(
                                      height: 200,
                                      width: 300,
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                                        child: Text('${_enterMessage}',style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ),
              actions: <Widget>[
                Center(
                  child: TextButton(onPressed: (){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context)
                        {return ChatListScreen(currentId: sendId);
                        }));
                  },
                      child: Container(
                        color: Colors.black45,
                        child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                        child: Text('채팅 리스트화면으로 돌아가기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),),
                      ),
                      )),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarStyle(),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30,),
              // 단체 메세지 작성
              Container(
                height: MediaQuery.of(context).size.height-300,
                width: MediaQuery.of(context).size.width-100,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      blurStyle: BlurStyle.outer,
                    )
                  ]
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _controller,
                    maxLines: 20,
                    maxLength: 500,
                    decoration: InputDecoration(
                      labelText: '보낼 메세지 내용을 작성해주세요',
                      labelStyle: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: TextStyle(color: Colors.black, fontSize: 20),
                    onChanged: (value){
                      setState(() {
                        _enterMessage = value;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20,),
              // 전송 버튼
              TextButton(onPressed: (){
                _enterMessage.trim().isEmpty ? null : sendMessage();
              },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          blurStyle: BlurStyle.outer,
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                      child: Text('메세지 전송',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),),
                    ),
                  )
              ),
              SizedBox(height: 20,),
              // 안내 문구
              Text('*검색하신 차량 번호의 모든 멀티프로필 계정으로 보내는 메세지입니다.*',
                  style: TextStyle(color: Colors.green, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}
