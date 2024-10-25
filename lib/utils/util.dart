import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// 加载动画
void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // 禁止点击空白区域关闭
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent, // 背景透明
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(), // 转圈动画
            SizedBox(height: 15),
            Text("加载中...", style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    },
  );
}

// 公共消息弹窗
class ElToast {
  static Map<String, dynamic> colors = {
    'success': {
      'bgColor': const Color.fromRGBO(240, 249, 235, 1),
      'textColor': const Color.fromRGBO(149, 212, 117, 1.0)
    },
    'info': {'bgColor': Colors.black12, 'textColor': Colors.white70},
    'warning': {
      'bgColor': const Color.fromRGBO(253, 246, 236, 1),
      'textColor': const Color.fromRGBO(238, 190, 119, 1.0)
    },
    'error': {
      'bgColor': const Color.fromRGBO(254, 240, 240, 1),
      'textColor': const Color.fromRGBO(248, 152, 152, 1.0)
    }
  };

  static setType(String type) {
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorColor = Colors.white
      ..backgroundColor = colors[type]['bgColor']
      ..textColor = colors[type]['textColor']
      ..contentPadding = const EdgeInsets.symmetric(vertical: 8, horizontal: 8);
  }

  static show(String type, String msg) {
    setType(type);
    EasyLoading.showToast(msg, toastPosition: EasyLoadingToastPosition.bottom);
  }

  static success(String msg) {
    show('success', msg);
  }

  static info(String msg) {
    show('info', msg);
  }

  static warning(String msg) {
    show('warning', msg);
  }

  static error(String msg) {
    show('error', msg);
  }
}