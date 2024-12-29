import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/AccountManager/Account.dart';
import 'package:parkinglot_frontend/Navigation/IndoorNavigation.dart';
import 'package:parkinglot_frontend/Store/StoreSelection.dart';
import 'package:parkinglot_frontend/CarSearch/CarSearch.dart';
import 'package:parkinglot_frontend/AccountManager/AccountManagement.dart';
import 'package:parkinglot_frontend/AccountManager/Account.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; // 引入二维码扫描包
import 'package:parkinglot_frontend/QRcode/QRScanPage.dart';

class Tabs extends StatefulWidget{
  String? location;

  Tabs({this.location, Key? key}) : super(key: key);

  _TabsState createState()=>_TabsState();
}

class _TabsState extends State<Tabs>{
  int _currentIndex=0;
  //下面的三个方法都是三个界面的方法
  List _pageList=[];
  List<String> titles = ["地图导览","品牌筛选","停车缴费","我的账户"];

  @override
  void initState() {
    super.initState();
    _pageList=[
      IndoorNavigationPage(location: widget.location,),
      BrandSelectionPage(),
      CarPage(),
      //accountPage()
      MemeberPage()
    ];
  }
  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(titles[_currentIndex]),
          automaticallyImplyLeading: false,
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
