import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'dart:async';
import 'package:parkinglot_frontend/api/navigation.dart';
import 'package:parkinglot_frontend/utils/util.dart';
import 'package:parkinglot_frontend/api/store.dart';
import 'dart:convert';

class Point {
  final double x;
  final double y;
  final String floor;

  Point({required this.x, required this.y, required this.floor});

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
        x: json['x'].toDouble() as double,
        y: json['y'].toDouble() as double,
        floor: json['floor'] as String);
  }
}

String _selectedFloor = 'M';

class IndoorNavigationPage extends StatefulWidget {
  String? location;

  IndoorNavigationPage({this.location, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return IndoorNavigationPageState();
  }
}


class IndoorNavigationPageState extends State<IndoorNavigationPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController idController1 = TextEditingController(); // 出发点
  final TextEditingController idController2 = TextEditingController(); // 终点
  Map<String, List<Point>> map = new HashMap();
  bool _isLoading = false;
  Map<String, ui.Image?> floorBackgrounds = {};
  ui.Image? backgroundImage;
  double _scale = 1.0;

  TransformationController _transformationController = TransformationController();

  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  List<String> _allSuggestions = [];

  final LayerLink _layerLink1 = LayerLink();
  final LayerLink _layerLink2 = LayerLink();

  List<String> _filteredSuggestions1 = [];
  List<String> _filteredSuggestions2 = [];

  OverlayEntry? _overlayEntry1;
  OverlayEntry? _overlayEntry2;

  void _showOverlay(int fieldIndex) {
    if (fieldIndex == 1) {
      if (_overlayEntry1 != null) _overlayEntry1!.remove();
      _overlayEntry1 = _createOverlayEntry(1);
      Overlay.of(context)!.insert(_overlayEntry1!);
    } else {
      if (_overlayEntry2 != null) _overlayEntry2!.remove();
      _overlayEntry2 = _createOverlayEntry(2);
      Overlay.of(context)!.insert(_overlayEntry2!);
    }
  }

  void _hideOverlay(int fieldIndex) {
    if (fieldIndex == 1) {
      _overlayEntry1?.remove();
      _overlayEntry1 = null;
    } else {
      _overlayEntry2?.remove();
      _overlayEntry2 = null;
    }
  }

