import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ManagerDataPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ManagerDataPageState();
}

class ManagerDataPageState extends State<ManagerDataPage> {
  // 模拟数据
  final int visitorCount = 1234;
  final int availableParkingSpots = 45;
  final int activeShops = 28;
  
  // 销售数据
  late List<SalesData> salesDataList;

  // 停车场数据
  final List<ParkingData> parkingData = [
    ParkingData('闲置车位', 30, Colors.green),
    ParkingData('临时车位', 20, Colors.blue),
    ParkingData('业主车位', 40, Colors.orange),
    ParkingData('已用车位', 10, Colors.red),
  ];

  // 用户统计数据
  final int totalUsers = 5000;
  final int newUsers = 120;
  final List<FlSpot> activeUsersData = [
    FlSpot(0, 800),
    FlSpot(1, 1000),
    FlSpot(2, 950),
    FlSpot(3, 1200),
    FlSpot(4, 1100),
    FlSpot(5, 1300),
    FlSpot(6, 1250),
  ];

  @override
  void initState() {
    super.initState();
    // 初始化销售数据
    initSalesData();
  }

  void initSalesData() {
    final now = DateTime.now();
    salesDataList = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return SalesData(
        date: date,
        sales: [2500, 3200, 2800, 3600, 3100, 3800, 4200][index],
        orders: [120, 150, 130, 180, 160, 200, 220][index],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverview(),
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
                  isCurved: true,
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
    // 计算最新的日环比和周同比
    final todayOrders = salesDataList.last.orders;
    final yesterdayOrders = salesDataList[salesDataList.length - 2].orders;
    final lastWeekOrders = todayOrders * 0.8; // 模拟数据，实际应该从数据源获取

    final dayChange = ((todayOrders - yesterdayOrders) / yesterdayOrders * 100).toStringAsFixed(1);
    final weekChange = ((todayOrders - lastWeekOrders) / lastWeekOrders * 100).toStringAsFixed(1);

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
                todayOrders.toString(),
                '日环比 ${dayChange}%',
                dayChange.startsWith('-') ? Colors.red : Colors.green,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildOrderMetric(
                '周订单趋势',
                todayOrders.toString(),
                '周同比 ${weekChange}%',
                weekChange.startsWith('-') ? Colors.red : Colors.green,
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
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: activeUsersData,
                      isCurved: true,
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