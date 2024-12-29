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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("缴费记录"),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _info.length,
              itemBuilder: (context, index) {
                var parkingRecord = _info[index];
                return ListTile(
                  title: Text(parkingRecord.carName),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("进入时间: ${formatUpdateTime(parkingRecord.entryTime)}"),
                          Text("出去时间: ${formatUpdateTime(parkingRecord.exitTime)}"),
                          Text("停车位置: ${parkingRecord.parkingSpace}"),
                          Text("支付金额: ${parkingRecord.payment}${parkingRecord.payment == '待支付' ? '' : '元'}"),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
