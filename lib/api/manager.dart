import '../utils/request.dart';

// 创建一个关于store相关请求的对象
class ManagerApi {
  static ManagerApi? _instance;

  factory ManagerApi() => _instance ?? ManagerApi._internal();

  static ManagerApi? get instance => _instance ?? ManagerApi._internal();

  // 初始化
  ManagerApi._internal() {
    // 初始化基本选项
  }

  Change(dynamic data) async {
    var result = await Request().request("/manager/change",
        method: DioMethod.post,
        data:data
    );
    return result;
  }

}

// 导出全局使用这一个实例
final navigationAPI = ManagerApi();