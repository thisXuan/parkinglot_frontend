import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parkinglot_frontend/utils/util.dart';

enum DioMethod {
  get,
  post,
  put,
  delete,
  patch,
  head,
}
 
// 创建请求类：封装dio
class Request {
  /// 单例模式
  static Request? _instance;
 
  // 工厂函数：执行初始化
  factory Request() => _instance ?? Request._internal();
 
  // 获取实例对象时，如果有实例对象就返回，没有就初始化
  static Request? get instance => _instance ?? Request._internal();
 
  /// Dio实例
  static Dio _dio = Dio();
 
  /// 初始化
  Request._internal() {
    // 初始化基本选项
    BaseOptions options = BaseOptions(
        baseUrl: 'http://192.168.1.175:8081',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5));
    _instance = this;
    // 初始化dio
    _dio = Dio(options);
    // 添加拦截器
    _dio.interceptors.add(InterceptorsWrapper(
        onRequest: _onRequest, onResponse: _onResponse, onError: _onError));
  }
 
  /// 请求拦截器
  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) async{
    // 头部添加token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson != null) {
      Map<String, String> userInfo = Map<String, String>.from(jsonDecode(userJson));
      String token = userInfo['token'] ?? '';
      options.headers['Authorization'] = token; // 往请求头加token
    }
    // 更多业务需求
    handler.next(options);
    // super.onRequest(options, handler);
  }
 
  /// 相应拦截器
  void _onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    // 请求成功是对数据做基本处理
    if (response.statusCode == 200) {
      // 处理成功的响应
      print("响应结果: $response");
    } else {
      // 处理异常结果
      print("响应异常: $response");
    }
    handler.next(response);
  }
 
  /// 错误处理: 网络错误等
  void _onError(DioException error, ErrorInterceptorHandler handler) {
    final response = error.response;
    final httpStatus = error.response?.statusCode;
    if (httpStatus == null) {
      ElToast.info('服务器暂时无法响应，请稍后再试');
    } else {
      switch (httpStatus) {
        case 401:
          ElToast.info('登录状态失效，请重新登录');
          break;
        case 500:
          final code = response?.data['code'];
          switch (code) {
          // 无权访问跳转到首页
            case 402:
              ElToast.info('您无权访问该资源');
              break;
          // 服务器出错
            default:
              ElToast.info('服务器暂时无法响应，请稍后再试');
              break;
          }
      }
    }
    //handler.next(error);
    handler.reject(error);
  }

  /// 显示加载动画
  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  /// 隐藏加载动画
  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

 
  /// 请求类：支持异步请求操作
  Future<T>  request<T>(
    String path, {
      required BuildContext context,
    DioMethod method = DioMethod.get,
    Map<String, dynamic>? params,
    dynamic data,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    const _methodValues = {
      DioMethod.get: 'get',
      DioMethod.post: 'post',
      DioMethod.put: 'put',
      DioMethod.delete: 'delete',
      DioMethod.patch: 'patch',
      DioMethod.head: 'head'
    };
    // 默认配置选项
    options ??= Options(method: _methodValues[method]);
    showLoadingDialog(context);
    try {
      Response response;
      // 开始发送请求
      response = await _dio.request(path,
          data: data,
          queryParameters: params,
          cancelToken: cancelToken,
          options: options,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);
      return response.data;
    } on DioException catch (e) {
      print("发送请求异常: $e");
      rethrow;
    }finally{
      hideLoadingDialog(context);
    }
  }

  /// 开启日志打印
  /// 需要打印日志的接口在接口请求前 Request.instance?.openLog();
  void openLog() {
    _dio.interceptors
        .add(LogInterceptor(responseHeader: false, responseBody: true));
  }

}
