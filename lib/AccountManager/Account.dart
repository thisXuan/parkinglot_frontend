import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/AccountManager/ChatPage.dart';
import 'package:parkinglot_frontend/AccountManager/Login.dart';
import 'package:parkinglot_frontend/AccountManager/LotteryPage.dart';
import 'package:parkinglot_frontend/AccountManager/MallRatingPage.dart';
import 'package:parkinglot_frontend/AccountManager/MyCollectionPage.dart';
import 'package:parkinglot_frontend/AccountManager/OrderPage.dart';
import 'package:parkinglot_frontend/AccountManager/PersonalInfoPage.dart';
import 'package:parkinglot_frontend/AccountManager/SettingsPage.dart';
import 'package:parkinglot_frontend/AccountManager/MemberActivityCenterPage.dart';
import 'package:parkinglot_frontend/Tabs.dart';
import 'package:parkinglot_frontend/api/user.dart';
import 'package:parkinglot_frontend/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:parkinglot_frontend/AccountManager/VipPrivilegePage.dart';
import 'package:parkinglot_frontend/AccountManager/SignInPage.dart';
import 'package:parkinglot_frontend/AccountManager/PointsExchangePage.dart';

class MemeberPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
   return MemberPageState();
  }
}

class MemberPageState extends State<MemeberPage> {
  String username = "点击头像登录";
  int _point = 0;
  int _currentIndex = 0;
  int _pointNeeded = 0;

  // VIP等级对应的主题色
  final List<Color> vipColors = [
    Color(0xFFDAE1EC),
    Color(0xFFEEE4CE),
    Color(0xFFF3E6DF),
    Color(0xFFD0D5EF),
    Color(0xFFBBAEA3),
  ];

  final List<Color> backgroudColors = [
    Color(0xFF1E3F7C),
    Color(0xFFC1925A),
    Color(0xFF6F4A23),
    Color(0xFF4A5185),
    Color(0xFF282219),
  ];

  Future<void> _loadUserName() async {
    String name = await getUserName(); // 调用获取用户名的函数
    setState(() {
      username = name; // 更新用户名并刷新UI
    });
  }

    // 定义等级区间
  final List<Map<String, dynamic>> _levelRanges = [
    {'min': 0, 'max': 99, 'level': 0},
    {'min': 100, 'max': 1999, 'level': 1},
    {'min': 2000, 'max': 3999, 'level': 2},
    {'min': 4000, 'max': 9999, 'level': 3},
    {'min': 10000, 'max': double.infinity, 'level': 4},
  ];

  Future<void> _getPoint() async{
    var result = await UserApi().GetPoint();
    int code = result['code'];

    if(result!=null){
      if(code==200){
        setState(() {
          _point = result['data'];
          for (var range in _levelRanges) {
            if (_point >= range['min'] && _point <= range['max']) {
              _currentIndex = range['level'];
              // 如果不是最高等级，计算升级所需积分
              if (_currentIndex < 5) {
                _pointNeeded = _levelRanges[_currentIndex]['max'] - _point;
              }
              break;
            }
          }
        });
      }else{
        ElToast.info(result['msg']);
      }
    }
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

  Future<void> _signIn() async{
    var result = await UserApi().Sign();
    if(result!=null){
      var code = result['code'];
      if(code!=200){
        ElToast.info("签到失败");
      }
    }
  }

  @override
  void initState() {
    _loadUserName();
    _getPoint();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vipColors[_currentIndex],
      body: ListView(
        children: [
          _buildHeaderSection(),
          _buildSectionWrapper(_buildBenefitsSection()),
          _buildSectionWrapper(_buildEarningSection()),
          _buildSectionWrapper(_buildSpendingSection()),
        ],
      ),
    );
  }

