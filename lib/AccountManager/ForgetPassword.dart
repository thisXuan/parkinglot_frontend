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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '忘记密码',
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
                child: TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: '请输入手机号',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              SizedBox(height: 20),
              // 验证码输入区域
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
                        controller: _codeController,
                        decoration: InputDecoration(
                          hintText: '请输入验证码',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _sendCaptcha,
                      child: Text(
                        '发送验证码',
                        style: TextStyle(
                          color: Color(0xFF1E3F7C),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // 新密码输入区域
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '请输入新密码',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // 确认密码输入区域
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '请确认新密码',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    suffixIcon: _isPasswordMatch
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : Icon(Icons.cancel, color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 40),
              // 重置密码按钮
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isPasswordMatch ? _resetPassword : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1E3F7C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    '重置密码',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // 返回登录
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '返回登录',
                    style: TextStyle(
                      color: Color(0xFF1E3F7C),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
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