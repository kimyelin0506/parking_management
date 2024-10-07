import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parcking_management/screen/chat_screen.dart';
import 'package:parcking_management/screen/group_message_screen.dart';
import 'package:parcking_management/screen/home_screen.dart';
import '../config/palette.dart';

class ChatListScreen extends StatefulWidget {
  final String currentId;
  const ChatListScreen({
    required this.currentId,
    super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState(currentId: currentId);
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _controller = TextEditingController();
  bool searchRes= false;
  String searchCarNum='';
  String? currentId;
  String? currentUid;
  List userUids=[];
  List carNums=[];
  List userIDs=[];
  AppBar AppBarStyle(){
    return AppBar(
      title: Text('채팅 리스트'),
      backgroundColor: Colors.white10,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          // 여기에 원하는 작업을 추가하세요.
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return HomeScreen(selectId: currentId!,
                seatPass: '');
          }));
        },
      ),
    );
  }

  _ChatListScreenState({
    required this.currentId
});

  // 검색 결과가 나왔을 때
  void showSearchDialog(){
    showDialog(context: context,
        builder: (BuildContext context){
      return Center(
        child: AlertDialog(
          title: Text('발견하였습니다!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
              content: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                height: MediaQuery.of(context).size.height - 600,
                width: MediaQuery.of(context).size.width - 100,
                child: Center(
                  child: Text(
                    '검색하신 ${searchCarNum}를 찾았습니다.',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              actions: <Widget>[
            TextButton(
                onPressed: ()=> Navigator.of(context).pop(),
                child: Container(
                  color: Colors.black26,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 7, 10, 7),
                    child: Text('취소', style: TextStyle(color: Colors.white, fontSize: 15),),
                  ),
                )),
            TextButton(
                onPressed: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context){
                        return GroupMessageScreen(
                            carNum: searchCarNum!,
                            sendId: currentId!);
                      }));
            },
                child: Container(
                  color: Colors.indigo,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 7, 10, 7),
                    child: Text('메세지 보내기',style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
                  ),
                ))
          ],
        ),
      );
        });
  }

  // 검색 결과가 나오지 않았을 때
  void noticeDialog(){
    showDialog(context: context,
        builder: (BuildContext context){
      return Center(
        child: AlertDialog(
          title: Center(child: Text('찾지 못했습니다.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),)),
              content: Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width - 100,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('검색하신 차량번호가 틀렸거나 ', style: TextStyle(fontSize: 20),),
                          Text('등록되지 않은 차량번호입니다', style: TextStyle(fontSize: 20),),
                        ],
                      ))),
              actions: [
            Center(
                child: TextButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                      _controller.clear();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurStyle: BlurStyle.outer,
                            blurRadius: 10,
                          ),
                        ]
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 7, 10, 7),
                        child: Text('확인', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
                      ),
                    )))
          ],
        ),
      );
        });
  }

  // 검색 결과 판단
  Future<Widget> judgeSearch() async{
    await _searchCarNum();
    if(searchRes){
      showSearchDialog();
    }
    else{
      noticeDialog();
    }
    return Container();
  }

  // 검색한 차량 번호의 기등록 유무 판단
  Future<void> _searchCarNum() async {
    searchRes = false;
    await FirebaseFirestore.instance.collection('user')
        .where('carNum', isEqualTo: searchCarNum)
        .get().then((value) {
      for(var snap in value.docs){
        setState(() {
          searchRes = true; // 찾는 값이 있을 경우 true로 반환
        });
      }
    });
  }

  void getUid() async{
    await FirebaseFirestore.instance
        .collection('user').where('userIDs', arrayContains: currentId)
        .get().then((value) {
      for(var snap in value.docs){
        setState(() {
          currentUid = snap['Uid'];
        });
      }
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUid();
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
                Container(
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: IconButton(
                          onPressed: ()async {
                            searchCarNum.trim().isEmpty? null : judgeSearch();
                            print(searchCarNum);
                            print('------');
                            print(searchRes);
                          },
                          icon: Icon(Icons.search),
                        ),
                      ),
                      Container(
                        width: MediaQuery.sizeOf(context).width-100,
                        child: TextField(
                          controller: _controller,
                          maxLines: null,
                          decoration: InputDecoration(
                            labelText: '자동차 번호로 채팅하기',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(35)),
                              borderSide: BorderSide(color: Colors.black45),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black45),
                              borderRadius: BorderRadius.all(Radius.circular(35)),
                            ),
                            hintText: '자동차 번호를 입력해 주세요.',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.black26,
                            ),
                            contentPadding: EdgeInsets.all(10),
                          ),
                          onChanged: (value){
                            setState(() {
                              searchCarNum = value;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 15,),
                Divider(thickness: 5,),
                SingleChildScrollView(
                  child: Container(
                      height: MediaQuery.sizeOf(context).height-200,
                      width: MediaQuery.sizeOf(context).width-50,
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('user').snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snap){
                          if(snap.connectionState == ConnectionState.waiting)
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          final userDoc = snap.data!.docs;
                          for(var snap in userDoc){
                            print(snap['userIDs']);
                            for(var i in snap['userIDs']){
                              userIDs.add(i);
                              carNums.add(snap['carNum']);
                              userUids.add(snap['Uid']);
                            }
                          }
                          print(userIDs);
                          return ListView.builder(
                              itemCount: userIDs.length-1,
                              itemBuilder: (context, index){
                                if (userIDs[index] != currentId)
                                  return Column(
                                    children: [
                                      SizedBox(height: 10,),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey,
                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                        ),
                                        height: 70,
                                        child: Padding(
                                            padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                                            child: TextButton.icon(
                                              onPressed: (){
                                                Navigator.of(context).push( 
                                                    MaterialPageRoute(builder: (context){
                                                      return ChatScreen(
                                                          sendUid: currentUid!,
                                                          sendid: currentId!, 
                                                          rcvUid: userUids[index],
                                                          rcvid: userIDs[index]);
                                                    }));
                                              },
                                              icon: Padding(
                                                padding: const EdgeInsets.only(left: 10, right: 5),
                                                child: Icon(Icons.person_rounded, color: Colors.indigo,),
                                              ),
                                              label: Row(
                                                  children:[
                                                    Text('[${carNums[index]}]: ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
                                                    SizedBox(height: 20,),
                                                    Text('${userIDs[index]}', style: TextStyle(color: Colors.black, fontSize: 20),)
                                                  ]
                                              ),
                                            )
                                        ),
                                      ),
                                    ],
                                  );
                                else
                                  return Container();
                          });
                        },
                      ),
                    ),
                )
              ],
            ),
          ),
      ),
    );
  }
}
