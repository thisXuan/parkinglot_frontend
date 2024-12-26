import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/api/parking.dart';
import 'package:intl/intl.dart';

class Car {
  int id;
  String carName;
  String updateTime;
  int userId;

  Car(
      {required this.id,
      required this.carName,
      required this.updateTime,
      required this.userId});

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
        id: json['id'],
        carName: json['carname'] ?? '',
        updateTime: json['updatetime'] ?? '',
        userId: json['userid'] ?? 0);
  }
}

class FindmycarPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FindmycarState();
  }
}

class FindmycarState extends State<FindmycarPage> {
  List<Car> _info = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCarRecord();
  }

  void fetchCarRecord() async {
    var result = await ParkingApi().GetMyCar();
    if (result != null) {
      var data = result['data'];
      if (data != null) {
        setState(() {
          _info = (data as List).map((json) => Car.fromJson(json)).toList();
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
        title: Text("我的车辆"),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _info.length,
              itemBuilder: (context, index) {
                var car = _info[index];
                return ListTile(
                  title: Text(car.carName),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("更新时间: ${formatUpdateTime(car.updateTime)}"),
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
