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

    var result = await UserApi().Register(data,context);
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
      appBar: AppBar(
        title: Text('注册'),
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
                '注册界面',
                style: TextStyle(
                  fontSize: 24,
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
                      controller: _captchaController,
                      decoration: InputDecoration(
                        labelText: "验证码",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  TextButton(
                    child: Text('发送验证码', style: TextStyle(color: Colors.blue)),
                    onPressed: _sendCaptcha,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent, // 设置按钮背景颜色
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // 设置按钮内边距
                    ),
                  ),
                ],
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
                onPressed: _isPasswordMatch ? () => _register() : null,
                child: Text("注册"),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("已有账号？"),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "立即登录",
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