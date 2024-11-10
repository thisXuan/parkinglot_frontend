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

final TransformationController _transformationController = TransformationController();

class IndoorNavigationPageState extends State<IndoorNavigationPage> {
  final TextEditingController idController1 = TextEditingController();
  final TextEditingController idController2 = TextEditingController();
  List<Point> points = [];
  bool _isLoading = false;

  ui.Image? backgroundImage;

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
    // TODO：根据店铺id返回店铺所在点（占屏幕的百分比）
    double startXPercent = 15;
    double startYPercent = 63;
    double endXPercent  = 59;
    double endYPercent = 34;
    dynamic data = {'startX': startXPercent, 'startY': startYPercent, 'endX': endXPercent, 'endY': endYPercent};
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
  List<Point>? points;
  ui.Image? backgroundImage;
  final double scale;

  IndoorMapPainter({
    this.backgroundImage,
    this.points,
    required this.scale,
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
    if (points!.isNotEmpty) {
      final path = Path();
      path.moveTo(size.width * (points![0].x.toDouble() / 100), size.height * (points![0].y.toDouble() / 100));
      for (int i = 1; i < points!.length; i++) {
        double x = size.width * (points![i].x.toDouble() / 100);
        double y = size.height * (points![i].y.toDouble() / 100);
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
