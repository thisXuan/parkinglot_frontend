import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; // 引入二维码扫描包

class QRScanPage extends StatefulWidget {
  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isCameraInitialized = false;

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

  void _onQRViewCreated(QRViewController controller) {
    if (!_isCameraInitialized) {
      this.controller = controller;
      _isCameraInitialized = true;

      controller.scannedDataStream.listen((scanData) {
        print('扫描结果: ${scanData.code}');
        controller.pauseCamera(); // 暂停相机，避免重复扫描

        // 导航到显示结果页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ParkingLocationPage(location: scanData.code ?? "未知点位"),
          ),
        ).then((_) {
          Navigator.pop(context); // 返回到再早的页面
        });
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
