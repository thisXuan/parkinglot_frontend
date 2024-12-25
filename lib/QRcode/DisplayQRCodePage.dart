import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DisplayQRCodePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String content = "A10"; // 二维码内容

    return Scaffold(
      appBar: AppBar(
        title: Text('显示二维码'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 展示二维码内容
            Text(
              content,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10), // 间距
            // 显示二维码
            QrImageView(
              data: content,
              version: QrVersions.auto,
              size: 200.0, // 设置二维码的大小
              gapless: false,
              backgroundColor: Colors.white, // 设置二维码背景颜色
            ),
          ],
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
