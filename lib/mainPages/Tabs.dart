import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/Navigation/IndoorNavigation.dart';
import 'package:parkinglot_frontend/Store/storeTotal.dart';
import 'package:parkinglot_frontend/mainPages/CarSearch.dart';
import 'package:parkinglot_frontend/RegisterAndLogin/AccountManagement.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; // 引入二维码扫描包
import 'package:parkinglot_frontend/QRcode/QRScanPage.dart';

class Tabs extends StatefulWidget{
  _TabsState createState()=>_TabsState();
}

class _TabsState extends State<Tabs>{
  int _currentIndex=0;
  //下面的三个方法都是三个界面的方法
  List _pageList=[
    IndoorNavigationPage(),
    StoreTotalPage(),
    CarPage(),
    accountPage()
  ];
  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: Text('停车场定位系统'),
          // 添加右上角扫描二维码的功能按钮
          actions: [
            IconButton(
              icon: Icon(Icons.qr_code_scanner),
              onPressed: () {
                // 跳转到二维码扫描页面
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScanPage()),
                );
              },
            ),
          ],
        ),
        /**
         *  切换底部导航栏的时候动态修改body内容
         */
        body:this._pageList[this._currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: this._currentIndex,
          //实现底部导航栏点击选中功能
          onTap: (int index){
//              this._currentIndex=index;//不会重新渲染
            setState(() {
              this._currentIndex=index;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                label: "地图导览"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: "店铺搜索"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.car_crash),
                label: "反向寻车"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "我的账户"
            ),
          ],
        ),
      );
  }
}
