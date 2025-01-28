import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkinglot_frontend/api/user.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late DateTime _currentMonth;
  late List<DateTime> _days;
  List<int> _signedDays = [];

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _getSignInDays();
    _generateDays();
  }

  Future<void> _getSignInDays() async {
    var result = await UserApi().GetSignInDays();
    if (result['data'] is List) {
      setState(() {
        _signedDays = result['data'].cast<int>();
        print(_signedDays);
      });
    }
  }

  void _generateDays() {
    // 获取当月第一天
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    // 获取当月最后一天
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    
    // 获取上月需要显示的天数
    final prevMonthDays = firstDay.weekday - 1; // 周一为1
    final firstShowDate = firstDay.subtract(Duration(days: prevMonthDays));
    
    _days = List.generate(42, (index) {
      return firstShowDate.add(Duration(days: index));
    });
  }

  void _showRulesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 禁止点击外部关闭
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            '活动规则',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B572A),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '1. 每日签到可获得成长值\n'
                            '2. 连续签到可获得额外奖励\n'
                            '3. 成长值可用于会员等级提升\n'
                            '4. 签到奖励当日有效\n'
                            '5. 中断签到则连签奖励重新计算',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.8,
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('每日签到', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 顶部黄色背景区域
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFB900)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '日日签 日日赚',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B572A),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '再签到 1 天，可获得连签礼',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8B572A),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: _showRulesDialog,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0x33000000),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '活动规则',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 日历部分
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // 年月显示
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    DateFormat('yyyy年M月').format(_currentMonth),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 星期行
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
                      .map((day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                // 日期网格
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: _days.length,
                  itemBuilder: (context, index) {
                    final date = _days[index];
                    final isCurrentMonth = date.month == _currentMonth.month;
                    final isSignedDay = _signedDays.contains(date.day) && isCurrentMonth;
                    final isToday = date.year == today.year && 
                                    date.month == today.month && 
                                    date.day == today.day;
                    
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              color: isCurrentMonth ? Colors.black : Colors.grey[300],
                              fontSize: 16,
                            ),
                          ),
                          if (isToday)
                            Container(
                              padding: EdgeInsets.only(top: 4),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.red,
                                size: 16,
                              ),
                            )
                          else if (isSignedDay)
                            Container(
                              padding: EdgeInsets.only(top: 4),
                              child: Icon(
                                Icons.check_circle,
                                color: Color(0xFFFF9966),
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 