import 'package:flutter/material.dart';


// 展示栏
void showInfoDialog(BuildContext context, String content) {
  showDialog(
    context: context,
    builder: (context) {
      return SimpleDialog(
        children: <Widget>[
          SimpleDialogOption(
            child: Text(content),
          )
        ],
      );
    },
  );
}

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