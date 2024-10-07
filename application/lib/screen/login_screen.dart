import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parcking_management/screen/choice_Id_screen.dart';
import 'package:parcking_management/screen/home_screen.dart';
import 'package:parcking_management/screen/signUp_screen.dart';
import '../config/palette.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //login or signUp
  bool isSignUpScreen = true;

  final _formKey = GlobalKey<FormState>(); //form키에서 사용하는 전역키
  String userEmail = '';
  String userPassWord = '';
  final _authentication = FirebaseAuth.instance; //사용자의 등록/인증
  bool showSpinner = false;
  bool _loginStatus = false;

  //form 이 유효한지 확인 -> 유효하면 null값 전달
  void _tryValidation() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: GestureDetector(
        // 다른 화면 누르면 키보드 내려가는 기능
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(children: [
            SizedBox(
              height: 80,
            ),
            Container(
              child: Column(
                children: [
                  Text('찾았다',
                      style: TextStyle(
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.bold,
                        color: Palette.textColorMain,
                        fontSize: 80,
                      )),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text('주차 관리 서비스 어플',
                      style: TextStyle(
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.normal,
                        color: Palette.textColorServe,
                        fontSize: 30,
                      )),
                  SizedBox(
                    height: 40.0,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Container(
              width: MediaQuery.sizeOf(context).width -40,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '로그인',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Palette.textColor1,
                        fontSize: 30,
                      ),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      key: ValueKey(1),
                      validator: (value) {
                        if (value!.isEmpty || value.length < 4) {
                          return '4글자 이상 입력해 주세요';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        userEmail = value!;
                      },
                      onChanged: (value) {
                        userEmail = value;
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Palette.textColor1,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(35.0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Palette.textColor1,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(35.0),
                          ),
                        ),
                        hintText: '이메일을 입력해 주세요',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Palette.textColor1,
                        ),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      obscureText: true,
                      key: ValueKey(2),
                      validator: (value) {
                        if (value!.isEmpty || value.length < 6) {
                          return '비밀번호는 최소 6글자 이상이여야 합니다.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        userPassWord = value!;
                      },
                      onChanged: (value) {
                        userPassWord = value;
                      },
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock_outline,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Palette.textColor1,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(35.0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Palette.textColor1,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(35.0),
                            ),
                          ),
                          hintText: '비밀번호를 입력해 주세요.',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Palette.textColor1,
                          ),
                          contentPadding: EdgeInsets.all(10)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.0,),
            AnimatedPositioned(
              child: Center(
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      showSpinner = true;
                    });
                    if (isSignUpScreen) {
                      _tryValidation();
                      try{
                        final newUser =
                            await _authentication.signInWithEmailAndPassword(
                                email: userEmail,
                                password: userPassWord,);
                        if (newUser.user != null){
                          _loginStatus = true;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context){
                                    return ChoiceIdScreen();
                                   // return HomeScreen(selectId: selectId!);
                                  }));
                        setState(() {
                          showSpinner = false;
                        });
                        }
                      }catch(e){
                        print('error ???? ');
                        print(e);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('등록되지 않은 회원입니다.')));
                       setState(() {
                         showSpinner = false;
                       });
                      }
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(0, 1))
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              duration: Duration(milliseconds: 500),
              curve: Curves.easeIn,
            ),
            SizedBox(height: 100,),
            Text('계정이 없으신가요?',
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.normal,
                color: Colors.black45,
              ),
            ),
            SizedBox(height: 8.0,),
            AnimatedPositioned(
              child: Center(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (builder){
                          return SignUpScreen();
                        })
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: Offset(0, 1))
                        ],
                      ),
                      child: Text('   회원가입으로 시작하기   ',
                        style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 20.0
                        ),),
                    ),
                  )
              ),
              duration: Duration(milliseconds: 500),
              curve: Curves.easeIn,
            ),
          ],
          ),
        ),
      ),
    );
  }
}
