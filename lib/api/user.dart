import '../utils/request.dart';

// 创建一个关于user相关请求的对象
class UserApi {
  /// 单例模式
  static UserApi? _instance;

  // 工厂函数：初始化，默认会返回唯一的实例
  factory UserApi() => _instance ?? UserApi._internal();

  // 用户Api实例：当访问UserApi的时候，就相当于使用了get方法来获取实例对象，如果_instance存在就返回_instance，不存在就初始化
  static UserApi? get instance => _instance ?? UserApi._internal();

  // 初始化
  UserApi._internal() {
    // 初始化基本选项
  }

  // 登录
  Login(dynamic data) async {
    var result = await Request().request("/user/login",
        method: DioMethod.post,
        data: data);
    return result;
  }

  // 注册
  Register(dynamic data) async {
    var result = await Request().request("/user/register",
        method: DioMethod.post,
        data: data);
    return result;
  }

  // 重置密码
  ForgetPassword(dynamic data) async {
    var result = await Request().request("/user/reset-password",
        method: DioMethod.post,
        data: data);
    return result;
  }
}

// 导出全局使用这一个实例
final userApi = UserApi();
