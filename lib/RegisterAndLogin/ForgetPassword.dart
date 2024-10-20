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
  final TextEditingController _confirmPasswordController = TextEditingController();
  final UserApi _userApi = UserApi(); // 创建UserApi实例
  bool _isPasswordMatch = false;

  void _sendCaptcha() async {
    // 发送验证码逻辑
  }

  void _resetPassword() async {
    String phone = _phoneController.text;
    String code = _codeController.text;
    String newPassword = _newPasswordController.text;

    if (phone.isEmpty || code.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('请填写所有字段')));
      return;
    }

    if (!_isPasswordMatch) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('密码不一致')));
      return;
    }

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
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('重置密码失败')));
    }
  }

  void _checkPassword() {
    setState(() {
      _isPasswordMatch = _newPasswordController.text == _confirmPasswordController.text;
    });
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: "验证码",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  TextButton(
                    child: Text("发送验证码"),
                    onPressed: () => _sendCaptcha(),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                  ),
                ],
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
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "确认密码",
                  border: OutlineInputBorder(),
                  suffixIcon: _isPasswordMatch
                      ? Icon(Icons.check, color: Colors.green)
                      : Icon(Icons.close, color: Colors.red),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isPasswordMatch ? () => _resetPassword() : null,
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
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_checkPassword);
    _confirmPasswordController.addListener(_checkPassword);
  }
}