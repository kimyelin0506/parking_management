import 'package:flutter/material.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.sizeOf(context).height -10,
          width: MediaQuery.sizeOf(context).width -10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(Icons.add_box_outlined, color: Colors.black12,),
                title: Text('계정 아이디 추가'),
                onTap: (){

                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.black12,),
                title: Text('계정 아니디 삭제'),
                onTap: (){

                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
