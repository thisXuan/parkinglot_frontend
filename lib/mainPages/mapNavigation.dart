import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_bmflocation/flutter_bmflocation.dart';

class IndoorMapPage extends StatefulWidget {
  @override
  _IndoorMapPageState createState() => _IndoorMapPageState();
}

class _IndoorMapPageState extends State<IndoorMapPage> {
  BMFMapController? _mapController;
  String? _indoorId; // 用于存储当前室内图的ID
  List<BMFCoordinate> _coordinateList = [];
  List<String> _floors = []; // 存储楼层信息

  @override
  void initState() {
    super.initState();
    // 初始化坐标点列表
    _coordinateList.add(BMFCoordinate(29.606124, 106.496405));
    _coordinateList.add(BMFCoordinate(29.604526, 106.496465));
    _coordinateList.add(BMFCoordinate(29.604569, 106.494309));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: BMFMapWidget(
          onBMFMapCreated: onMapCreated,
          mapOptions: BMFMapOptions(
            center: BMFCoordinate(29.605333, 106.495935), // 设置地图中心点为围栏中心
            zoomLevel: 18, // 设置缩放级别，室内地图最大支持22级
            mapPadding: BMFEdgeInsets(left: 30, top: 30, right: 30, bottom: 30),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 显示楼层选择菜单
          showFloorsDialog();
        },
        child: Icon(Icons.layers),
      ),
    );
  }

  void onMapCreated(BMFMapController controller) {
    _mapController = controller;
    _mapController?.showBaseIndoorMap(true); // 显示室内地图

    // 设置监听事件来监听进入和移出室内图
    _mapController?.setMapInOrOutBaseIndoorMapCallback(
      callback: (bool flag, BMFBaseIndoorMapInfo baseIndoorMapInfo) {
        setState(() {
          if (flag) {
            // 进入室内图
            _indoorId = baseIndoorMapInfo.strID; // 获取indoorId
            _floors = baseIndoorMapInfo.listStrFloors!; // 获取楼层信息
            print('进入室内图，ID: $_indoorId');
          } else {
            // 离开室内图
            _indoorId = null;
            _floors = [];
            print('离开室内图');
          }
        });
      },
    );
  }

  void showFloorsDialog() {
    if (_floors.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('选择楼层'),
            children: _floors.map((floor) {
              return SimpleDialogOption(
                child: Text(floor),
                onPressed: () {
                  Navigator.pop(context);
                  switchFloor(floor);
                },
              );
            }).toList(),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('暂无楼层信息')),
      );
    }
  }

  void switchFloor(String floorId) {
    if (_mapController != null && _indoorId != null) {
      _mapController?.switchBaseIndoorMapFloor(floorId, _indoorId!);
    }
  }
}