import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'package:parkinglot_frontend/api/navigation.dart';

// 定义点的实体类
class Point {
  final int x;
  final int y;

  Point({required this.x, required this.y});

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      x: json['x'] as int,
      y: json['y'] as int,
    );
  }
}

class IndoorNavigationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return IndoorNavigationPageState();
  }
}

class IndoorNavigationPageState extends State<IndoorNavigationPage> {
  final TextEditingController idController1 = TextEditingController();
  final TextEditingController idController2 = TextEditingController();
  List<Point> points = [];
  bool _isLoading = false;

  Offset? point1;
  Offset? point2;
  ui.Image? backgroundImage;

  final TransformationController _transformationController = TransformationController();
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadBackgroundImage();
    _transformationController.addListener(() {
      setState(() {
        _scale = _transformationController.value.getMaxScaleOnAxis();
      });
    });
  }

  Future<void> _loadBackgroundImage() async {
    try {
      final data = await rootBundle.load('assets/Mall_L3.jpg');
      final list = data.buffer.asUint8List();
      final image = await decodeImageFromList(list);

      setState(() {
        backgroundImage = image;
      });
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  Future<void> getCoordinates(String id1, String id2) async {
    double startX = 125;
    double startY = 400;
    double endX = 150;
    double endY = 300;
    setState(() {
      point1 = Offset(startX, startY);
      point2 = Offset(endX, endY);
    });
    dynamic data = {'startX': startX, 'startY': startY, 'endX': endX, 'endY': endY};
    setState(() {
      _isLoading = true;
    });
    var result;
    try {
      result = await NavigationApi().GetPath(data);
      setState(() {
        points = (result['data'] as List)
            .map((pointJson) => Point.fromJson(pointJson))
            .toList();
      });
    } finally {
      setState(() {
        _isLoading = false;
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
                      point1: point1,
                      point2: point2,
                      backgroundImage: backgroundImage,
                      points: points,
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
        ],
      ),
    );
  }
}

class IndoorMapPainter extends CustomPainter {
  Offset? point1;
  Offset? point2;
  List<Point>? points;
  ui.Image? backgroundImage;
  final double scale;

  IndoorMapPainter({
    this.point1,
    this.point2,
    this.backgroundImage,
    this.points,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制背景图
    if (backgroundImage != null) {
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.width, size.height),
        image: backgroundImage!,
        fit: BoxFit.fitWidth,
      );
    }

    if (points!.isEmpty) return;

    final scaledPath = Path();
    scaledPath.moveTo(points![0].x * scale, points![0].y * scale);

    for (int i = 1; i < points!.length; i++) {
      scaledPath.lineTo(points![i].x * scale, points![i].y * scale);
    }

    final pathPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4 / scale // 根据缩放调整线宽
      ..style = PaintingStyle.stroke;

    canvas.drawPath(scaledPath, pathPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
