import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
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
  final TextEditingController idController1 = TextEditingController();
  final TextEditingController idController2 = TextEditingController();
  List<Point> points = [];
  bool _isLoading = false;
  Map<String, ui.Image?> floorBackgrounds = {};

  ui.Image? backgroundImage;
  double _scale = 1.0;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _loadAllBackgroundImages();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..addListener(() {
      setState(() {});
    });
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
        points = (result['data'] as List).map((pointJson) => Point.fromJson(pointJson)).toList();
        _animationController.reset();
        _animationController.forward(); // 动画启动
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
        points = [];
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
                      points: points,
                      scale: _scale,
                      progress: _animationController.value,
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
            bottom: 30,
            right: 30,
            child: DropdownButton<String>(
              value: _selectedFloor,
              onChanged: _onFloorSelected,
              items: [
                DropdownMenuItem(
                  value: 'B1',
                  child: Text('B1'),
                ),
                DropdownMenuItem(
                  value: 'M',
                  child: Text('M'),
                ),
                DropdownMenuItem(
                  value: 'F1',
                  child: Text('L1'),
                ),
                DropdownMenuItem(
                  value: 'F2',
                  child: Text('L2'),
                ),
                DropdownMenuItem(
                  value: 'F3',
                  child: Text('L3'),
                ),
                DropdownMenuItem(
                  value: 'F4',
                  child: Text('L4'),
                ),
                DropdownMenuItem(
                  value: 'F5',
                  child: Text('L5'),
                ),
              ],
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
  final double progress;

  IndoorMapPainter({
    required this.floorBackgrounds,
    this.points,
    required this.scale,
    required this.progress,
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

    // 绘制路径
    Path path = Path();
    bool hasPathStarted = false; // 标记路径是否已开始
    int endIndex = (points!.length * progress).clamp(0, points!.length).toInt();

    for (int i = 0; i < endIndex; i++) {
      double x = size.width * points![i].x / 100;
      double y = size.height * points![i].y / 100;

      // 检查当前点的楼层是否切换
      if (i > 0 && points![i].floor != points![i - 1].floor) {
        // 在楼层切换时，绘制前一段路径
        if (hasPathStarted) {
          final pathPaint = Paint()
            ..color = Colors.red
            ..strokeWidth = 4.0
            ..style = PaintingStyle.stroke;
          canvas.drawPath(path, pathPaint);
        }

        //TODO：切换楼层

        // 清除路径并切换背景图
        path = Path();
        hasPathStarted = false; // 重置标记
        canvas.restore();
        canvas.save();

        // 更新楼层和背景图
        _selectedFloor = points![i].floor;
        currentBackground = floorBackgrounds[_selectedFloor];
        if (currentBackground != null) {
          paintImage(
            canvas: canvas,
            rect: Rect.fromLTWH(0, 0, size.width, size.height),
            image: currentBackground,
            fit: BoxFit.fitWidth,
          );
        }
      }

      // 更新路径
      if (!hasPathStarted) {
        path.moveTo(x, y);
        hasPathStarted = true; // 标记路径已开始
      } else {
        path.lineTo(x, y);
      }
    }

    // 绘制最后一段路径
    if (hasPathStarted) {
      final pathPaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, pathPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}