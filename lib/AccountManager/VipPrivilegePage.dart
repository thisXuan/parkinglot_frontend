import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:parkinglot_frontend/utils/util.dart';

import '../api/user.dart';

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

  final List<Color> noticeColors = [
    Color(0x7E899DFF),
    Color(0xFF938566),
    Color(0xFF8A8073),
    Color(0xFF78798C),
    Color(0xFF746F6D),
  ];

  final List<Color> backgroudColors = [
    Color(0xFF1E3F7C),
    Color(0xFFC1925A),
    Color(0xFF6F4A23),
    Color(0xFF4A5185),
    Color(0xFF282219),
  ];

  @override
  void initState() {
    _getPoint();
    super.initState();
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

  // 构建特权网格
  Widget _buildPrivilegeGrid(int level) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(
              '花琥珀',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            padding: EdgeInsets.symmetric(horizontal: 12),
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            childAspectRatio: 0.9,
            children: [
              _buildPrivilegeItem("抵天街消费", "${level.toDouble()}倍", Icons.shopping_bag),
              _buildPrivilegeItem("天街免费停车", "可抵扣琥珀", Icons.local_parking),
              _buildPrivilegeItem("抵房款", "1.5倍", Icons.home),
              _buildPrivilegeItem("抵物业费", "${level.toDouble()}倍", Icons.business),
              _buildPrivilegeItem("抵生活消费", "${level.toDouble()}倍", Icons.local_mall),
              _buildPrivilegeItem("抵冠寓房租", "支持混合支付", Icons.house),
              _buildPrivilegeItem("抵租售服务费", "1.5倍", Icons.support_agent),
              _buildPrivilegeItem("抵优选好物", "${level.toDouble()}倍", Icons.shopping_cart),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(
              '赚琥珀',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            padding: EdgeInsets.symmetric(horizontal: 12),
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            childAspectRatio: 0.9,
            children: [
              _buildPrivilegeItem("逛天街返琥珀", "最高5%", Icons.storefront),
              _buildPrivilegeItem("新房置业返", "0.5%琥珀", Icons.apartment),
              _buildPrivilegeItem("物业缴费返", "10%琥珀", Icons.payments),
              _buildPrivilegeItem("生活消费返", "20%琥珀", Icons.savings),
              _buildPrivilegeItem("冠寓返琥珀", "最高10%", Icons.house_siding),
              _buildPrivilegeItem("塘鹅返琥珀", "三大专享特权", Icons.card_giftcard),
              _buildPrivilegeItem("优选返琥珀", "最高10%", Icons.redeem),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrivilegeItem(String title, String value, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 40,color: Colors.grey,),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 12)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('会员特权'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 广播和客服行
            Container(
              height: 36,
              padding: EdgeInsets.symmetric(horizontal: 16),
              color: vipColors[_currentPage],
              child: Row(
                children: [
                  Icon(
                    Icons.volume_up,
                    size: 20,
                    color: Colors.black,
                  ),
                  SizedBox(width: 8),
                  // 滚动文字
                  Expanded(
                    child: Marquee(
                      text: '购新房、天街消费、住冠寓、预缴物业费，租售二手房等可增加珑珠',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      scrollAxis: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      blankSpace: 30.0,
                      velocity: 30.0,
                      pauseAfterRound: Duration(seconds: 0),
                      startPadding: 10.0,
                    ),
                  ),
                  // 客服按钮
                  InkWell(
                    onTap: () {
                      ElToast.info("敬请期待");
                    },
                    child: Container(
                      child: Row(
                        children: [
                          SizedBox(width: 8),
                          Icon(
                            Icons.headset_mic,
                            size: 16,
                            color: Colors.black,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '客服',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // VIP等级显示区域
            Container(
              height: 220,
              width: double.infinity,
              color: backgroudColors[_currentPage],
              child: Container(
                margin: EdgeInsets.only(left: 16, right: 16, top: 16),
                decoration: BoxDecoration(
                  color: vipColors[_currentPage],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.zero,
                    bottomRight: Radius.zero,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      top: 16,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: backgroudColors[_currentPage],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            if (_currentIndex == _currentPage)
                              Text(
                                '当前等级',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Icon(
                                    Icons.lock_outline,  // 使用锁图标
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),  // 图标和文字之间的间距
                                  Text(
                                    '待解锁',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      top: 60,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _point.toString(),
                            style: TextStyle(
                              fontSize: 48,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 8, bottom: 8),
                            child: Text(
                              '成长值',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(_currentIndex==_currentPage)
                          Text(
                            '升级至下一等级还需要：${_pointNeeded} 成长值',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          )
                          else if(_currentIndex<_currentPage)
                            Text(
                              '升级至该等级还需要：${_levelRanges[_currentPage]['min'] - _point} 成长值',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            )
                          else
                            Text(
                              '已解锁',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          SizedBox(height: 8),
                          Container(
                            height: 2,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(1),
                            ),
                            child: FractionallySizedBox(
                              widthFactor: 0.1, // 10/90 的进度
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 16,
                      child: GestureDetector(
                        onTap: (){

                        },
                        child: Row(
                          children: [
                            Text(
                              '去升级',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.black.withOpacity(0.8),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      top: 40,
                      child: Text(
                        'V'+(_currentPage+1).toString(),
                        style: TextStyle(
                          fontSize: 64,
                          color: backgroudColors[_currentPage],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 特权内容区域
            Container(
              height: MediaQuery.of(context).size.height - 300, // 调整高度以适应屏幕
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
                          ? backgroudColors[_currentPage]
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 