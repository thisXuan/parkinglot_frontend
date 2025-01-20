import 'package:flutter/material.dart';

  // VIP特权数据结构
class VipPrivilege {
    final String title;
    final String value;
    final String iconPath;

    VipPrivilege({
      required this.title,
      required this.value,
      required this.iconPath,
    });
}

class VipPrivilegePage extends StatefulWidget {
  @override
  _VipPrivilegePageState createState() => _VipPrivilegePageState();
}

class _VipPrivilegePageState extends State<VipPrivilegePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // VIP等级对应的主题色
  final List<Color> vipColors = [
    Color(0xFF8AA8E5), // V1 蓝色
    Color(0xFFE5C88A), // V2 金色
    Color(0xFFB8E58A), // V3 绿色
    Color(0xFFE58AA8), // V4 粉色
    Color(0xFF8AE5E5), // V5 青色
  ];

  // 构建特权网格
  Widget _buildPrivilegeGrid(int level) {
    return GridView.count(
      crossAxisCount: 4,
      padding: EdgeInsets.all(16),
      children: [
        _buildPrivilegeItem("抵天街消费", "${level.toDouble()}倍", "assets/icons/shopping.png"),
        _buildPrivilegeItem("天街免费停车", "可抵扣琥珀", "assets/icons/parking.png"),
        _buildPrivilegeItem("抵房款", "1.5倍", "assets/icons/house.png"),
        _buildPrivilegeItem("抵物业费", "${level.toDouble()}倍", "assets/icons/property.png"),
        _buildPrivilegeItem("抵生活消费", "${level.toDouble()}倍", "assets/icons/life.png"),
        _buildPrivilegeItem("抵冠寓房租", "支持混合支付", "assets/icons/rent.png"),
        _buildPrivilegeItem("抵租售服务费", "1.5倍", "assets/icons/service.png"),
        _buildPrivilegeItem("抵优选好物", "${level.toDouble()}倍", "assets/icons/goods.png"),
        // 添加更多特权项...
      ],
    );
  }

  Widget _buildPrivilegeItem(String title, String value, String iconPath) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(iconPath, width: 40, height: 40),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 12)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('会员特权'),
        backgroundColor: vipColors[_currentPage],
        elevation: 0,
      ),
      body: Column(
        children: [
          // VIP等级显示区域
          Container(
            height: 150,
            color: vipColors[_currentPage],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'V${_currentPage + 1}',
                  style: TextStyle(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '成长值：${_currentPage * 100 + 5}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // 特权内容区域
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildPrivilegeGrid(index + 1);
              },
            ),
          ),
          // 页面指示器
          Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? vipColors[_currentPage]
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 