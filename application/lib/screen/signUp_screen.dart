import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/palette.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String userName = '';
  List<String> userID= [];
  String userEmail = '';
  String userPassWord = '';
  String carNum = '';
  String insertId ='';
  bool showSpinner = false;
  bool addMoreUserId = false;
  int _addMoreIds =0;
  bool disabled = false;
  bool electric = false;
  final _authentication = FirebaseAuth.instance; //사용자의 등록/인증
  CollectionReference _reference = FirebaseFirestore.instance.collection('user');

  //form 이 유효한지 확인 -> 유효하면 null값 전달
  void _tryValidation() {
    final form = _formKey.currentState;
    if (form != null) {
      final isValid = form.validate();
      if (isValid) {
        form.save();
      }
    }
  }

  AppBar AppBarStyle(){
    return AppBar(
      title: Text('회원 가입', style: TextStyle(fontSize: 30, color: Colors.black45),),
      backgroundColor: Colors.white10,
      centerTitle: true,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarStyle(),
      body: Center(
          child: GestureDetector(
            onTap: (){
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.sizeOf(context).height,
                width: MediaQuery.sizeOf(context).width,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30,),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: 20.0,),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width - 40,
                            height: MediaQuery.sizeOf(context).height - 200,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white38,
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3), //투명도 조절
                                    blurRadius: 15.0,
                                    spreadRadius: 5.0,
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: EdgeInsets.all(20.0),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      //이름
                                      TextFormField(
                                        keyboardType: TextInputType.name,
                                        key: ValueKey(1),
                                        validator: (val) {
                                          if (val!.isEmpty) {
                                            return "이름을 입력해주세요";
                                          }
                                          return null;
                                        },
                                        onSaved: (val) {
                                          userName = val!;
                                        },
                                        onChanged: (val) {
                                          userName = val;
                                        },
                                        decoration: InputDecoration(
                                            hintText: '대표 가입자 이름', icon: Icon(Icons.person)),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      //아이디
                                      TextFormField(
                                        keyboardType: TextInputType.name,
                                        key: ValueKey(2),
                                        validator: (val) {
                                          if (val!.isEmpty) {
                                            return "아이디를 입력해주세요";
                                          }
                                          return null;
                                        },
                                        onSaved: (val) {
                                          insertId = val!;
                                          userID.add(insertId);
                                          print(userID);
                                        },
                                        onChanged: (val) {
                                          insertId = val;
                                        },
                                        decoration: InputDecoration(
                                            hintText: '아이디',
                                            icon: Icon(
                                                Icons.perm_contact_calendar_rounded)),
                                      ),
                                      //아이디 추가
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (BuildContext context) {
                                                    _addMoreIds += 1;
                                                    return SingleChildScrollView(
                                                      child: AlertDialog(
                                                        title: Text('계정 아이디 추가하기'),
                                                        content: SizedBox(
                                                            width: MediaQuery.sizeOf(
                                                                context)
                                                                .width -
                                                                100,
                                                            height: MediaQuery.sizeOf(
                                                                context)
                                                                .height -
                                                                600,
                                                            child: TextFormField(
                                                              keyboardType:
                                                              TextInputType.name,
                                                              key: ValueKey(6),
                                                              validator: (val) {
                                                                if (val!.isEmpty)
                                                                  return '추가 아이디를 입력해 주세요';
                                                                return null;
                                                              },
                                                              onSaved: (val) {
                                                                insertId = val!;
                                                              },
                                                              onChanged: (val) {
                                                                insertId = val;
                                                              },
                                                              decoration:
                                                              InputDecoration(
                                                                  hintText:
                                                                  '추가 아이디'),
                                                            )),
                                                        actions: <Widget>[
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.of(context)
                                                                    .pop();
                                                                print(_addMoreIds);
                                                                print(insertId);
                                                                userID.add(insertId);
                                                                print(userID);
                                                              },
                                                              child: Text('저장하기'))
                                                        ],
                                                      ),
                                                    );
                                                  });
                                            });
                                          },
                                          icon: Icon(Icons.add)),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      //이메일
                                      TextFormField(
                                        keyboardType: TextInputType.emailAddress,
                                        key: ValueKey(3),
                                        validator: (val) {
                                          if (val!.isEmpty || !val.contains('@')) {
                                            return "이메일의 형식으로 입력해주세요.";
                                          }
                                          return null;
                                        },
                                        onSaved: (val) {
                                          userEmail = val!;
                                        },
                                        onChanged: (val) {
                                          userEmail = val;
                                        },
                                        decoration: InputDecoration(
                                          hintText: '대표 이메일',
                                          icon: Icon(Icons.email_outlined),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      //비밀 번호
                                      TextFormField(
                                        keyboardType: TextInputType.name,
                                        key: ValueKey(4),
                                        validator: (val) {
                                          if (val!.isEmpty || val.length < 6) {
                                            return "비밀번호는 최소 6글자 이상이여야합니다.";
                                          }
                                          return null;
                                        },
                                        onSaved: (val) {
                                          userPassWord = val!;
                                        },
                                        onChanged: (val) {
                                          userPassWord = val;
                                        },
                                        decoration: InputDecoration(
                                          hintText: '비밀번호',
                                          icon: Icon(Icons.lock_outline),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      //차량 번호
                                      TextFormField(
                                        keyboardType: TextInputType.name,
                                        key: ValueKey(5),
                                        validator: (val) {
                                          if (val!.isEmpty) {
                                            return "차량번호를 입력해주세요";
                                          }
                                          return null;
                                        },
                                        onSaved: (val) {
                                          carNum = val!;
                                        },
                                        onChanged: (val) {
                                          carNum = val;
                                        },
                                        decoration: InputDecoration(
                                          hintText: '차량 번호',
                                          icon: Icon(Icons.car_crash_outlined),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      //장애인 차량 인증 체크 박스
                                      Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: Row(
                                            children: [
                                              Checkbox(
                                                  value: disabled,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      disabled = val!;
                                                    });
                                                  }),
                                              Text(
                                                '장애인 차량 등록하기',
                                                style: TextStyle(fontSize: 15.0),
                                              ),
                                            ],
                                          )),
                                      //체크박스 true
                                      //if (disabled)
                                       /* Column(
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(left: 10.0),
                                                  child: IconButton(
                                                    onPressed: () {},
                                                    icon: Icon(Icons.image_search),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(5.0),
                                                  child: Text(
                                                      '장애인 증명 서류(장애인 복지카드, 증명서 등)'),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 1.0,
                                            ),
                                            Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(left: 10.0),
                                                  child: IconButton(
                                                    onPressed: () {},
                                                    icon: Icon(Icons.image_search),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(5.0),
                                                  child: Text('본인 인증 서류(주민등록 사진)'),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 15.0,
                                            ),
                                          ],
                                        ),
                                       * */
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      //전기차 인증 체크 박스
                                      Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: Row(
                                            children: [
                                              Checkbox(
                                                  value: electric,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      electric = val!;
                                                    });
                                                  }),
                                              Text(
                                                '전기차 등록하기',
                                                style: TextStyle(fontSize: 15.0),
                                              ),
                                            ],
                                          )),
                                      //확인 버튼
                                      SizedBox(
                                        width: 50,
                                        height: 40,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black45,
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          child: TextButton(
                                              onPressed: () async {
                                                setState(() {
                                                  showSpinner = true;
                                                });
                                                _tryValidation();
                                                try {
                                                  final newUser = await _authentication
                                                      .createUserWithEmailAndPassword(
                                                      email: userEmail,
                                                      password: userPassWord);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    content:
                                                    Text('가입 되셨습니다! 로그인을 진행해 주세요.'),
                                                    backgroundColor: Colors.blueAccent,
                                                  ));
                                                  await _reference
                                                      .doc(newUser.user!.uid)
                                                      .set({
                                                    'Uid': newUser.user!.uid,
                                                    'userName': userName,
                                                    'userEmail': userEmail,
                                                    'userIDs':
                                                    FieldValue.arrayUnion(userID),
                                                    'userPass': userPassWord,
                                                    'carNum': carNum,
                                                    'disabled': disabled,
                                                    'electric': electric,
                                                    'profileUrl' : ''
                                                  });
                                                  setState(() {
                                                    showSpinner = false;
                                                  });
                                                  Navigator.of(context).pop();
                                                } catch (e) {
                                                  print('error ??????? ');
                                                  print(e);
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(SnackBar(
                                                      content:
                                                      Text('가입 양식을 다시 확인해 주세요.'),
                                                      backgroundColor: Colors.red,
                                                    ));
                                                  }
                                                  setState(() {
                                                    showSpinner = false;
                                                  });
                                                }
                                              },
                                              child: Text(
                                                '확인',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold),
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
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
        ),
    );
  }
}
