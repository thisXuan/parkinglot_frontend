import 'package:flutter/cupertino.dart';

import '../utils/request.dart';

// 创建一个关于store相关请求的对象
class StoreApi {
  static StoreApi? _instance;

  factory StoreApi() => _instance ?? StoreApi._internal();

  static StoreApi? get instance => _instance ?? StoreApi._internal();

  // 初始化
  StoreApi._internal() {
    // 初始化基本选项
  }

  // 登录
  GetStoreInfo(dynamic data) async {
    var result = await Request().request("/store/getStoreInfo?page=$data",
        method: DioMethod.get);
    return result;
  }

}

// 导出全局使用这一个实例
final storeApi = StoreApi();