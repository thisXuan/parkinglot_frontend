import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 导入 shared_preferences 包
import '../api/qrcode.dart'; // 引入二维码扫描包
import 'dart:convert';
import 'package:parkinglot_frontend/api/qrcode.dart';

class QRScanPage extends StatefulWidget {
  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isCameraInitialized = false;

  //final QRCodeApi qrcode = QRCodeApi();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('扫描二维码'),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }

  // void _onQRViewCreated(QRViewController controller) {
  //   if (!_isCameraInitialized) {
  //     this.controller = controller;
  //     _isCameraInitialized = true;
  //
  //     controller.scannedDataStream.listen((scanData) {
  //       print('扫描结果: ${scanData.code}');
  //       controller.pauseCamera(); // 暂停相机，避免重复扫描
  //
  //       // 导航到显示结果页面
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => ParkingLocationPage(location: scanData.code ?? "未知点位"),
  //         ),
  //       ).then((_) {
  //         Navigator.pop(context); // 返回到再早的页面
  //       });
  //     });
  //   }
  // }

  bool _isProcessing = false;  // 用于标记是否正在处理扫描结果

  void _onQRViewCreated(QRViewController controller) {
    if (!_isCameraInitialized) {
      this.controller = controller;
      _isCameraInitialized = true;

      controller.scannedDataStream.listen((scanData) async {
        // 如果正在处理，就不再进行扫描
        if (_isProcessing) return;

        _isProcessing = true;  // 标记为正在处理
        print('扫描结果: ${scanData.code}');
        controller.pauseCamera(); // 暂停相机，避免重复扫描

        // 获取存储的 token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('user') != null
            ? jsonDecode(prefs.getString('user')!)['token']
            : null;

        if (token != null) {
          // 发送扫描结果和 token 到后端
          try {
            print(scanData.code);
            print(token);
            print("准备调用 sendQRCodeContent 方法...");
            var response = await QRCodeApi().sendQRCodeContent(scanData.code ?? "", token);
            print("sendQRCodeContent 方法调用结束");

            //var response = await QRCodeApi().sendQRCodeContent(scanData.code ?? "", token); // 传递 token
            //print('服务器返回: $response');
            print(scanData.code);
            print(token);

            // 如果发送成功，导航到显示结果页面
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ParkingLocationPage(location: scanData.code ?? "未知点位"),
              ),
            ).then((_) {
              controller.resumeCamera(); // 返回时恢复相机
              _isProcessing = false;  // 重置处理标志
            });
          } catch (e) {
            print('发送失败: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('发送二维码内容失败，请重试')),
            );
            controller.resumeCamera(); // 发送失败也恢复相机
            _isProcessing = false;  // 重置处理标志
          }
        } else {
          print('Token 未找到');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('未找到 Token，请重新登录')),
          );
          controller.resumeCamera(); // 发送失败也恢复相机
          _isProcessing = false;  // 重置处理标志
        }
      });
    }
  }

  @override
  void deactivate() {
    controller?.pauseCamera(); // 页面切换时暂停相机
    super.deactivate();
  }

  @override
  void dispose() {
    controller?.dispose(); // 释放资源
    super.dispose();
  }
}

class ParkingLocationPage extends StatelessWidget {
  final String location;

  ParkingLocationPage({required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('停车位信息'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '你已在停车场 $location 点位',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 返回到之前的页面
              },
              child: Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}
