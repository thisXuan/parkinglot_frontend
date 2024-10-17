import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _register() {
    String username = _usernameController.text;
    String phone = _phoneController.text;
    String password = _passwordController.text;
    // TODO: 实现注册逻辑，如验证输入内容并保存用户信息
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
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "密码",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                  onPressed: (){
                    _register();
                  },
                  child: Text("注册")
              ),
              SizedBox(
                  height: 30
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("已有账号？"),
                  GestureDetector(
                    onTap: (){
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
    super.dispose();
  }
}
