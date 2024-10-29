import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/RegisterAndLogin/Login.dart';
import 'package:parkinglot_frontend/mainPages/Tabs.dart';
import 'package:parkinglot_frontend/mainPages/mapNavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class accountPage extends StatefulWidget {
  _accountPageState createState() => _accountPageState();
}

// TODO:没有加上用户登录状态管理
class _accountPageState extends State<accountPage> {
  String username = "点击头像登录";
  List menuTitles = [
    '我的消息',
    '浏览记录',
    '我的问答',
    '我的活动',
    '邀请好友',
  ];
  List menuIcons = [
    Icons.message,
    Icons.print,
    Icons.phone,
    Icons.send,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName(); // 加载用户名
  }

  Future<void> _loadUserName() async {
    String name = await getUserName(); // 调用获取用户名的函数
    setState(() {
      username = name; // 更新用户名并刷新UI
    });
  }

  Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson != null) {
      Map<String, String> userInfo = Map<String, String>.from(jsonDecode(userJson));
      return userInfo['username'] ?? '';
    }
    return "点击头像登录";
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              color: Colors.deepPurple,
              height: 160.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Container(
                      width: 60.0,
                      height:60.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:Colors.white,
                            width: 2.0,
                          ),
                          image: DecorationImage(
                              image: AssetImage('assets/user.png'),
                              fit: BoxFit.cover
                          )
                      ),
                    ),
                    onTap: (){
                      if(username=="点击头像登录"){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      }else{
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('确认退出登录?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // 关闭对话框
                                  },
                                  child: Text('取消'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    await prefs.remove('user');
                                    Navigator.of(context).pop(); // 关闭对话框
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => Tabs()),
                                    );
                                  },
                                  child: Text('确定'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    username,
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            );
          }
          index -= 1;
          return ListTile(
            leading: Icon(menuIcons[index]), //左图标
            title: Text(menuTitles[index]), //中间标题
            trailing: Icon(Icons.arrow_forward_ios),
          );
        },
        separatorBuilder: (context, index) {
          return Divider();
        }, //分隔线
        itemCount: menuTitles.length + 1);
  }

}
