import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/user.dart';

class ForgetpasswordPage extends StatefulWidget {
  _ForgetpasswordPageState createState() => _ForgetpasswordPageState();
}

class _ForgetpasswordPageState extends State<ForgetpasswordPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final UserApi _userApi = UserApi(); // 创建UserApi实例

  void _sendCaptcha() async {

  }

  void _resetPassword() async {
    String phone = _phoneController.text;
    String code = _codeController.text;
    String newPassword = _newPasswordController.text;

    if (phone.isEmpty || code.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('请填写所有字段')));
      return;
    }

    // 构建请求体，重置密码
    Map<String, dynamic> data = {
      'phone': phone,
      'captcha': code,
      'newPassword': newPassword,
    };

    var result = await _userApi.ForgetPassword(data);
    if (result != null) {
      var code = result['code'];
      var message = result['message'];
      if (code == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String registrationInfo = jsonEncode(result);
        prefs.setString('registration', registrationInfo);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('密码重置成功')));
        Navigator.pop(context); // 返回登录页面
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('重置密码失败')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('忘记密码'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '忘记密码',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "手机号",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _sendCaptcha();
                    },
                    child: Text("发送验证码"),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: "验证码",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "新密码",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _resetPassword();
                },
                child: Text("重置密码"),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("返回登录？"),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "立即登录",
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }
}