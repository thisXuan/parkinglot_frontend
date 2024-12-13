import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'dart:async';
import 'package:parkinglot_frontend/api/navigation.dart';
import 'package:parkinglot_frontend/utils/util.dart';

class Point {
  final double x;
  final double y;
  final String floor;

  Point({
    required this.x,
    required this.y,
    required this.floor
  });

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      x: json['x'].toDouble() as double,
      y: json['y'].toDouble() as double,
      floor: json['floor'] as String
    );
  }
}

String _selectedFloor = 'M';

class IndoorNavigationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return IndoorNavigationPageState();
  }
}

final TransformationController _transformationController = TransformationController();

class IndoorNavigationPageState extends State<IndoorNavigationPage> with SingleTickerProviderStateMixin {
  final TextEditingController idController1 = TextEditingController(); // 出发点
  final TextEditingController idController2 = TextEditingController(); // 终点
  Map<String,List<Point>> map = new HashMap();
  bool _isLoading = false;
  Map<String, ui.Image?> floorBackgrounds = {};
  ui.Image? backgroundImage;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadAllBackgroundImages();
    _transformationController.addListener(() {
      setState(() {
        _scale = _transformationController.value.getMaxScaleOnAxis();
      });
    });
  }

  Future<void> _loadAllBackgroundImages() async {
    List<String> floors = ['B1', 'M', 'F1', 'F2', 'F3', 'F4', 'F5'];
    for (String floor in floors) {
      try {
        final data = await rootBundle.load("assets/floor/${floor}.jpg");
        final list = data.buffer.asUint8List();
        final image = await decodeImageFromList(list);
        floorBackgrounds[floor] = image;
      } catch (e) {
        print('Error loading image for floor $floor: $e');
        floorBackgrounds[floor] = null;
      }
    }
  }

  Future<void> getCoordinates(String id1, String id2) async {
    map.clear();
    // TODO：根据店铺id返回店铺所在点（占屏幕的百分比）
    int startId = 10;
    int endId = 200;

    dynamic data = {'startId':startId,'endId':endId};
    setState(() {
      _isLoading = true;
    });
    var result;
    try {
      result = await NavigationApi().GetPath(data);
      var code = result['code'];
      var msg = result['msg'];
      if(code!=200){
        ElToast.info(msg.toString());
        return;
      }
      setState(() {
        List<dynamic> dataList = result['data'];
        for (var item in dataList) {
          Point point = Point(
            x: item['x'],
            y: item['y'],
            floor: item['floor'],
          );
          // 将 point 添加到对应楼层的列表中
          if (!map.containsKey(point.floor)) {
            map[point.floor] = [];
          }
          map[point.floor]!.add(point);
        }
        _selectedFloor = map.keys.first;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 用来处理楼层选择
  void _onFloorSelected(String? floor) {
    if (floor != null) {
      setState(() {
        _selectedFloor = floor;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: idController1,
                      decoration: InputDecoration(labelText: '出发点'),
                    ),
                    TextField(
                      controller: idController2,
                      decoration: InputDecoration(labelText: '终点'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        getCoordinates(idController1.text, idController2.text);
                      },
                      child: Text('开始导航'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: CustomPaint(
                    size: Size(double.infinity, double.infinity),
                    painter: IndoorMapPainter(
                      floorBackgrounds: floorBackgrounds,
                      points: map[_selectedFloor],
                      scale: _scale,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Wrap(
              spacing: 8.0, // 按钮之间的水平间距
              children: map.keys.map((String floorKey) {
                return ElevatedButton(
                  onPressed: () {
                    _onFloorSelected(floorKey);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedFloor == floorKey ? Colors.deepPurple : Colors.grey,
                  ),
                  child: Text(
                    floorKey,
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}


class IndoorMapPainter extends CustomPainter {
  final Map<String, ui.Image?> floorBackgrounds; // 每层楼的背景图
  final List<Point>? points;
  final double scale;

  IndoorMapPainter({
    required this.floorBackgrounds,
    this.points,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.transform(_transformationController.value.storage);

    // 如果 points 为 null 或为空，显示指定的默认背景图
    if (points == null || points!.isEmpty) {
      final ui.Image? defaultBackground = floorBackgrounds[_selectedFloor];
      if (defaultBackground != null) {
        paintImage(
          canvas: canvas,
          rect: Rect.fromLTWH(0, 0, size.width, size.height),
          image: defaultBackground,
          fit: BoxFit.fitWidth,
        );
      }
      canvas.restore();
      return;
    }

    // 当前绘制的背景图和楼层
    _selectedFloor = points!.first.floor;
    ui.Image? currentBackground = floorBackgrounds[_selectedFloor];

    if (currentBackground != null) {
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.width, size.height),
        image: currentBackground,
        fit: BoxFit.fitWidth,
      );
    }

    // 设置路径的画笔
    final Paint pathPaint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points!.length; i++) {
      double x = size.width * points![i].x / 100;
      double y = size.height * points![i].y / 100;

      if (i < points!.length - 1) {
        double nextX = size.width * points![i + 1].x / 100;
        double nextY = size.height * points![i + 1].y / 100;
        canvas.drawLine(Offset(x, y), Offset(nextX, nextY), pathPaint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}