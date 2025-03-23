import '../utils/request.dart';

// 创建一个关于store相关请求的对象
class DataApi {
  static DataApi? _instance;

  factory DataApi() => _instance ?? DataApi._internal();

  static DataApi? get instance => _instance ?? DataApi._internal();

  // 初始化
  DataApi._internal() {
    // 初始化基本选项
  }

  TotalView() async{
    var result = await Request().request("/data/TotalView",
        method: DioMethod.get);
    return result;
  }

  SalesAnalysis() async{
    var result = await Request().request("/data/salesAnalysis",
        method: DioMethod.get);
    return result;
  }

  OrderAnalysis() async{
    var result = await Request().request("/data/orderAnalysis",
        method: DioMethod.get);
    return result;
  }

  UserAnalysis() async{
    var result = await Request().request("/data/userAnalysis",
        method: DioMethod.get);
    return result;
  }
}

// 导出全局使用这一个实例
final voucherApi = DataApi();