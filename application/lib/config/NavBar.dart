import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parcking_management/config/setting.dart';
import 'package:parcking_management/config/userData.dart';
import 'package:parcking_management/screen/login_screen.dart';
import '../screen/home_screen.dart';
import 'dart:developer';

import 'account.dart';


class NavBar extends StatefulWidget {
  final String uid;
  final String userId;
  final String seatPass;
  const NavBar({
    required this.uid,
    required this.userId,
    required this.seatPass,
    Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState(
    userUid: uid,
    userId: userId,
    seatPass: seatPass,
  );
}

class _NavBarState extends State<NavBar> {
  String? userUid;
  String? userId;
  List userIds =[];
  List userIdsChoice =[];
  String? changeId;
  String? userEmail;
  String seatPass;
  bool? electric;
  bool? disabled;
  String? carNum;
  _NavBarState({
    required this.userUid,
    required this.userId,
    required this.seatPass,
});

  void getUserData() async {
    setState(() {
      electric = userData['electric'];
      disabled = userData['disabled'];
      carNum = userData['carNum'];
    });
    await FirebaseFirestore.instance.collection('user')
        .where('Uid', isEqualTo: userUid)
        .get().then((value) {
          for(var snap in value.docs){
            setState(() {
              userEmail = snap['userEmail'];
              electric = snap['electric'];
              disabled = snap['disabled'];
              carNum = snap['carNum'];
            });
            for(var ids in snap['userIDs']){
              setState(() {
                userIds.add(ids);
                print('userId: $userId');
                if(userId == ids){
                  userIdsChoice.add(true);
                }
                else{
                  userIdsChoice.add(false);
                }
              });
            }
          }

    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    print('initState 완료 2');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
              accountName: Text('$userId'),
              accountEmail: Text('$userEmail'),
          currentAccountPicture: CircleAvatar(
            backgroundImage: AssetImage('asset/image/profile.png'),
          ),
            decoration: BoxDecoration(
              color: Colors.grey,
            ),
          ),
         ListTile(
            leading: Icon(Icons.home_filled),
            title: Text('Home'),
            onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(builder:
                      (context) => HomeScreen(selectId: userId!, seatPass: userData['seatPass'],)));
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('사용자 정보 수정'),
            onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                    return Account(userId: userId!, uId: userUid!,);
                  }));
            },
          ),
    // 앱 설정
    /*     ListTile(
            leading: Icon(Icons.settings),
            title: Text('앱 설정'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder:
                      (context) => Setting()));
            },
          ),
    * */
          ListTile(
            leading: Icon(Icons.change_circle),
            title: Text('로그인 아이디 변경'),
            onTap: (){
              showChangeIdDialog();
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('계정 로그아웃'),
            onTap: () {
              showLogOutCheckDialog();
            },
          ),
        ],
      ),
    );
  }
  void showChangeIdDialog() {
    print('$userIds');
    print('$userIdsChoice');
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState){
        return Center(
          child: AlertDialog(
            title: Center(child: Text('로그인 계정 바꾸기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),),
            content: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height-400,
                width: MediaQuery.sizeOf(context).width-200,
                child: ListView.builder(
                    itemCount: userIds.length,
                    itemBuilder: (BuildContext context, int index){
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 15,),
                          GestureDetector(
                            onTap: (){
                              for(int i=0; i<userIds.length; i++){
                                if(userIdsChoice[i] == true){
                                  userIdsChoice[i] = false;
                                }
                                    setState(() {
                                      userIdsChoice[index] = true;
                                      changeId = userIds[index];
                                    });
                                  }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: userIdsChoice[index]?
                                Colors.indigo : Colors.grey,
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 15,
                                    blurStyle: BlurStyle.inner,
                                    spreadRadius: 6,
                                  )
                                ]
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Center(
                                  child: Text('${userIds[index]}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15,),
                        ],
                      );
                    }),
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: (){
                Navigator.of(context).pop();
              },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.grey,
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8,5,8,5),
                      child: Text('취소', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),),
                    ),
                  )),
              TextButton(onPressed: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context)
                    {return HomeScreen(selectId: changeId!, seatPass: seatPass,);
                    }
                    ));
              },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8,5,8,5),
                      child: Text('확인', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),),
                    ),
                  ))
            ],
          ),
        );
      });
        });
  }
  void showLogOutCheckDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
      return Center(
        child: AlertDialog(
          title: Center(child: Text('로그아웃 하기',
            style: TextStyle(fontWeight: FontWeight.bold,
                fontSize: 30),),),
          content: SizedBox(
            height: MediaQuery.of(context).size.height - 600,
            width: MediaQuery.of(context).size.width - 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('로그아웃 하시겠습니까?', style: TextStyle(fontSize: 20),),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(onPressed: (){
              Navigator.of(context).pop();
            },
                child: Text('취소', style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w300),)),
            ElevatedButton(onPressed: (){
              FirebaseAuth.instance.signOut();
              Navigator.push(context,
              MaterialPageRoute(builder: (context){
                return LoginScreen();
              })
              );
            },
                child: Text('확인', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),))
          ],
        ),
      );
        });
  }
}
