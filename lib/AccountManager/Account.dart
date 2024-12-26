import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/AccountManager/Login.dart';
import 'package:parkinglot_frontend/Tabs.dart';
import 'package:parkinglot_frontend/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MemeberPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
   return MemberPageState();
  }
}

class MemberPageState extends State<MemeberPage> {
  String username = "点击头像登录";

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
  void initState() {
    _loadUserName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[60],
      body: ListView(
        children: [
          _buildHeaderSection(),
          _buildBenefit(),
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
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFFDACDFB),
        //borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
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
                      width: 34, // 宽度 = 半径 * 2 + 边框宽度
                      height: 34, // 高度 = 半径 * 2 + 边框宽度
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black, // 边框颜色
                          width: 2.0, // 边框宽度
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 15, // 头像半径
                        foregroundImage: AssetImage('assets/user.jpg'),
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
                  SizedBox(width: 8), // 头像与用户名之间的间距
                  Text(
                    username,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chat_bubble_outline),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.headset_mic),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.more_horiz),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCard("我的卡券", "0", "即将过期: 0"),
              _buildCard("我的琉珠", "0.0", "即将过期: 0.0"),
              Column(
                children: [
                  Icon(Icons.qr_code, size: 48),
                  Text(
                    '会员码',
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildBenefit(){
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFFd0c0f9),
        //borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: GestureDetector(
        child: Center(
          child: Text(
            "查看全部 15 项权益",
            style: TextStyle(color: Colors.deepPurple),
          ),
        ),
        onTap: (){
          ElToast.info("敬请期待");
        },
      )
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
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("赚琉珠", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _buildEarningItem(Icons.calendar_month,"连签赚琉珠", "日签得 5 成长值", "去签到"),
          _buildEarningItem(Icons.wallet_giftcard,"每日幸运转转赚", "最高得 666 琉珠", "去参与"),
          _buildEarningItem(Icons.stacked_line_chart,"琉珠赚不停", "每周助力完成得 8 琉珠", "去参与"),
        ],
      ),
    );
  }

  Widget _buildEarningItem(IconData icon, String title, String subtitle, String action) {
    return ListTile(
      title: Row(
        children: [
          Icon(
            icon,
            color: Colors.black,
          ),
          SizedBox(width: 4,),
          Text(title)
        ],
      ),
      subtitle: Text(subtitle,style: TextStyle(fontSize: 13,color: Colors.deepPurple),),
      trailing: ElevatedButton(
        onPressed: () {},
        child: Text(action, style: TextStyle(color: Colors.deepPurple)),
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