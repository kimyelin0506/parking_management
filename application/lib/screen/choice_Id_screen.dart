import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parcking_management/firebase_options.dart';
import 'package:parcking_management/screen/home_screen.dart';
import 'package:parcking_management/screen/login_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/userData.dart';


class ChoiceIdScreen extends StatefulWidget {
  const ChoiceIdScreen({super.key});

  @override
  State<ChoiceIdScreen> createState() => _ChoiceIdScreenState();
}

class _ChoiceIdScreenState extends State<ChoiceIdScreen> {
  CollectionReference _referenceUser = FirebaseFirestore.instance.collection('user');
  final String _userEmail = FirebaseAuth.instance.currentUser!.email.toString();
  String? selectId;
  String selectParking ='';
  List userIds =[];
  List choice =[];

  void stateUpdate() async {
    await _referenceUser.where('userEmail', isEqualTo: _userEmail).get().then((value) {
      for(var snap in value.docs){
        print('----userIds');
        for(var i in snap['userIDs']){
          print(i);
          setState(() {
            userIds.add(i);
            choice.add(false);
          });
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    stateUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 80,),
              Text('현재 차량이용 유저 선택',
                style: TextStyle(fontSize: 30,
                    fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(height: 40,),
              SingleChildScrollView(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        height: MediaQuery.sizeOf(context).height-250,
                        width: MediaQuery.sizeOf(context).width-100,
                        child: ListView.builder(
                                itemCount: userIds.length,
                                itemBuilder: (BuildContext context, int index){
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          for(int i=0; i<choice.length; i++){
                                            if(choice[i] == true){
                                              choice[i] = false;
                                            }
                                            setState(() {
                                              choice[index] = true;
                                              selectId = userIds[index];
                                            });
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                            choice[index] == true ?
                                            Colors.cyan :
                                            Colors.white54,
                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                            boxShadow: [
                                              BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 15,
                                              blurStyle: BlurStyle.inner,
                                              spreadRadius: 5,
                                            )]
                                          ),
                                          height: 80,
                                          width: 200,
                                          child: Center(
                                            child: Text('${userIds[index]}',
                                              style: TextStyle(fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 15,),
                                    ],
                                  );
                                }
                        ),
                      ),
                      SizedBox(height: 18,),
                      TextButton(
                          onPressed: (){
                        Navigator.push(context,
                            MaterialPageRoute(
                            builder: (context){
                          return HomeScreen(selectId: selectId!, seatPass: userData['seatPass'],);
                        }));
                      },
                          child: Center(
                            child: Text('선택 완료',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                              color: Colors.red
                              ),),
                          ))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
