import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/mainPages/mapNavigation.dart';
import 'package:parkinglot_frontend/mainPages/storeSearch.dart';
import 'package:parkinglot_frontend/mainPages/discountSearch.dart';
import 'package:parkinglot_frontend/mainPages/AccountManagement.dart';

class Tabs extends StatefulWidget{
  _TabsState createState()=>_TabsState();
}

class _TabsState extends State<Tabs>{
  int _currentIndex=0;
  //下面的三个方法都是三个界面的方法
  List _pageList=[
    IndoorMapPage(),
    StoreSearchPage(),
    discountPage(),
    accountPage()
  ];
  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: Text('停车场定位系统'),
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
                icon: Icon(Icons.discount),
                label: "今日折扣"
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
