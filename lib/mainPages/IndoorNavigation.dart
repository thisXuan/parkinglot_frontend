import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'package:parkinglot_frontend/api/navigation.dart';
import 'package:parkinglot_frontend/utils/util.dart';

class Point {
  final double x;
  final double y;

  Point({required this.x, required this.y});

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      x: json['x'].toDouble() as double,
      y: json['y'].toDouble() as double,
    );
  }
}

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

  ui.Image? backgroundImage;
  double _scale = 1.0;

  late AnimationController _animationController;
  String _selectedFloor = 'F3';

  @override
  void initState() {
    super.initState();
    _loadBackgroundImage(_selectedFloor);
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

  Future<void> _loadBackgroundImage(String floor) async {
    try {
      final data = await rootBundle.load("assets/floor/${floor}.jpg");
      final list = data.buffer.asUint8List();
      final image = await decodeImageFromList(list);

      setState(() {
        backgroundImage = image;
      });
    } catch (e) {
      print('Error loading image: $e');
      ElToast.info("${floor}图片加载失败");
    }
  }

  Future<void> getCoordinates(String id1, String id2) async {
    // TODO：根据店铺id返回店铺所在点（占屏幕的百分比）
    int startId = 222;
    int endId = 308;

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
      });
      _loadBackgroundImage(_selectedFloor); // 切换楼层时加载相应的图片
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
                      backgroundImage: backgroundImage,
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
  List<Point>? points;
  ui.Image? backgroundImage;
  final double scale;
  final double progress; // 新增参数，用于控制路径绘制进度

  IndoorMapPainter({
    this.backgroundImage,
    this.points,
    required this.scale,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundImage == null) return;

    canvas.save();
    canvas.transform(_transformationController.value.storage);

    // 绘制背景图
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.width, size.height),
      image: backgroundImage!,
      fit: BoxFit.fitWidth,
    );

    // 绘制路径
    if (points != null && points!.isNotEmpty) {
      final path = Path();
      path.moveTo(size.width * points![0].x / 100, size.height * points![0].y / 100);

      int endIndex = (points!.length * progress).clamp(0, points!.length).toInt();

      for (int i = 1; i < endIndex; i++) {
        double x = size.width * points![i].x/ 100;
        double y = size.height * points![i].y / 100;
        path.lineTo(x, y);
      }

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