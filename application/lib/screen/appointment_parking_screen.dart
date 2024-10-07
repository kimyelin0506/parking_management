import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parcking_management/config/userData.dart';
import 'package:parcking_management/screen/home_screen.dart';
import '../config/palette.dart';


class AppointmentParkingScreen extends StatefulWidget {
 // final String selectParking;
  final String selectId;
  final String seat;

  const AppointmentParkingScreen({
    //required this.selectParking,
      required this.selectId,
      required this.seat,
      Key? key})
      : super(key: key);

  @override
  State<AppointmentParkingScreen> createState() =>
      _AppointmentParkingScreenState(
        selectId: selectId,
          //selectParking: selectParking,
          seat: seat,
      );
}

class _AppointmentParkingScreenState extends State<AppointmentParkingScreen> {
  //String selectParking;
  String selectId;
  String seat;
  String? seatPass;
  var _enterMessage ='';
  final _controller = TextEditingController();


  _AppointmentParkingScreenState({
    //required this.selectParking,
    required this.selectId,
    required this.seat,
  });

  void leaveNote() async{
    FocusScope.of(context).unfocus();
    await FirebaseFirestore.instance.collection('appointment').doc(seat)
        .set({
      'note' : _enterMessage,
      'time' : Timestamp.now(),
      'selectId' : selectId,
      'seat' : seat,
      'state' : 'appoint',
      'seatPass' : seatPass,
    });
    _controller.clear();
  }

  AppBar AppBarStyle(){
    return AppBar(
      title: Text('주차장 예약하기'),
      centerTitle: true,
      backgroundColor: Colors.white10,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    temporaryNum();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarStyle(),
      body: Container(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 80,),
                Container(
                  height: MediaQuery.of(context).size.height-300,
                  width: MediaQuery.of(context).size.width-100,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3), //투명도
                        blurRadius: 15,
                        spreadRadius: 5,
                        blurStyle: BlurStyle.outer
                      )
                    ]
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      maxLines: 20,
                      maxLength: 500,
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: '부재 시 남길 메세지 작성',
                        labelStyle: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                      style: TextStyle(fontSize: 20.0, color: Colors.black),
                      onChanged: (value){
                        setState(() {
                          _enterMessage = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20.0,),
                TextButton(
                    onPressed: () {
                      // 괄호가 있다면 메소드가 실행된다는 의미이며 값이 리턴된다는 의미임
                      // 반대의 경우 위치를 참조하는 것임
                      _enterMessage.trim().isEmpty ? null : leaveNote(); successAppointment();
                    },
                    child: Text('메모 남기기',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void temporaryNum() {
    if(seat == 'aaaa1'){
      seatPass = '1234';
      userData['seatPass'] = seatPass;
    }
    else if(seat == 'bbbb1'){
      seatPass = '2345';
      userData['seatPass'] = seatPass;
    }
    else {
      seatPass = '3456';
      userData['seatPass'] = seatPass;
    }
  }

  void successAppointment() async {
    String note='';
    Timestamp? time;
    await FirebaseFirestore
        .instance.collection('appointment')
        .where('selectId', isEqualTo: selectId)
        .get().then((value) {
      for(var snap in value.docs){
        time = snap['time'];
        note = snap['note'];
      }
    });
    DateTime dt = DateTime.fromMicrosecondsSinceEpoch(time!.microsecondsSinceEpoch);

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: AlertDialog(
              title: Center(child: Text('예약 성공', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),)),
              content:Container(
                  height: MediaQuery.of(context).size.height-300,
                  width: MediaQuery.of(context).size.width-100,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 20,),
                            Text('주차 자리 비밀번호',style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Container(
                              width: 300,
                              decoration: BoxDecoration(
                                color: Colors.amberAccent,
                              ),
                              child: Center(child: Text('${seatPass}',style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),)),
                            ),
                            SizedBox(height: 20,),
                            Text('예약한 유저',style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Container(
                              width: 300,
                             decoration: BoxDecoration(
                                  color: Colors.amberAccent,
                                 ),
                              child: Center(child: Text('${selectId}', style: TextStyle(fontSize: 20),)),
                            ),
                            SizedBox(height: 20,),
                            Text('주차 예약 시간',style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Container(
                              width: 300,
                            decoration: BoxDecoration(
                                  color: Colors.amberAccent,
                                ),
                              child: Center(child: Text('${dt.year}년 ${dt.month}월 ${dt.day}일 ${dt.hour}시 ${dt.minute}분 ${dt.second}초',style: TextStyle(fontSize: 20),)),
                            ),
                            SizedBox(height: 20,),
                            Text('부재시 남길 메모',style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Container(
                              width: 300,
                             decoration: BoxDecoration(
                                  color: Colors.amberAccent,
                                 ),
                              child: Center(child: Text('${note}',style: TextStyle(fontSize: 20),)),
                            ),
                            SizedBox(height: 20,),
                            Text('*주의: 예약 후 15분안으로 주차 완료해주셔야합니다.*',style: TextStyle(fontSize: 13),),
                            SizedBox(height: 10,),
                            Text('*15분이 지나면 자동으로 예약취소 처리됩니다.*',style: TextStyle(fontSize: 13),),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              actions: <Widget>[
                TextButton(onPressed: (){
                  updateParkingList();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context)
                      {return HomeScreen(
                        selectId: selectId,
                        seatPass: seatPass!,
                      );}));
                },
                    child: Text('확인'))
              ],
            ),
          );
        });
  }

  void updateParkingList() async {
    logUserAppoint();
    var parking = FirebaseFirestore.instance
        .collection('parkingList').doc(seat);
    Map<String, dynamic> _update = {
      'state': 'appoint',
      'selectedId': selectId};
    parking.update(_update);
    print('update 완료');
  }

  void logUserAppoint() async {
    await FirebaseFirestore.instance.collection('appointment')
        .where('selectId', isEqualTo: selectId)
        .get().then((value) {
      for(var snap in value.docs){
        setState(() {
          selectId = snap['selectId'];
          seat = snap['seat'];
        });
      }
    });
    print('?????????????$selectId');
    print('?????????????????$seat');
  }

}
