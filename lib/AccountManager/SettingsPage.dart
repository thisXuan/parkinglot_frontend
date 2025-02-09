import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/Tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return SettingsPageState();
  }
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('设置', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
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
                        _buildSettingItem('账号与安全', onTap: () {}),
                        Divider(height: 1, indent: 16, endIndent: 16),
                        _buildSettingItem('服务与隐私', onTap: () {}),
                        Divider(height: 1, indent: 16, endIndent: 16),
                        _buildSettingItem('珑珠相关设置', onTap: () {}),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 底部按钮和隐私政策
          Container(
            padding: EdgeInsets.all(16),
            color: Color(0xFFF5F5F5),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text(
                              '确认退出登录吗?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: EdgeInsets.only(
                              top: 20,
                              bottom: 10,
                              left: 24,
                              right: 24,
                            ),
                            actions: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // 关闭弹窗
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Color(0xFF1E3F7C)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(22),
                                          ),
                                          minimumSize: Size(0, 44),
                                        ),
                                        child: Text(
                                          '取消',
                                          style: TextStyle(color: Color(0xFF1E3F7C)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop(); // 关闭弹窗
                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                          await prefs.remove('user');
                                          Navigator.of(context).pop(); // 关闭对话框
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => Tabs()),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF1E3F7C),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(22),
                                          ),
                                          minimumSize: Size(0, 44),
                                        ),
                                        child: Text(
                                          '确认',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF1E3F7C)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Text(
                      '退出登录',
                      style: TextStyle(color: Color(0xFF1E3F7C)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        '《个人信息收集清单》',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        '《个人信息共享清单》',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16), // 为底部安全区域留出空间
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, {required VoidCallback onTap}) {
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
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}