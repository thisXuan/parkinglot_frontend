import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';

class SaveQRCodeToFilePage extends StatelessWidget {
  // 生成二维码并保存为图片
  Future<void> saveQRCode(String content) async {
    try {
      // 生成二维码图像
      final qrCodeImage = await QrPainter(
        data: content,
        version: QrVersions.auto,
      ).toImage(200.0);

      // 获取桌面目录路径（根据不同操作系统，路径会有所不同）
      final directory = await getApplicationDocumentsDirectory();

      // 保存文件路径
      final filePath = '${directory.path}/$content.png';
      final file = File(filePath);

      // 保存图片到文件
      final byteData = await qrCodeImage.toByteData(format: ImageByteFormat.png);

      // 只有在 byteData 不为 null 时才能执行以下操作
      if (byteData != null) {
        await file.writeAsBytes(byteData.buffer.asUint8List());
        print('二维码已保存到: $filePath');
      } else {
        print('二维码图像的字节数据为空');
      }
    } catch (e) {
      print('保存二维码失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String content = "A20"; // 二维码内容

    return Scaffold(
      appBar: AppBar(
        title: Text('保存二维码到文件夹'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await saveQRCode(content); // 调用保存二维码的函数
          },
          child: Text('保存二维码'),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SaveQRCodeToFilePage(),
  ));
}