  OverlayEntry _createOverlayEntry(int fieldIndex) {
    final suggestions = fieldIndex == 1 ? _filteredSuggestions1 : _filteredSuggestions2;
    final layerLink = fieldIndex == 1 ? _layerLink1 : _layerLink2;

    double containerHeight = (suggestions.length * 50).toDouble();
    containerHeight = containerHeight > 250 ? 250 : containerHeight;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, 40.0), // 下拉框位置
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              height: containerHeight,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(suggestions[index]),
                    onTap: () {
                      if (fieldIndex == 1) {
                        idController1.text = suggestions[index];
                        _hideOverlay(1);
                      } else {
                        idController2.text = suggestions[index];
                        _hideOverlay(2);
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _filterSuggestions(String input, int fieldIndex) {
    _getStoreNames();
    if (input.isEmpty) {
      if (fieldIndex == 1) {
        setState(() => _filteredSuggestions1.clear());
        _hideOverlay(1);
      } else {
        setState(() => _filteredSuggestions2.clear());
        _hideOverlay(2);
      }
    } else {
      final filtered = _allSuggestions
          .where((suggestion) => suggestion.contains(input))
          .toList();
      setState(() {
        if (fieldIndex == 1) {
          _filteredSuggestions1 = filtered;
        } else {
          _filteredSuggestions2 = filtered;
        }
      });
      if (filtered.isNotEmpty) {
        _showOverlay(fieldIndex);
      } else {
        _hideOverlay(fieldIndex);
      }
    }
  }

  bool _validateInput(String? value, int fieldIndex) {
    if (value == null || value.isEmpty) {
      return false;
    }
    if (!_allSuggestions.contains(value)) {
      return false;
    }
    return true;
  }


  @override
  void dispose() {
    _animationController.dispose();
    idController1.dispose();
    idController2.dispose();
    widget.location = "";
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if(widget.location!=null){
      idController2.text = widget.location!;
    }
    _loadAllBackgroundImages();
    _getStoreNames();
    _transformationController.addListener(() {
      setState(() {
        _scale = _transformationController.value.getMaxScaleOnAxis();
      });
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // 行走动画时间
    )..repeat(reverse: false);
    // 添加监听器来触发重绘
    _animationController.addListener(() {
      setState(() {});
    });
    _progressAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  Future<void> _getStoreNames() async{
    var result = await StoreApi().GetStoreName();
    setState(() {
        _allSuggestions = List<String>.from(result['data']);
    });
  }

  Future<void> _loadAllBackgroundImages() async {
    List<String> floors = ['B2','B1', 'M', 'F1', 'F2', 'F3', 'F4', 'F5'];
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

  Future<void> getCoordinates(String storeName1, String storeName2) async {
    map.clear();

    dynamic data = {'startName': storeName1, 'endName': storeName2};
    setState(() {
      _isLoading = true;
    });
    var result;
    try {
      result = await NavigationApi().GetPath(data);
      var code = result['code'];
      var msg = result['msg'];
      if (code != 200) {
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
        _progressAnimation =
            Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
      });
    }
  }
  
  Widget _buildSectionWrapper(Widget child) {
    return Container(
      padding: EdgeInsets.all(16), // 内边距
      decoration: BoxDecoration(
        color: Colors.white, // 淡灰色背景
        borderRadius: BorderRadius.circular(0), // 圆角
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _buildSectionWrapper(Column(
                children: [
                  CompositedTransformTarget(
                    link: _layerLink1,
                    child: TextField(
                      controller: idController1,
                      decoration: InputDecoration(
                        hintText: "出发点",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) => _filterSuggestions(value, 1),
                      onTap: (){
                        map.clear();
                      },
                    ),
                  ),
                  SizedBox(height: 8,),
                  CompositedTransformTarget(
                    link: _layerLink2,
                    child: TextField(
                      controller: idController2,
                      decoration: InputDecoration(
                        hintText: "终点",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) => _filterSuggestions(value, 2),
                      onTap: (){
                        map.clear();
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // 收起键盘
                      FocusScope.of(context).unfocus();

                      if(idController1.text.length==0||idController2.text.length==0){
                        ElToast.info("请输入起始点和终点");
                        return;
                      }

                      if(idController1.text==idController2.text){
                        ElToast.info("起始点和终点不能相同");
                        return;
                      }
                      if( _validateInput(idController1.text,1)&& _validateInput(idController2.text,2)) {
                        getCoordinates(idController1.text, idController2.text);
                        return;
                      }else{
                        ElToast.info("输入错误");
                      }
                    },
                    child: Text('开始导航'),
                  ),
                ],
              )),
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
                      animationProgress: _progressAnimation.value,
                      transformationController: _transformationController,
                      availableHeight: MediaQuery.of(context).size.height,
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
            child: map.isEmpty
                ? Text(
                    '',
                    style: TextStyle(color: Colors.grey),
                  )
                : Wrap(
                    spacing: 8.0,
                    children: map.keys.map((String floorKey) {
                      return ElevatedButton(
                        onPressed: () {
                          _onFloorSelected(floorKey);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedFloor == floorKey
                              ? Colors.deepPurple
                              : Colors.grey,
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
  final double animationProgress;
  final TransformationController transformationController;
  double availableHeight;

  IndoorMapPainter(
      {required this.floorBackgrounds,
      this.points,
      required this.scale,
      required this.animationProgress,
      required this.transformationController,
      required this.availableHeight});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.transform(transformationController.value.storage);

    double nowHeight = 526;

    // 如果 points 为 null 或为空，显示指定的默认背景图
    if (points == null || points!.isEmpty) {
      final ui.Image? defaultBackground = floorBackgrounds[_selectedFloor];
      if (defaultBackground != null) {
        paintImage(
          canvas: canvas,
          rect: Rect.fromLTWH(0, 0, size.width, nowHeight),
          image: defaultBackground,
          fit: BoxFit.fitHeight,
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
        rect: Rect.fromLTWH(0, 0, size.width, nowHeight),
        image: currentBackground,
        fit: BoxFit.fitHeight,
      );
    }

    // 绘制灰色路径
    final Paint backgroundPathPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final Paint animationPathPaint = Paint()
      ..color = Colors.purple
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    double totalLength = 0.0;
    List<double> segmentLengths = [];

    for (int i = 0; i < points!.length - 1; i++) {
      double x1 = size.width * points![i].x / 100;
      double y1 = size.height * points![i].y / 100;
      double x2 = size.width * points![i + 1].x / 100;
      double y2 = size.height * points![i + 1].y / 100;
      double length = sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
      segmentLengths.add(length);
      totalLength += length;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), backgroundPathPaint);
    }

    double currentLength = totalLength * animationProgress;
    // 找到当前所在的路径段
    double cumulativeLength = 0.0;
    int segmentIndex = 0;
    for (int i = 0; i < segmentLengths.length; i++) {
      if (cumulativeLength + segmentLengths[i] >= currentLength) {
        segmentIndex = i;
        break;
      }
      cumulativeLength += segmentLengths[i];
    }

    double localProgress =
        (currentLength - cumulativeLength) / segmentLengths[segmentIndex];

    for (int i = 0; i < segmentIndex; i++) {
      double x1 = size.width * points![i].x / 100;
      double y1 = size.height * points![i].y / 100;
      double x2 = size.width * points![i + 1].x / 100;
      double y2 = size.height * points![i + 1].y / 100;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), animationPathPaint);
    }

    if (segmentIndex < points!.length - 1) {
      double startX = size.width * points![segmentIndex].x / 100;
      double startY = size.height * points![segmentIndex].y / 100;
      double endX = size.width * points![segmentIndex + 1].x / 100;
      double endY = size.height * points![segmentIndex + 1].y / 100;

      // 动态线段终点
      double currentX = startX + (endX - startX) * localProgress;
      double currentY = startY + (endY - startY) * localProgress;

      // 绘制动态线段
      canvas.drawLine(
        Offset(startX, startY),
        Offset(currentX, currentY),
        animationPathPaint,
      );

      // 动态行走点
      final Paint animationPaint = Paint()
        ..color = Colors.deepPurple
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
          Offset(currentX, currentY), 5.0 / scale, animationPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
