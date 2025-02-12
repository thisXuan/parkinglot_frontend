import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/RegisterAndLogin/ForgetPassword.dart';
import 'package:parkinglot_frontend/RegisterAndLogin/Register.dart';
import 'package:parkinglot_frontend/api/user.dart';
import 'package:parkinglot_frontend/mainPages/Tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parkinglot_frontend/utils/util.dart';

class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 定义控制器来获取输入框的内容
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    dynamic data = {'name': username, 'password': password};

    var result = await UserApi().Login(data);
    if(result!=null){
      var code = result['code'];
      var message = result['data'];
      if (code == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        Map<String, String> userInfo = {
          'username': username,
          'token': message,
        };
        // 将Map转换为JSON字符串
        String userJson = jsonEncode(userInfo);
        prefs.setString('user', userJson);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Tabs()),
        );
      } else {
        showInfoDialog(context,message.toString());
      }
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登录'),
      ),
      body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ParkLocation',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "用户名",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "密码",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ForgetpasswordPage()),
                      );
                    },
                    child: Text(
                      '忘记密码？',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15,),
                ElevatedButton(
                    onPressed: (){
                      _login();
                    },
                    child: Text("登录")
                ),
                SizedBox(
                    height: 30
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("没有账号？"),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        );
                      },
                      child: Text(
                        "立即注册",
                        style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}