import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/AccountManager/Login.dart';
import 'package:parkinglot_frontend/Tabs.dart';
import 'package:parkinglot_frontend/api/user.dart';
import 'package:parkinglot_frontend/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:parkinglot_frontend/AccountManager/VipPrivilegePage.dart';
import 'package:parkinglot_frontend/AccountManager/SignInPage.dart';

class MemeberPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
   return MemberPageState();
  }
}

class MemberPageState extends State<MemeberPage> {
  String username = "点击头像登录";

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vipColors[0],
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
        color: backgroudColors[0],
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
                      icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                      onPressed: () {},
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
                      onPressed: () {},
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
                              "10",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                        Text(
                          "升级还需90成长值",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'V1',
                      style: TextStyle(
                        fontSize: 60,
                        color: backgroudColors[0],
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
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.black),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
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
        if (action == "去签到") {
          await _signIn();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignInPage()),
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
          Image.asset('assets/multipleAD.jpg', fit: BoxFit.fitHeight,)
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