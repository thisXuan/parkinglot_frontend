import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/AccountManager/ForgetPassword.dart';
import 'package:parkinglot_frontend/AccountManager/Register.dart';
import 'package:parkinglot_frontend/Manager/ManageLocationPage.dart';
import 'package:parkinglot_frontend/Manager/ManagerTab.dart';
import 'package:parkinglot_frontend/api/user.dart';
import 'package:parkinglot_frontend/Tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parkinglot_frontend/utils/util.dart';

class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 定义控制器来获取输入框的内容
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    String phone = _usernameController.text;
    String password = _passwordController.text;
    if(phone.isEmpty||password.isEmpty){
      ElToast.info("手机号和密码不能为空");
      return;
    }
    dynamic data = {'phone': phone, 'password': password};

    setState(() {
      _isLoading=true;
    });

    var result;

    try {
      result = await UserApi().Login(data);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    if(result!=null){
      var code = result['code'];
      var msg = result['msg'];
      if (code == 200) {
        var token = result['data']['jwt'];
        var type = result['data']['type'];
        var userinfo = await UserApi().GetUserInfo(phone);
        var username = userinfo['data']['name'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        Map<String, String> userInfo = {
          'phone': phone,
          'token': token,
          'username':username,
          'type': type.toString()
        };
        // 将Map转换为JSON字符串
        String userJson = jsonEncode(userInfo);
        prefs.setString('user', userJson);
        if(type==0){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Tabs()),
          );
        }else{
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ManagerTab()),
          );
        }
      } else {
        ElToast.info(msg);
      }
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登录'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height),
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
                      labelText: "手机号",
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgetpasswordPage()),
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
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      _login();
                    },
                    child: Text("登录"),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("没有账号？"),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterPage()),
                          );
                        },
                        child: Text(
                          "立即注册",
                          style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
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