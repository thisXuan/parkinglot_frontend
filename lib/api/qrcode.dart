import 'package:dio/dio.dart';
import '../utils/request.dart';

// 创建一个关于 QRCode 相关请求的对象
class QRCodeApi {
  static QRCodeApi? _instance;

  // 使用工厂模式保证全局只有一个实例
  factory QRCodeApi() => _instance ?? QRCodeApi._internal();

  static QRCodeApi get instance => _instance ?? QRCodeApi._internal();

  // 初始化
  QRCodeApi._internal() {
    // 任何需要初始化的逻辑可以放在这里
  }

  // 传输扫描后的二维码内容
  Future<dynamic> sendQRCodeContent(String qrCodeContent, String token) async {
    print("准备发送POST请求:");
    print("路径: /qrcode/submit");
    print("数据: $qrCodeContent");
    print("Token: $token");

    try {
      var result = await Request().request(
        "/qrcode/submit",
        method: DioMethod.post,
        data: {
          "qrCodeContent": qrCodeContent,
        },
      );
      print("请求成功: $result");
      return result;
    } catch (e) {
      print("请求失败: $e");
      rethrow;
    }
  }
}
