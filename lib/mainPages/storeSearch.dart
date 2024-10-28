import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/api/store.dart';

// Store 模型类
class Store {
  final int id;
  final String storeName;
  final String serviceCategory;
  final String serviceType;
  final String businessHours;
  final String address;
  final int floorNumber;
  final String description;
  final String recommendedServices;

  Store({
    required this.id,
    required this.storeName,
    required this.serviceCategory,
    required this.serviceType,
    required this.businessHours,
    required this.address,
    required this.floorNumber,
    this.description = '',
    this.recommendedServices = '',
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      storeName: json['storeName'] ?? '',
      serviceCategory: json['serviceCategory'] ?? '',
      serviceType: json['serviceType'] ?? '',
      businessHours: json['businessHours'] ?? '',
      address: json['address'] ?? '',
      floorNumber: json['floorNumber'] ?? 0,
      description: json['description'] ?? '',
      recommendedServices: json['recommendedServices'] ?? '',
    );
  }
}

class StoreSearchPage extends StatefulWidget {
  _StoreSearchPageState createState() => _StoreSearchPageState();
}

class _StoreSearchPageState extends State<StoreSearchPage> {
  List<Store> _storeInfo = [];
  int _page = 1;
  bool _hasMore = true; //判断有没有数据
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    this._fetchStoreInfo();
    //监听滚动条事件
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 40) {
        this._fetchStoreInfo();
      }
    });
  }

  Future<void> _fetchStoreInfo() async {
    if (this._hasMore) {
      var result = await StoreApi().GetStoreInfo(_page);
      if (result != null && result['code'] == 200 && result['data'] != null) {
        setState(() {
          _storeInfo.addAll((result['data'] as List)
              .map((json) => Store.fromJson(json))
              .toList());
          _page++;
        });
      }
      List<Store> storeList =
          (result['data'] as List).map((json) => Store.fromJson(json)).toList();
      //判断是否是最后一页
      if (storeList.length < 10) {
        setState(() {
          this._hasMore = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await Future.delayed(Duration(milliseconds: 2000), () {
      print('请求数据完成');
      _fetchStoreInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: this._storeInfo.length > 0
            ? RefreshIndicator(
                onRefresh: _refreshData,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _storeInfo.length,
                  itemBuilder: (context, index) {
                    var store = _storeInfo[index];
                    if (index == this._storeInfo.length - 1) {
                      //列表渲染到最后一条的时候加一个圈圈
                      //拉到底
                      return Column(
                        children: <Widget>[
                          ListTile(
                            title: Text(store.storeName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Category: ${store.serviceCategory}"),
                                Text("Type: ${store.serviceType}"),
                                Text("Hours: ${store.businessHours}"),
                                Text("Address: ${store.address}"),
                                Text("Floor: ${store.floorNumber}"),
                              ],
                            ),
                          ),
                          Divider(),
                          _getMoreWidget()
                        ],
                      );
                    } else {
                      return Column(
                        children: <Widget>[
                          ListTile(
                            title: Text(store.storeName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Category: ${store.serviceCategory}"),
                                Text("Type: ${store.serviceType}"),
                                Text("Hours: ${store.businessHours}"),
                                Text("Address: ${store.address}"),
                                Text("Floor: ${store.floorNumber}"),
                              ],
                            ),
                          ),
                          Divider()
                        ],
                      );
                    }
                  },
                ),
              )
            : _getMoreWidget());
  }

  //加载中的圈圈
  Widget _getMoreWidget() {
    if (_hasMore) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child:  CircularProgressIndicator(
            strokeWidth: 1.0,
          )
        ),
      );
    } else {
      return Center(
        child: Text("--我是有底线的--"),
      );
    }
  }
}
