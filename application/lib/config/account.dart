import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Account extends StatefulWidget {
  final String userId;
  final String uId;

  const Account({
    required this.userId,
    required this.uId,
    super.key});

  @override
  State<Account> createState() => _AccountState(
    userId: userId,
    uId: uId,
  );
}

class _AccountState extends State<Account> {
  final String uId;
  final String userId;
  final _formKey = GlobalKey<FormState>();
  final _authentication = FirebaseAuth.instance;
  CollectionReference _reference = FirebaseFirestore.instance.collection('user');
  final _controller = TextEditingController();
  var _addIds ='';


  String? userName;
  String? userEmail;
  String? pass;
  bool? disabled;
  bool? electric;
  List<String> userIDs=[];
  List<String> changeIDs=[];
  List<String> delIds=[];
  List<String> addIds=[];
  String? carNum;
  String? profileUrl;


  _AccountState({
    required this.uId,
    required this.userId,
});

  void _tryValidation(){
    final form = _formKey.currentState;
    if (form != null) {
      final isValid = form.validate();
      if (isValid) {
        form.save();
      }
    }
  }

  void getUserData() async {
    await FirebaseFirestore.instance.collection('user')
        .where('Uid', isEqualTo: uId)
        .get().then((value) {
      setState(() {
        for(var snap in value.docs){
          userName = snap['userName'];
          userEmail = snap['userEmail'];
          pass = snap['userPass'];
          carNum = snap['carNum'];
          disabled = snap['disabled'];
          electric = snap['electric'];
          profileUrl = snap['profileUrl'];
          for(var i in snap['userIDs']){
            userIDs.add(i);
          }
        }
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
    print(userName);
    print('---initState---');
  }

  AppBar AppBarStyle(){
    return AppBar(
      title: Text('사용자 정보 수정'),
      centerTitle: true,
      backgroundColor: Colors.white10,
    );
  }


  void addUserIDs(){

    showDialog(context: context,  builder: (BuildContext context){
      return Center(
        child: AlertDialog(
          title: Text('멀티 계정 추가하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
          content: SizedBox(
            height: 100,
            width: MediaQuery.sizeOf(context).width-100,
            child: Center(
              child: TextField(
                keyboardType: TextInputType.name,
                controller: _controller,
                onChanged: (val) {
                  setState(() {
                 _addIds = val;
                  });
                },
                decoration:
                InputDecoration(
                    hintText:
                    '추가 아이디'),
              ),
              ),
            ),
          actions: [
              TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Container(
                  color: Colors.grey,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 8,10, 8),
                    child: Text('취소', style: TextStyle(color: Colors.black45, fontSize: 20),),
                  ),
                ),
              ),
            TextButton(
              onPressed: (){
                _addIds.trim().isEmpty? null: _newIds();
                Navigator.of(context).pop();
              },
              child: Container(
                color: Colors.blueAccent,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 8,10, 8),
                  child: Text('추가', style: TextStyle(color: Colors.white, fontSize: 20),),
                ),
              ),
            ),

          ],
          ),
        );
    });
  }

