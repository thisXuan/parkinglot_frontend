import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/AccountManager/SettingsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManagerSettingPage extends StatefulWidget {
  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<ManagerSettingPage> {
  String _avatar = 'assets/user.jpg';
  String _nickname = '珑珠用户';
  String _birthday = '去设置';

  @override
  void initState() {
    _getUserName();
    super.initState();
  }

  Future<void> _getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson != null) {
      Map<String, String> userInfo = Map<String, String>.from(jsonDecode(userJson));
      setState(() {
        _nickname = userInfo['username']??'';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFF5F5F5),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // 头像
                  _buildInfoItem(
                    '头像',
                    trailing: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        _avatar,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[200],
                            child: Icon(Icons.person, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    onTap: () async {
                      // TODO: 实现头像选择和上传
                    },
                  ),
                  Divider(height: 1, indent: 16, endIndent: 16),
                  // 昵称
                  _buildInfoItem(
                    '昵称',
                    value: _nickname,
                    onTap: () async {
                      // TODO: 实现昵称修改
                    },
                  ),
                  Divider(height: 1, indent: 16, endIndent: 16),
                  // 生日
                  _buildInfoItem(
                    '生日',
                    value: _birthday,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _birthday = "${picked.year}-${picked.month}-${picked.day}";
                        });
                        // TODO: 调用API保存生日
                      }
                    },
                  ),
                ],
              ),
            ),
            // 设置按钮
            Container(
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildInfoItem(
                '设置',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      String title, {
        String? value,
        Widget? trailing,
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                if (value != null)
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: title == '生日' && value == '去设置'
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                if (trailing != null) trailing,
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}