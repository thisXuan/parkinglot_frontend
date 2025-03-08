import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/AccountManager/Account.dart';
import 'package:parkinglot_frontend/AccountManager/PersonalInfoPage.dart';
import 'package:parkinglot_frontend/Manager/ManageLocationPage.dart';
import 'package:parkinglot_frontend/Manager/ManagerPersonPage.dart';
import 'package:parkinglot_frontend/Manager/ManagerSettingPage.dart';
import 'package:parkinglot_frontend/Navigation/IndoorNavigation.dart';
import 'package:parkinglot_frontend/Store/StoreSelection.dart';
import 'package:parkinglot_frontend/CarSearch/CarSearch.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; // 引入二维码扫描包
import 'package:parkinglot_frontend/QRcode/QRScanPage.dart';

class ManagerTab extends StatefulWidget{
  String? location;

  ManagerTab({this.location, Key? key}) : super(key: key);

  _TabsState createState()=>_TabsState();
}

class _TabsState extends State<ManagerTab>{
  int _currentIndex=0;
  //下面的三个方法都是三个界面的方法
  List _pageList=[];
  List<String> titles = ["管理商铺","管理用户","账号管理"];

  @override
  void initState() {
    super.initState();
    _pageList=[
      ManageLocationPage(),
      ManagerPersonPage(),
      ManagerSettingPage()
    ];
  }
  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(titles[_currentIndex]),
          centerTitle: true,
          automaticallyImplyLeading: false,
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
                icon: Icon(Icons.shop),
                label: "管理商铺"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.man),
                label: "管理用户"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: "账号管理"
            ),
          ],
        ),
      );
  }
}