  void _newIds() {
    setState(() {
      addIds.add(_addIds);
      userIDs.add(_addIds);
      _controller.clear();
    });
  }

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBarStyle(),
        body: Container(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 20,),
                    Text('*수정 할 정보만 입력해주세요.*', style: TextStyle(color: Colors.green, fontSize: 15),),
                    SizedBox(height: 10,),
                    SingleChildScrollView(
                      child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 이름 수정
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  key: ValueKey(1),
                                  keyboardType: TextInputType.name,
                                  validator: (value){
                                    if(value!.isEmpty){
                                      return userName;
                                    }
                                    return null;
                                  },
                                  onChanged: (value){
                                    userName = value;
                                  },
                                  onSaved: (value){
                                    userName = value;
                                  },
                                  decoration: InputDecoration(
                                    labelStyle: TextStyle(color: Colors.lightBlueAccent),
                                    labelText: '대표 가입자 이름 수정', icon: Icon(Icons.person, color: Colors.lightBlueAccent,),
                                    hintStyle: TextStyle(color: Colors.black45),
                                    hintText: '$userName',
                                  ),
                                ),
                              ),
                              // 아이디 수정
                              Text('멀티 프로필 수정', style: TextStyle(
                                  fontSize: 15, color: Colors.lightBlueAccent),),
                              Container(
                                height: 300,
                                width: 400,
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                child: ListView.builder(
                                    itemCount: userIDs.length,
                                    itemBuilder: (context, index){
                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(15, 8, 8, 8),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                IconButton(
                                                  onPressed: (){
                                                    setState(() {
                                                      delIds.add(userIDs[index]);
                                                      userIDs.remove(userIDs[index]);
                                                      print('----');
                                                      print(delIds);
                                                      print('----');
                                                      print(userIDs);
                                                    });
                                                  },
                                                  icon: Icon(Icons.delete_outline),
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 10,),
                                                Text('${userIDs[index]}', style: TextStyle(color: Colors.black45,),),
                                              ],
                                            ),
                                            Divider(),
                                          ],
                                        )
                                      );
                                    }),
                              ),
                              IconButton(onPressed: (){
                                addUserIDs();
                              },
                                  icon: Icon(Icons.add_box_outlined, color: Colors.black,)),
                              // 이메일 수정
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  key: ValueKey(2),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value){
                                    if(value!.isEmpty){
                                      return userEmail;
                                    }
                                    return null;
                                  },
                                  onChanged: (value){
                                    userEmail = value;
                                  },
                                  onSaved: (value){
                                    userEmail = value;
                                  },
                                  decoration: InputDecoration(
                                    labelStyle: TextStyle(color: Colors.lightBlueAccent),
                                    labelText: '대표 이메일 수정', icon: Icon(
                                    Icons.email_outlined, color: Colors.lightBlueAccent,),
                                    hintStyle: TextStyle(color: Colors.black45),
                                    hintText: '$userEmail',
                                  ),
                                ),
                              ),
                              // 비밀 번호 수정
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  key: ValueKey(3),
                                  keyboardType: TextInputType.visiblePassword,
                                  validator: (value){
                                    if(value!.isEmpty){
                                      return pass;
                                    }
                                    return null;
                                  },
                                  onChanged: (value){
                                    pass = value;
                                  },
                                  onSaved: (value){
                                    pass = value;
                                  },
                                  decoration: InputDecoration(
                                    labelStyle: TextStyle(color: Colors.lightBlueAccent),
                                    labelText: '비밀 번호 수정',
                                    icon: Icon(Icons.lock_outline,
                                      color: Colors.lightBlueAccent,),
                                    hintStyle: TextStyle(color: Colors.black45),
                                    hintText: '$pass',
                                  ),
                                ),
                              ),
                              // 차량 번호
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  key: ValueKey(4),
                                  keyboardType: TextInputType.name,
                                  validator: (value){
                                    if(value!.isEmpty){
                                      return carNum;
                                    }
                                    return null;
                                  },
                                  onChanged: (value){
                                    carNum = value;
                                  },
                                  onSaved: (value){
                                    carNum = value;
                                  },
                                  decoration: InputDecoration(
                                    labelStyle: TextStyle(color: Colors.lightBlueAccent),
                                    labelText: '차량 번호 수정',
                                    icon: Icon(Icons.car_crash_outlined,
                                      color: Colors.lightBlueAccent,),
                                    hintStyle: TextStyle(color: Colors.black45),
                                    hintText: '$carNum',
                                  ),
                                ),
                              ),
                              // profileUrl

                              // 장애인 차량 인증 체크박스
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
                              // 전기차 체크박스
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
                              // 수정 확인 버튼
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
                                        _tryValidation();
                                        print(userIDs);
                                        try {
                                          Map <String, dynamic> _new = {
                                            'userName': userName,
                                            'userEmail': userEmail,
                                            'userPass': pass,
                                            'carNum': carNum,
                                            'disabled': disabled,
                                            'electric': electric,
                                            'profileUrl' : profileUrl
                                          };
                                          await _reference.doc(uId).update(_new);
                                          await _reference.doc(uId).update({
                                            'userIDs': FieldValue.arrayRemove(delIds),
                                          });
                                          await _reference.doc(uId).update({
                                            'userIDs': FieldValue.arrayUnion(addIds),
                                          });
                                          await _reference.doc(uId).update({
                                            'userIDs': FieldValue.arrayRemove(changeIDs),
                                          });

                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content:
                                            Text('회원 정보를 수정하였습니다!'),
                                            backgroundColor: Colors.blueAccent,
                                          ));
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content:
                                              Text('가입 양식을 다시 확인해 주세요.'),
                                              backgroundColor: Colors.red,
                                            ));
                                          }
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
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
}
