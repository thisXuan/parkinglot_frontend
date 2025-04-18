import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/user.dart';
import '../utils/util.dart';

class RegisterPage extends StatefulWidget {
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController(); // 确认密码控制器
  final TextEditingController _captchaController = TextEditingController(); // 验证码控制器

  bool _isPasswordMatch = false; // 密码是否匹配

  void _register() async {
    String username = _usernameController.text;
    String phone = _phoneController.text;
    String password = _passwordController.text;
    String captcha = _captchaController.text; // 获取验证码

    // 验证输入内容
    if (username.isEmpty || phone.isEmpty || password.isEmpty || captcha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('请填写所有字段')));
      return;
    }

    // 构建请求体，包含验证码
    Map<String, dynamic> data = {
      'username': username,
      'phone': phone,
      'password': password,
      'captcha': captcha, // 包含验证码
    };

    var result = await UserApi().Register(data);
    if (result != null) {
      var code = result['code'];
      var message = result['message'];
      if (code == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String registrationInfo = jsonEncode(result);
        prefs.setString('registration', registrationInfo);
        Navigator.pop(context); // 返回到登录页面
      } else {
        ElToast.info(message.toString());
      }
    } else {
      ElToast.info('注册失败');
    }
  }

  void _sendCaptcha() {
    // 发送验证码逻辑，可能需要调用后端API获取验证码
    // 这里省略具体实现...
  }

  void _checkPassword() {
    setState(() {
      _isPasswordMatch = _passwordController.text == _confirmPasswordController.text;
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
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '注册',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              // 用户名输入区域
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: '请输入用户名',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
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
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: TextField(
                        controller: _captchaController,
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
                  ),
                  SizedBox(width: 16),
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
                    hintText: '请确认密码',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    suffixIcon: _isPasswordMatch
                        ? Icon(Icons.check, color: Colors.green)
                        : Icon(Icons.close, color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 40),
              // 注册按钮
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isPasswordMatch ? () => _register() : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1E3F7C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    '注册',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // 已有账号登录
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "已有账号？",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "立即登录",
                      style: TextStyle(
                        color: Color(0xFF1E3F7C),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPassword);
    _confirmPasswordController.addListener(_checkPassword);
  }
}