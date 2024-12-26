import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/Tabs.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Tabs(),
      builder: EasyLoading.init(),
    );
  }
}
