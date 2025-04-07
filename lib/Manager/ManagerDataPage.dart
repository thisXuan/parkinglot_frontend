import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:parkinglot_frontend/Manager/ManagerReviewPage.dart';
import 'package:parkinglot_frontend/api/data.dart';
import 'package:parkinglot_frontend/entity/DataDTO.dart';
import 'package:parkinglot_frontend/entity/SalesDataDTO.dart';
import 'package:parkinglot_frontend/utils/request.dart';

class ManagerDataPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ManagerDataPageState();
}

class ManagerDataPageState extends State<ManagerDataPage> {
  // 数据概览
  int visitorCount = 0;
  int availableParkingSpots = 0;
  int activeShops = 0;
  
  // 销售数据
  List<SalesData> salesDataList = List.filled(7, new SalesData(date: DateTime.now(), sales: 0, orders: 0));

  // 订单分析
  int todayOrder = 0;
  int dayOrderDay = 0;
  int weekOrder=0;
  int weekOrderWeek=0;

  // 停车场数据
  final List<ParkingData> parkingData = [
    ParkingData('闲置车位', 30, Colors.green),
    ParkingData('临时车位', 20, Colors.blue),
    ParkingData('业主车位', 40, Colors.orange),
    ParkingData('已用车位', 10, Colors.red),
  ];

  // 用户统计数据
  int totalUsers = 0;
  int newUsers = 0;
  List<FlSpot> activeUsersData = [];

  @override
  void initState() {
    super.initState();
    initTotalView();
    initSalesData();
    initOrderData();
    initUserData();
  }

  void initTotalView() async{
    var result = await DataApi().TotalView();
    if(result!=null){
      var code = result['code'];
      if(code==200){
        DataDTO dataDTO = DataDTO.fromJson(result['data']);
        setState(() {
          visitorCount = dataDTO.visitor;
          availableParkingSpots = dataDTO.parking;
          activeShops = dataDTO.store;
        });
      }
    }
  }

  void initSalesData() async{
    final now = DateTime.now();
    var result = await DataApi().SalesAnalysis();
    List<int> sales = List.filled(7, 0);
    if(result!=null){
      var code = result['code'];
      if(code==200){
        sales = List<int>.from(result['data']);
      }else{
        return;
      }
    }
    salesDataList = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return SalesData(
        date: date,
        sales: sales[index],
        orders: [120, 150, 130, 180, 160, 200, 220][index],
      );
    });
  }

  void initOrderData() async{
    var result = await DataApi().OrderAnalysis();
    if(result!=null){
      var code = result['code'];
      if(code==200){
        setState(() {
          todayOrder = result['data']['todayOrder'];
          dayOrderDay = result['data']['dayOrderDay'];
          weekOrder=result['data']['weekOrder'];
          weekOrderWeek=result['data']['weekOrderWeek'];
        });
      }
    }
  }

  void initUserData() async{
    var result = await DataApi().UserAnalysis();
    if(result!=null){
      var code = result['code'];
      if(code==200){
        setState(() {
          totalUsers = result['data']['totalRegister'];
          newUsers = result['data']['todayRegister'];
          List<int> weekRegister = List<int>.from(result['data']['weekRegister']);
          for(int i=0;i<weekRegister.length;i++){
            setState(() {
              activeUsersData.add(FlSpot(i.toDouble(), weekRegister[i].toDouble()));
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverview(),
            SizedBox(height: 20),
            _buildReviews(),
            SizedBox(height: 20),
            _buildSalesAnalysis(),
            SizedBox(height: 20),
            _buildParkingAnalysis(),
            SizedBox(height: 20),
            _buildUserAnalysis(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('数据概览', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOverviewItem('访问人数', visitorCount),
                _buildOverviewItem('空闲车位', availableParkingSpots),
                _buildOverviewItem('营业店铺', activeShops),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviews() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManagerReviewPage()),
                );
              },
              child: Row(
                children: [
                  Text('商场评价', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Spacer(),  // 使"点击查看详情"和图标靠右对齐
                  Row(
                    children: [
                      Text("点击查看详情", style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Icon(Icons.arrow_forward_ios, color: Colors.grey)
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOverviewItem('整体评分', 0),
                _buildOverviewItem('反馈人数', 0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(String title, int value) {
    return Column(
      children: [
        Text(value.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildSalesAnalysis() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('商铺分析', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildSalesChart(),
            SizedBox(height: 20),
            _buildOrdersAnalysis(),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('销售额趋势', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        Container(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < salesDataList.length) {
                        return Text(
                          '${salesDataList[value.toInt()].date.day}日',
                          style: TextStyle(fontSize: 10),
                        );
                      }
                      return Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: salesDataList.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.sales.toDouble());
                  }).toList(),
                  isCurved: false,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('订单分析', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildOrderMetric(
                '今日订单',
                todayOrder.toString(),
                '日环比 ${dayOrderDay}%',
                dayOrderDay.toString().startsWith('-') ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildOrderMetric(
                '周订单趋势',
                weekOrder.toString(),
                '周同比 ${weekOrderWeek}%',
                weekOrderWeek.toString().startsWith('-') ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderMetric(String title, String value, String change, Color changeColor) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(
            change,
            style: TextStyle(color: changeColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingAnalysis() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('停车场统计', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: parkingData.map((data) => PieChartSectionData(
                          value: data.value,
                          color: data.color,
                          title: '${(data.value).toStringAsFixed(0)}%',
                        )).toList(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: parkingData.map((data) => _buildLegendItem(
                      data.title,
                      data.color,
                      '${data.value}%',
                    )).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAnalysis() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('用户统计', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildUserStatItem('总注册人数', totalUsers),
                _buildUserStatItem('新注册人数', newUsers),
              ],
            ),
            SizedBox(height: 20),
            Container(
              height: 200,
              child: activeUsersData.isEmpty
                  ? Center(
                      child: Text('暂无数据', 
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 && value.toInt() < salesDataList.length) {
                                  return Text(
                                    '${salesDataList[value.toInt()].date.day}日',
                                    style: TextStyle(fontSize: 10),
                                  );
                                }
                                return Text('');
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: activeUsersData,
                            isCurved: false,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            color: color,
          ),
          SizedBox(width: 4),
          Flexible(
            child: Text(
              '$title: $value',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatItem(String title, int value) {
    return Column(
      children: [
        Text(value.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class ParkingData {
  final String title;
  final double value;
  final Color color;

  ParkingData(this.title, this.value, this.color);
}

// 新增数据类
class SalesData {
  final DateTime date;
  final int sales;
  final int orders;

  SalesData({
    required this.date,
    required this.sales,
    required this.orders,
  });
}