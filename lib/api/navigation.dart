import '../utils/request.dart';

// 创建一个关于store相关请求的对象
class NavigationApi {
  static NavigationApi? _instance;

  factory NavigationApi() => _instance ?? NavigationApi._internal();

  static NavigationApi? get instance => _instance ?? NavigationApi._internal();

  // 初始化
  NavigationApi._internal() {
    // 初始化基本选项
  }

  GetPath(dynamic data, dynamic mode) async {
    var result = await Request().request("/navigation/getPath?mode=$mode",
        method: DioMethod.get,
        data:data);
    return result;
  }

}

// 导出全局使用这一个实例
final navigationAPI = NavigationApi();