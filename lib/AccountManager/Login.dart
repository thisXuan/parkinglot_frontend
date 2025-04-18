import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
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
  bool _isAgreedToTerms = false;  // 添加协议同意状态变量

  void _login() async {
    // 添加协议检查
    if (!_isAgreedToTerms) {
      ElToast.info("请同意用户协议");
      return;
    }

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '登录',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 40),
                  // 手机号输入区域
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              hintText: '请输入账号',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // 密码输入区域
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '请输入密码',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  // 登录按钮
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1E3F7C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        '登录',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterPage()),
                            );
                          },
                          child: Text(
                            '注册',
                            style: TextStyle(
                              color: Color(0xFF1E3F7C),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        SizedBox(width: 8,),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ForgetpasswordPage()),
                            );
                          },
                          child: Text(
                            '忘记密码',
                            style: TextStyle(
                              color: Color(0xFF1E3F7C),
                              fontSize: 14,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // 修改用户协议部分
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAgreedToTerms = !_isAgreedToTerms;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          _isAgreedToTerms ? Icons.check_circle : Icons.circle_outlined,
                          color: _isAgreedToTerms ? Color(0xFF1E3F7C) : Color(0xFF8E9AAF),
                          size: 20
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  text: '我已阅读并同意',
                                ),
                                TextSpan(
                                  text: '《隐私政策》',
                                  style: TextStyle(
                                    color: Color(0xFF1E3F7C),
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // 处理隐私政策点击
                                    },
                                ),
                                TextSpan(text: '、'),
                                TextSpan(
                                  text: '《服务协议》',
                                  style: TextStyle(
                                    color: Color(0xFF1E3F7C),
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // 处理服务协议点击
                                    },
                                ),
                                TextSpan(text: '和'),
                                TextSpan(
                                  text: '《小程序隐私保护指引》',
                                  style: TextStyle(
                                    color: Color(0xFF1E3F7C),
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // 处理隐私保护指引点击
                                    },
                                ),
                              ],
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
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E9AAF)),
                ),
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