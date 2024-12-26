import '../utils/request.dart';

class ParkingApi {
  /// 单例模式
  static ParkingApi? _instance;

  // 工厂函数：初始化，默认会返回唯一的实例
  factory ParkingApi() => _instance ?? ParkingApi._internal();

  // 用户Api实例：当访问UserApi的时候，就相当于使用了get方法来获取实例对象，如果_instance存在就返回_instance，不存在就初始化
  static ParkingApi? get instance => _instance ?? ParkingApi._internal();

  // 初始化
  ParkingApi._internal() {
    // 初始化基本选项
  }

  // 获取用户停车时间和停车位置
  GetParkingTimeAndLocation(dynamic data) async {
    var result = await Request().request("/parking/getParkingTimeAndLocation?carName=$data",
        method: DioMethod.get);
    return result;
  }

  // 获取缴费记录
  GetPayment() async{
    var result = await Request().request("/parking/getPayment",
        method: DioMethod.get);
    return result;
  }

  // 获取我的车辆信息
  GetMyCar() async{
    var result = await Request().request("/parking/getMyCar",
        method: DioMethod.get);
    return result;
  }

}

// 导出全局使用这一个实例
final parkingApi = ParkingApi();