import '../utils/request.dart';

// 创建一个关于store相关请求的对象
class VoucherApi {
  static VoucherApi? _instance;

  factory VoucherApi() => _instance ?? VoucherApi._internal();

  static VoucherApi? get instance => _instance ?? VoucherApi._internal();

  // 初始化
  VoucherApi._internal() {
    // 初始化基本选项
  }

  GetVoucherByShopId(dynamic data) async {
    var result = await Request().request("/voucher/getVoucherByShopId?shopId=$data",
        method: DioMethod.get);
    return result;
  }


}

// 导出全局使用这一个实例
final voucherApi = VoucherApi();