  Widget _buildSectionWrapper(Widget child) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10), // 外边距
      //padding: EdgeInsets.all(16), // 内边距
      decoration: BoxDecoration(
        color: Colors.white, // 淡灰色背景
        borderRadius: BorderRadius.circular(12), // 圆角
      ),
      child: child,
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      decoration: BoxDecoration(
        color: backgroudColors[_currentIndex],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        foregroundImage: AssetImage('assets/user.jpg'),
                      ),
                    ),
                    onTap: () {
                      if(username=="点击头像登录"){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      }else{
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PersonalInfoPage()),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.card_giftcard, color: Colors.white, size: 20),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MemberActivityCenterPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.headset_mic, color: Colors.white, size: 20),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChatPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _point.toString(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                        Text(
                          "升级还需${_pointNeeded}成长值",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'V${_currentIndex+1}',
                      style: TextStyle(
                        fontSize: 60,
                        color: backgroudColors[_currentIndex],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem("我的卡券", "0", "即将过期：0"),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[200],
                    ),
                    _buildInfoItem("我的珑珠", "0.0", "即将过期：0.0"),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            size: 40,
                            color: Colors.black87,
                          ),
                          Text(
                            "珑珠码",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  child: Center(
                    child: Text(
                      "查看全部 15 项权益",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VipPrivilegePage()),
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[400]),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(String title, String value, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildBenefitsSection() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIconWithLabel("我的订单", Icons.receipt_long),
              _buildIconWithLabel("我的收藏", Icons.star_border),
              _buildIconWithLabel("账号设置", Icons.settings),
              _buildIconWithLabel("商场评价", Icons.feedback),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconWithLabel(String label, IconData icon) {
    return GestureDetector(
      onTap: () async{
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userJson = prefs.getString('user');
        if (userJson == null) {
          ElToast.info("请先登录");
          return;
        }
        if(label=="我的订单"){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderPage()),
          );
        }
        if(label=="我的收藏"){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyCollectionPage()),
          );
        }
        if(label=="账号设置"){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage()),
          );
        }
        if(label=="商场评价"){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MallRatingPage()),
          );
        }
      },
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.black),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEarningSection() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "赚琉珠",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildEarningItem(
          "每日赚成长值",
          "日签得 5 成长值",
          "去签到",
          Icons.edit,
        ),
        const SizedBox(height: 16),
        _buildEarningItem(
          "每日幸运转转赚",
          "最高得 666 珑珠",
          "去参与",
          Icons.card_giftcard,
        ),
        const SizedBox(height: 16),
        _buildEarningItem(
          "珑珠赚不停 升级更轻松",
          "每周助力 完成得 8 珑珠",
          "去参与",
          Icons.show_chart,
        ),
      ],
    ),
    );
  }

  Widget _buildEarningItem(String title, String subtitle, String action, IconData icon) {
    return GestureDetector(
      onTap: () async{
        print(_point);
        if (action == "去签到") {
          await _signIn();
          _getPoint();
          print(_point);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignInPage()),
          );
        }
        if(title=="每日幸运转转赚"&&action=="去参与"){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LotteryPage()),
          );
        }
      },
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFDF6F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF8B572A),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8B572A),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5DCC3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              action,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8B572A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题部分
          Text(
            "花琉珠",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧大图
              Expanded(
                flex: 2,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    //borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage('assets/iqiyi.jpg'), // 替换为实际图片路径
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              // 右侧商品列表
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    buildProductItem("维达抽纸", "99琉珠"),
                    buildProductItem("苏泊尔电水壶", "790琉珠"),
                    buildProductItem("小额琉珠好物专区", "99琉珠起"),
                    buildProductItem("THERMOS保温杯", "820琉珠起"),
                    buildProductItem("可口可乐一箱装", "300琉珠起")
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8,),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PointsExchangePage()),
              );
            },
            child: Image.asset(
              'assets/multipleAD.jpg',
              fit: BoxFit.fitHeight,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProductItem(String title, String price) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14),
          ),
          Text(
            price,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.brown),
          ),
        ],
      ),
    );
  }
}