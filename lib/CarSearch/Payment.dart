import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/api/parking.dart';
import 'package:intl/intl.dart';
import 'package:parkinglot_frontend/entity/ParkingRecord.dart';

class PaymentPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PaymentPageState();
  }
}

class PaymentPageState extends State<PaymentPage> {
  List<ParkingRecord> _info = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchParkingRecord();
  }

  void fetchParkingRecord() async {
    var result = await ParkingApi().GetPayment();
    if (result != null) {
      var data = result['data'];
      if (data != null) {
        setState(() {
          _info = (data as List)
              .map((json) => ParkingRecord.fromJson(json))
              .toList();
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 格式化时间
  String formatUpdateTime(String updateTime) {
    try {
      DateTime parsedTime = DateTime.parse(updateTime).toLocal();
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedTime);
    } catch (e) {
      return updateTime; // 如果解析失败，返回原始字符串
    }
  }

  Widget _buildSectionWrapper(Widget child) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 外边距
      padding: EdgeInsets.all(16), // 内边距
      decoration: BoxDecoration(
        color: Colors.white, // 白色背景
        borderRadius: BorderRadius.circular(12), // 圆角
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("缴费记录"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _info.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("暂无缴费记录", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _info.length,
                  itemBuilder: (context, index) {
                    var parkingRecord = _info[index];
                    return _buildSectionWrapper(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                parkingRecord.carName,
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: parkingRecord.payment == '待支付' 
                                    ? Colors.red[100] 
                                    : Colors.green[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  parkingRecord.payment == '待支付' 
                                    ? "待支付" 
                                    : "已支付 ${parkingRecord.payment}元",
                                  style: TextStyle(
                                    color: parkingRecord.payment == '待支付' 
                                      ? Colors.red 
                                      : Colors.green,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 20),
                          _buildInfoItem("进入时间", formatUpdateTime(parkingRecord.entryTime)),
                          SizedBox(height: 8),
                          _buildInfoItem("出去时间", formatUpdateTime(parkingRecord.exitTime)),
                          SizedBox(height: 8),
                          _buildInfoItem("停车位置", parkingRecord.parkingSpace),
                          if (parkingRecord.payment != '待支付') ...[
                            SizedBox(height: 16),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  // 查看详情或打印发票功能
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown[300],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text("查看发票"),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
    );
  }
  
  Widget _buildInfoItem(String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
