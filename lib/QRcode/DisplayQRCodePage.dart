import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:qr_flutter/qr_flutter.dart';

class DisplayQRCodePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String content = "A40"; // 二维码内容

    return Scaffold(
      appBar: AppBar(
        title: Text('显示二维码'),
      ),
      body: Center(
        child: CustomPaint(
          size: Size(200, 200), // 设置二维码的大小
          painter: QrPainter(
            data: content,
            version: QrVersions.auto,
            gapless: false,
            color: Color(0xFF000000), // 设置二维码颜色
            emptyColor: Color(0xFFFFFFFF), // 设置背景颜色
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: DisplayQRCodePage(),
  ));
}