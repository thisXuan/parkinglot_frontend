import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/Manager/ManagerTab.dart';
import 'package:parkinglot_frontend/Tabs.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:parkinglot_frontend/api/user.dart';
import 'package:tencent_cloud_chat_uikit/tencent_cloud_chat_uikit.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';

void main() {
  // if (Platform.isIOS) {
  //   BMFMapSDK.setApiKeyAndCoordType(
  //       '请在此输入您在开放平台上申请的API_KEY', BMF_COORD_TYPE.BD09LL);
  // } else if (Platform.isAndroid) {
  //   /// 初始化获取Android 系统版本号，如果低于10使用TextureMapView 等于大于10使用Mapview
  //   await BMFAndroidVersion.initAndroidVersion();
  //   // Android 目前不支持接口设置Apikey,
  //   // 请在主工程的Manifest文件里设置，详细配置方法请参考官网(https://lbsyun.baidu.com/)demo
  //   BMFMapSDK.setCoordType(BMF_COORD_TYPE.BD09LL);
  // }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<int> getUserRole() async {
    var result = await UserApi().GetUserRole();
    if (result != null) {
      if (result['code'] == 200) {
        print(result['data']);
        return result['data'];
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  }

  final CoreServicesImpl _coreInstance = TIMUIKitCore.getInstance();
  @override
  void initState() {
    _coreInstance.init(
        sdkAppID: 1600083654, // Replace 0 with the SDKAppID of your IM application when integrating
        //language: LanguageEnum.zhHant, // 界面语言配置，若不配置，则跟随系统语言
        loglevel: LogLevelEnum.V2TIM_LOG_DEBUG,
        onTUIKitCallbackListener:  (TIMCallback callbackValue){}, // [建议配置，详见此部分](https://cloud.tencent.com/document/product/269/70746#callback)
        listener: V2TimSDKListener());
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: AppBarTheme(scrolledUnderElevation: 0.0)
      ),
      home: FutureBuilder<int>(
        future: getUserRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            // 根据不同的用户角色返回不同的主页面
            final userRole = snapshot.data ?? 0;
            if (userRole == 1) {
              return ManagerTab();
            } else if (userRole == 2) {
              // 如果有其他角色，可以在这里添加更多条件
              return Tabs(); // 或者其他针对角色2的页面
            } else {
              return Tabs(); // 默认页面
            }
          }
        },
      ),
      builder: EasyLoading.init(),
    );
  }
}
