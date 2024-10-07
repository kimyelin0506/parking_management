import 'dart:ffi';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parcking_management/config/NavBar.dart';
import 'package:parcking_management/config/parkingList.dart';
import 'package:parcking_management/config/userData.dart';
import 'package:parcking_management/screen/appointment_parking_screen.dart';
import 'package:parcking_management/screen/chat_screen.dart';
import 'package:parcking_management/screen/signUp_screen.dart';
import '../config/palette.dart';
import 'chat_list_screen.dart';


class HomeScreen extends StatefulWidget {
  final String selectId;
  final String seatPass;

  const HomeScreen({
    required this.selectId,
    required this.seatPass,
    super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState(
      selectId: selectId,
    seatPass: seatPass,
  );
}

class _HomeScreenState extends State<HomeScreen> {
  User? loggedUser;
  bool disabled = false;
  bool electric = false;
  bool appointment = false;
  String? selectId; // 현재 로그인된 유저 아이디
  String? alreadyId;
  String selectParking ='';
  String selectSeat='';
  String seatPass;
  String state ='';
  bool checkIn =false;
  Timestamp? time;
  CollectionReference _referenceParking = FirebaseFirestore.instance.collection('parkingList');

  final _databaseReference = FirebaseDatabase.instance.reference();
  _HomeScreenState({
    required this.selectId,
    required this.seatPass,
});

  // 현재 로그인된 유저의 차량 정보 불러옴
  void getCurrentUser() async {
    try{
      final user = FirebaseAuth.instance.currentUser;
      if(user != null){
        loggedUser = user;
        final _userData = await FirebaseFirestore.instance
            .collection('user').doc(user.uid).get();
        setState(() {
          disabled = _userData.data()!['disabled'];
          electric = _userData.data()!['electric'];
          userData['carNum'] = _userData.data()!['carNum'];
          userData['disabled'] = disabled;
          userData['electric'] = electric;
          userData['userUid'] = user.uid.toString();
        });
      }
    }catch(e){
      print(e);
    };
  }

  // 현재 로그인된 유저가 선택하고 있는 주차자리 정보 불러옴
  void currentUserChoice() async {
      await FirebaseFirestore.instance
          .collection('parkingList').where('selectedId', isEqualTo: selectId)
          .get().then((value) {
            for(var snap in value.docs){
              setState(() {
                selectSeat = snap['parkId'];
                userData['userId'] = selectId;
                userData['selectSeat'] = selectSeat;
                seatPass = snap['seatPass'];
              });
              print('???????????$selectId');
              print('???????????$selectSeat');
            }
      });
  }

  // 현재 아이디가 주차를 하고있다면 bool checkIn = true -> 추가 UI 생성
  void checkState() async {
    await FirebaseFirestore.instance.collection('parkingList')
        .where('state', isEqualTo: 'selected').get().then((value) {
      for(var snap in value.docs){
        if(snap['selectedId'] == selectId){
          setState(() {
            checkIn = true;
          });
        }
      }
    });
  }

  // 현재 아이디가 주차를 하고있는 자리 정보 불러옴
  void checkParkingUsers() async {
    await FirebaseFirestore.instance
        .collection('appointment')
        .where('selectId', isEqualTo: selectId)
        .get().then((value) {
          for(var snap in value.docs){
            setState(() {
              selectSeat = snap['seat'];
              time = snap['time'];
              DateTime dt = DateTime.fromMicrosecondsSinceEpoch(time!.microsecondsSinceEpoch);
              userData['note'] = snap['note'];
              userData['selectDate'] = '${dt.year}년 ${dt.month}월 ${dt.day}일 ${dt.hour}시 ${dt.minute}분 ${dt.second}초';
              userData['seatPass'] = snap['seatPass'];
            });
          }
    });
  }

  // 모든 자리의 선택한 아이디의 정보를 불러옴
  void checkUserState() async{
    for(var parkId in parkingUserList.keys){
      await _referenceParking.where('parkId', isEqualTo: parkId)
          .get().then((value) {
            for(var snap in value.docs){
              setState(() {
                parkingUserList[parkId] = snap['selectedId'];
              });
            }
      });
    }
    print(parkingUserList);
  }

  //주차장 상태(possible / appoint / selected) 초기화
  void checkCurrentStatue() async{
    for(var parkId in parkingList.keys){
      await _referenceParking.where('parkId', isEqualTo: parkId)
          .get().then((value) {
        for(var snap in value.docs){
          if(snap['state'] == 'possible'){
           setState(() {
             parkingList[parkId] = 'possible';
           });
          } else if(snap['state'] == 'appoint') {
           setState(() {
             parkingList[parkId] = 'appoint';
           });
          } else {
            setState(() {
              parkingList[parkId] = 'selected';
            });
          }
        }
      });
    }
    print(parkingList);
  }

  @override
  void initState(){
    super.initState();
    getCurrentUser();
    checkCurrentStatue();
    currentUserChoice();
    checkParkingUsers();
    checkState();
    checkUserState();
    visitCheck();
    print('initState 완료');
  }
  // 초기 initState()에서 정의하는 함수
  void visitCheck() async {
    DataSnapshot _snaphot = await FirebaseDatabase.instance.ref().get();
    setState(() {
      // firebase realtime Database에 저장되어 있는 값을 map형태로 가져옴
     visitParkingList = _snaphot.value as Map<dynamic, dynamic>;
    });
    print(visitParkingList);

  }

  // 업데이트 될 때 작동되는 함수
  void onChangeVisit() async {
    _databaseReference.onValue.listen((event) { // 값이 변동 될 때 동작되는 함수
      setState(() {
        // firebase realtime Database에 저장되어 있는 값을 map형태로 가져옴
        visitParkingList = Map<String, dynamic>
            .from(event.snapshot.value as dynamic);
      });
    });
  }

  AppBar AppBarStyle(){
    return AppBar(
      backgroundColor: Colors.white10,
      title: Text('주차장 화면', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black45),),
      centerTitle: true,
      actions: [
        IconButton(onPressed: (){
          Navigator.push(context,
              MaterialPageRoute(builder: (context)
              {return ChatListScreen(currentId: selectId!,);}
              ));
        },
            icon: Icon(Icons.chat_outlined))
      ],

    );
 }
  @override
  Widget build(BuildContext context) {
    // 일단 지워둠
    onChangeVisit();
    return Scaffold(
      drawer: NavBar(userId: selectId!, uid: userData['userUid'], seatPass: seatPass,),
      appBar: AppBarStyle(),
      body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            child: Stack(
              children: [
                if(selectSeat != '')
                  Positioned(
                    top: 70,
                    right: MediaQuery.sizeOf(context).width-390,
                    child: TextButton(
                      onPressed: (){
                        //주차 정보 확인하는 dialog띄우기
                        infoCurrentPark();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                            )
                          ]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Center(child: Text('주차 정보 확인',
                            style: TextStyle(fontSize: 20, color: Colors.black87),),),
                        ),
                      ),
                    ),
                  ),
                Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 60,),
                    Text('입구', style: TextStyle(fontSize: 20.0),),
                    Icon(Icons.arrow_downward, size: 50.0,),
                    SizedBox(height: 45,),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Column(
                              children: [
                                // 일반
                                SizedBox(
                                  width: 150,
                                  height: 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: commonColor('aaaa1'),
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    child: TextButton(
                                        onPressed: () {
                                          selectParking = 'aaaa1';
                                          judgment(selectParking);
                                          print(selectParking);
                                        },
                                        child: possible('aaaa1')),
                                  ),
                                ),
                                SizedBox(height: 10.0,),
                                // 전기차
                                SizedBox(
                                  width: 150,
                                  height: 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: electricColor('cccc1'),
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    child: TextButton(
                                        onPressed: (){
                                          selectParking = 'cccc1';
                                          judgment(selectParking);
                                          print(selectParking);
                                        },
                                        child: possible('cccc1')),
                                  ),
                                ),
                                SizedBox(height: 10.0,),
                                // 장애인
                                SizedBox(
                                  width: 150,
                                  height: 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: disabledColor('bbbb1'),
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    child: TextButton(
                                        onPressed: (){
                                          selectParking = 'bbbb1';
                                          judgment(selectParking);
                                          print(selectParking);
                                        },
                                        child: possible('bbbb1')),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 60.0,),
                          Container(
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 150,
                                  height: 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: visitColor('carPresent1'),
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    child: TextButton(
                                        onPressed: (){
                                          selectParking = 'carPresent1';
                                          impossible(selectParking);
                                          print(selectParking);
                                          },
                                        child:possible('carPresent1'),),
                                  ),
                                ),
                                SizedBox(height: 10.0,),
                                SizedBox(
                                  width: 150,
                                  height: 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: visitColor('carPresent2'),
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    child: TextButton(
                                      onPressed: (){
                                        selectParking = 'carPresent2';
                                        impossible(selectParking);
                                        print(selectParking);
                                        },
                                      child:possible('carPresent2'),),
                                  ),
                                ),
                                SizedBox(height: 10.0,),
                                SizedBox(
                                  width: 150,
                                  height: 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: visitColor('carPresent3'),
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    child: TextButton(
                                      onPressed: (){
                                        selectParking = 'carPresent3';
                                        impossible(selectParking);
                                        print(selectParking);
                                      },
                                      child:possible('carPresent3'),),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),]
            ),
          ),
        ),
    );

  }

  // 주차 정보 확인하는 dialog
  void infoCurrentPark(){
    showDialog(context: context,
        builder: (BuildContext context){
      return Center(
        child: AlertDialog(
          title: Center(child: Text('주차 정보 확인', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),),
          content: SizedBox(
              height: MediaQuery.sizeOf(context).height-300,
              width: MediaQuery.sizeOf(context).width-100,
              child: SingleChildScrollView(
                child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Divider(color: Colors.indigo, thickness: 5,),
                        Text('예약한 주차 자리 비밀번호', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500, fontSize: 20),),
                        SizedBox(height: 10,),
                        Text('${userData['seatPass']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                        SizedBox(height: 20,),

                        Divider(color: Colors.indigo, thickness: 5,),
                        Text('등록된 자동차 정보', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500, fontSize: 20),),
                        SizedBox(height: 10,),
                        Text('자동차 번호: ${userData['carNum']}', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),),
                        SizedBox(height: 10,),
                        Text('전기차 유무: ${userData['electric'] == true ? 'O' : 'X'}', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),),
                        SizedBox(height: 10,),
                        Text('장애인 전용 유무: ${userData['disabled'] == true ? 'O' : 'X'}', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),),
                        SizedBox(height: 20,),

                        Divider(color: Colors.indigo, thickness: 5,),
                        Text('유저 아이디', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500, fontSize: 20),),
                        SizedBox(height: 10,),
                        Text('${userData['userId']}', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),),
                        SizedBox(height: 20,),

                        Divider(color: Colors.indigo, thickness: 5,),
                        Text('예약한 주차 자리', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500, fontSize: 20),),
                        SizedBox(height: 10,),
                        Text('${userData['selectSeat']}', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),),
                        SizedBox(height: 20,),

                        Divider(color: Colors.indigo, thickness: 5,),
                        Text('예약한 날짜', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500, fontSize: 20),),
                        SizedBox(height: 10,),
                        Text('${userData['selectDate']}', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),),
                        SizedBox(height: 20,),

                        Divider(color: Colors.indigo, thickness: 5,),
                        Text('부재중 시 남긴 메모', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500, fontSize: 20),),
                        SizedBox(height: 10,),
                        Text('${userData['note']}', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),),
                        SizedBox(height: 20,),
                        Divider(color: Colors.indigo, thickness: 5,),

                      ],
                    ),
                  ),
              ),
            ),
          actions: <Widget>[
            Center(
              child: TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('확인', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                  ),
                ),
              ),
            )
          ],
        ),
      );
        });
  }

  // 방문 차량 색깔
  visitColor(parkId){
    // 주차 가능
    if(visitParkingList[parkId] == true){
      return Colors.red;
    }
    else {
      return Colors.blueGrey;
    }
  }

  // 일반 차량 색깔
  commonColor(poss){
    if(parkingList[poss] == 'selected'
        && parkingUserList[poss] == selectId){
      return Colors.indigo;
    }
    else{
      return parkingList[poss] == 'selected'?
      Colors.red :
      parkingList[poss] == 'possible'?
      Colors.grey :
      selectSeat == poss?
      Colors.orange :
      Colors.amberAccent;
    }
  }

  // 전기차 색깔
  electricColor(poss) {
    if(parkingList[poss] == 'selected'
        && parkingUserList[poss] == selectId){
      return Colors.indigo;
   }
   else{
     return parkingList[poss] == 'selected'?
     Colors.red :
     parkingList[poss] == 'possible'?
     Colors.green:
     selectSeat == poss?
     Colors.orange :
     Colors.amberAccent;
   }
  }

  // 장애인 전용 색깔
  disabledColor(poss){
    if(parkingList[poss] == 'selected'
        && parkingUserList[poss] == selectId){
      return Colors.indigo;
    }
    else{
      return parkingList[poss] == 'selected'?
      Colors.red :
      parkingList[poss] == 'possible' ?
      Colors.lightBlueAccent:
      selectSeat == poss ?
      Colors.orange :
      Colors.amberAccent;
    }
  }
  
  // 주차장(일반/전기차/장애인/방문) state에 따른 주차장 텍스트 변화
  Widget possible(parkId) {
    // 일반 차량
    if (parkId.contains('aaaa')) {
      if(parkingList[parkId] == 'selected'
          && parkingUserList[parkId] == selectId){
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '일반 차량',
              style: TextStyle(fontSize: 20.0, color: Colors.black),
            ),
            Text(
              '(주차중)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.black),
            )
          ],
        );
      }
      else if(parkingList[parkId] == 'selected'
          && parkingUserList[parkId] != selectId){
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '일반 차량',
              style: TextStyle(fontSize: 20.0, color: Colors.black),
            ),
            Text(
              '(주차 불가)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.black),
            )
          ],
        );
      }
      else if(parkingList[parkId] == 'possible'){
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '일반 차량',
              style: TextStyle(fontSize: 20.0, color: Colors.black),
            ),
            Text(
              '(주차 가능)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.black),
            )
          ],
        );
      }
      else {
        return selectSeat == parkId ?
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '일반 차량',
              style: TextStyle(fontSize: 20.0, color: Colors.black),
            ),
            Text(
              '(현재유저 예약)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.black),
            )
          ],
        ):
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '일반 차량',
              style: TextStyle(fontSize: 20.0, color: Colors.black),
            ),
            Text(
              '(다른유저 예약)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.black),
            )
          ],
        );
      }
    }
    // 장애인 전용차량
    else if (parkId.contains('bbbb')) {
      if(parkingList[parkId] == 'selected'
          && parkingUserList[parkId] == selectId){
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '장애인 전용차량',
              style: TextStyle(fontSize: 20.0, color: Colors.black),
            ),
            Text(
              '(주차중)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.black),
            )
          ],
        );
      }
      else if((parkingList[parkId] == 'selected'
          && parkingUserList[parkId] != selectId) || disabled == false) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '장애인 전용차량',
              style: TextStyle(fontSize: 20.0, color: Colors.black),
            ),
            Text(
              '(주차 불가)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.black),
            )
          ],
        );
      }
      else if(parkingList[parkId] == 'possible'){
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '장애인 전용차량',
              style: TextStyle(fontSize: 20.0, color: Colors.black),
            ),
            Text(
              '(주차 가능)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.black),
            )
          ],
        );
      }
      else{
        return selectSeat == parkId?
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '장애인 전용차량',
              style: TextStyle(fontSize: 20.0, color: Colors.black),
            ),
            Text(
              '(현재유저 예약)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.black),
            )
          ],
        ):
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '장애인 전용차량',
              style: TextStyle(fontSize: 20.0, color: Colors.black),
            ),
            Text(
              '(다른유저 예약)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.black),
            )
          ],
        );
      }
    }
    // 전기차 전용
    else if(parkId.contains('cccc')) {
      if (parkingList[parkId] == 'selected'
          && parkingUserList[parkId] == selectId) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '전기차 전용',
              style: TextStyle(fontSize: 20.0, color: Colors.black),
            ),
            Text(
              '(주차중)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.black),
            )
          ],
        );
      }
      else if ((parkingList[parkId] == 'selected'
          && parkingUserList[parkId] != selectId) || electric == false) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '전기차 전용',
              style: TextStyle(fontSize: 20.0, color: Colors.black),
            ),
            Text(
              '(주차 불가)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.black),
            )
          ],
        );
      }
      else if (parkingList[parkId] == 'possible') {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '전기차 전용',
              style: TextStyle(fontSize: 20.0, color: Colors.black),
            ),
            Text(
              '(주차 가능)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.black),
            )
          ],
        );
      }
      else {
        return selectSeat == parkId ?
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '전기차 전용',
              style: TextStyle(fontSize: 20.0, color: Colors.black),
            ),
            Text(
              '(현재유저 예약)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.black),
            )
          ],
        ) :
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '전기차 전용',
              style: TextStyle(fontSize: 20.0, color: Colors.black),
            ),
            Text(
              '(다른유저 예약)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.black),
            )
          ],
        );
      }
    }
    // 방문 차량 -> 방문차량은 아두이노 센서를 통한 자동인식이므로
    // 어플에서는 주차를 예약할 수 없음
    else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '방문차량 전용',
              style: TextStyle(fontSize: 20.0, color: Colors.black),
            ),
            Text(
              '(주차 불가)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.black),
            )
          ],
        );
    }
  }

  // 예약이 불가능할 때 띄움
  void impossible(condition){
    // 전기차 전용 자리
    if(condition == 'electric'){
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('전기차 전용 자리입니다', style: TextStyle(color: Colors.black, fontSize: 15.0),),
        backgroundColor: Colors.red,));
    }
    // 장애인 전용 자리
    else if(condition == 'disabled'){
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('장애인 전용 차량 자리 입니다.', style: TextStyle(color: Colors.black, fontSize: 15.0),),
        backgroundColor: Colors.red,));
    }
    // 방문차량 전용 자리
    else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('방문 차량 전용 자리 입니다.', style: TextStyle(color: Colors.black, fontSize: 15.0),),
        backgroundColor: Colors.red,));
    }
  }

  // 다른 아이디가 예약한 자리를 클릭할 경우
  void appointMessage(){
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('예약된 자리입니다.', style: TextStyle(color: Colors.black, fontSize: 15.0),),
      backgroundColor: Colors.yellow,));
  }

  // 주차 예약 후 띄움
  // 현재 수동으로 클릭 -> 아두이노 키패드에 랜덤 번호를 입력하면 자동으로 완료되도록 변경해야함
  void checkInParking(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return Center(
            child: AlertDialog(
              title: Center(child: Text('주차 완료', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),),
              content: SizedBox(
                  width: 400,
                  height: 100,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('비밀번호를 입력하셨다면 하셨다면', style: TextStyle(fontSize: 18),),
                        Text('주차 완료 버튼을 눌러주세요', style: TextStyle(fontSize: 18),),
                        SizedBox(height: 15,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('비밀 번호: ', style: TextStyle(fontSize: 20),),
                            Text('${userData['seatPass']}', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),)
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              actions: <Widget>[
                TextButton(onPressed: (){
                  Navigator.of(context).pop();
                },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 5,
                              color: Colors.black.withOpacity(0.3),
                            )
                          ]
                      ),
                      child: Center(child: Text('취소',
                        style: TextStyle(fontSize: 20, color: Colors.white,),),),
                    )),
                TextButton(
                    onPressed: (){
                  //데베(parkingList, appointment 수정)
                  checkInUser();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context){
                    return HomeScreen(selectId: selectId!, seatPass: seatPass,);
                  }));
                  checkInMessage();
                }, 
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 5,
                            color: Colors.black.withOpacity(0.3),
                          )
                        ]
                      ),
                        child: Center(child: Text('주차 완료',
                          style: TextStyle(fontSize: 20,
                              fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),),)))
              ],
            ),
          );
        });
  }

  // 주차 자리 취소
  void checkOutParking() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: AlertDialog(
              title: Center(child: Text('출차', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),),
              content: SizedBox(
                height: 100,
                width: 400,
                child: SingleChildScrollView(
                  child: Center(child: Text('출차하시겠습니까?', style: TextStyle(fontSize: 20),)),
                ),
              ),
              actions: <Widget>[
                TextButton(onPressed: (){
                  Navigator.of(context).pop();
                },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(12,8,12,8),
                        child: Text('취소', style: TextStyle(color: Colors.white),),
                      ),
                    )),
                TextButton(onPressed: (){
                  checkOutUser();
                  Navigator.of(context).pop();
                  checkOutMessage();
                },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(12,8,12,8),
                        child: Text('출차 확인', style: TextStyle(color: Colors.white),),
                      ),
                    ))
              ],
            ),
          );
        });
  }
  // 주차 취소 snackBar
  void checkOutMessage() {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('출차 되셨습니다! 이용해 주셔서 감사합니다.',
      style: TextStyle(color: Colors.black, fontSize: 15.0),),
      backgroundColor: Colors.blueAccent,));
  }

  // 주차 취소 후 Firebase 업데이트
  void checkOutUser() async {
    var checkOutAppointment = FirebaseFirestore.instance
        .collection('appointment').doc(selectSeat);
    print(selectSeat);
    checkOutAppointment.delete();

    var checkOutParkingList = FirebaseFirestore.instance
        .collection('parkingList').doc(selectSeat);
    Map<String , dynamic> _update ={
      'selectedId' :'',
      'state' : 'possible',
    };
    checkOutParkingList.update(_update);
    checkCurrentStatue();
    setState(() {
      selectSeat ='';
      checkIn = false;
    });
  }

  // 예약 창으로 넘어감
  void possiblePark(selected){
    //선택 가능한 좌석일때
    Navigator.push(context,
        MaterialPageRoute(builder: (context){
          return AppointmentParkingScreen(
            selectId: selectId!,
            seat: selected,
          );
        }));
  }

  // 주차 자리 정보 확인
  void judgment(parkId) {
    if(parkId.contains('bbbb')){ // 장애인 전용 자리를 클릭했을 때
      if(parkingList[parkId] == 'selected'){
        if(parkingUserList[parkId] == selectId){
          checkOutParking();
        }else{
          alreadySelected(parkId);
        }
      } // 이미 선택된 자리일 때
      else if(parkingList[parkId] == 'appoint'){
        if(parkingUserList[parkId] == selectId){
          checkInParking();
        }else{
          appointMessage();
        }
      } // 예약 중인 상태일 떄
      else{
        if(disabled == true){
          possiblePark(parkId);
        } // 현재 로그인된 유저의 차량 조건이 맞을 경우
        else{
          print('XXXXXXXX');
          impossible('disabled');
        }
      }
    }
    else if(parkId.contains('cccc')){ // 전기 차량 전용 자리를 클릭했을 때
      if(parkingList[parkId] == 'selected'){
        if(parkingUserList[parkId] == selectId){
          checkOutParking();
        }else{
          alreadySelected(parkId);
        }
      } // 이미 선택된 자리일 때
      else if(parkingList[parkId] == 'appoint'){
        if(parkingUserList[parkId] == selectId){
          checkInParking();
        }else{
          appointMessage();
        }
      } // 예약 중인 상태일 떄
      else{
        if(electric == true){
          possiblePark(parkId);
        } // 현재 로그인된 유저의 차량 조건이 맞을 경우
        else{
          print('XXXXXXXX');
          impossible('electric');
        }
      }
    }
    else{  // 일반 주차장 자리일 때
      if(parkingList[parkId] == 'selected'){
        // 선택된 자리를 현재 아이디가 예약했을 때
        if(parkingUserList[parkId] == selectId){
          checkOutParking();
        }
        else{
          alreadySelected(parkId);
        }
      } // 이미 선택된 자리일 때
      else {
        if(parkingList[parkId] == 'appoint'){
          if(selectSeat == parkId){
            //예약한 유저가 로그인된 유저일 때
            checkInParking();
          } // 예약 중인 상태일 떄
          else {
            //누른 자리가 다른 사람이 예약 중일때
            appointMessage();
          }
        } // 예약 중인 상태일 떄
        else {
          possiblePark(parkId);
        } // 예약 가능할 때
      }
    }
  }

  // 주차 완료 후 Firebase 정보 수정
  void checkInUser() async {
    var checkInAppoint = await FirebaseFirestore.instance
        .collection('appointment').doc(selectSeat);
    Map<String, dynamic> _updateAppoint = {
      'state' : 'selected',
    };
    checkInAppoint.update(_updateAppoint);

    var checkInPark = await FirebaseFirestore.instance
        .collection('parkingList').doc(selectSeat);
    Map<String, dynamic> _updatePark = {
      'state' : 'selected',
    };
    checkInPark.update(_updatePark);
    checkCurrentStatue();
  }

  // 주차 완료 snackBar
  void checkInMessage() {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('주차 완료되셨습니다!.',
      style: TextStyle(color: Colors.black, fontSize: 15.0),),
      backgroundColor: Colors.blueAccent,));
  }

  Future<dynamic> searchUid(id) async {
    String? res;
    await FirebaseFirestore.instance
        .collection('user').where('userIDs', arrayContains: id)
        .get().then((value) {
          for(var snap in value.docs){
            res = snap['Uid'];
          }
    });
    return res;

  }
  //이미 선택된 자리 클릭 시 뜨는 dialog : 예약한 유저에게 채팅 보내기
  void alreadySelected(parkingId) async{
    final alreadySelected = await FirebaseFirestore.instance
        .collection('appointment')
        .doc(parkingId).get();
    alreadyId = alreadySelected.data()!['selectId'];
    var note = alreadySelected.data()!['note'];

    var sendUid = await searchUid(selectId);
    var rcvUid = await searchUid(alreadyId);
    print('이선좌 계정: ${alreadyId}');
    print('이미 선택된 자리입니다');
    print('보내는 사람 Uid: ${sendUid}');
    print('받는 사람 Uid: ${rcvUid}');
      //dialog
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return Center(
            child: StatefulBuilder(
                builder: (BuildContext context,
                    StateSetter setState){
                  return SingleChildScrollView(
                    child: AlertDialog(
                      title: Center(child: Text('${alreadyId} 에게 메세지 보내기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),),
                      content: SizedBox(
                        width: 300,
                        height: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('남긴 메모'),
                            SingleChildScrollView(
                              child: Container(
                                color: Colors.grey,
                                  height: 80,
                                  width: 250,
                                  child: Center(child: Text('$note', style: TextStyle(fontWeight: FontWeight.bold),))),
                            ),
                            Text('현재 주차 중인 유저는 ${alreadyId} 입니다.'),
                            Text('연락 하시겠습니까?')
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(onPressed: (){
                          Navigator.of(context).pop();
                        },
                          child: Text('취소'),),
                        TextButton(onPressed: (){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context){
                                //수정 중
                                return ChatScreen(
                                  sendUid: sendUid,
                                  sendid: selectId!,
                                  rcvUid: rcvUid,
                                  rcvid:  alreadyId!,
                                );
                              }));
                        },
                          child: Text('확인'),),
                      ],
                    ),
                  );
                }),
          );
        });
  }

}
