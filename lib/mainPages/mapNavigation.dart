import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';

class MapPage extends StatefulWidget {
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  BMFMapOptions mapOptions = BMFMapOptions(
      center: BMFCoordinate(39.917215, 116.380341),
      zoomLevel: 12,
      mapPadding: BMFEdgeInsets(left: 30, top: 0, right: 30, bottom: 0));

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: window.physicalSize.height,
      width: window.physicalSize.width,
      child: BMFMapWidget(
        onBMFMapCreated: (controller) {
          //onBMFMapCreated(controller);
        },
        mapOptions: mapOptions,
      ),
    );
  }
}
