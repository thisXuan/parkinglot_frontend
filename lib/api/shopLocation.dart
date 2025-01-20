import '../utils/request.dart';

class ShopLocationApi {
  static ShopLocationApi? _instance;

  factory ShopLocationApi() => _instance ?? ShopLocationApi._internal();

  static ShopLocationApi? get instance => _instance ?? ShopLocationApi._internal();

  // 初始化
  ShopLocationApi._internal() {
    // 初始化基本选项
  }

  GetShopsByFloor(dynamic data) async {
    var result = await Request().request("/shopLocation/byFloor?floor=$data",
        method: DioMethod.get,
        data:data);
    return result;
  }

}

// 导出全局使用这一个实例
final shopLocationAPI = ShopLocationApi();  