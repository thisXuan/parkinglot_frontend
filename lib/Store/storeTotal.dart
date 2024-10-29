import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/api/store.dart';
import 'package:parkinglot_frontend/Store/storeSearch.dart';

// Store 模型类
class Store {
  int id;
  String storeName;
  String serviceCategory;
  String serviceType;
  String businessHours;
  String address;
  int floorNumber;
  String description;
  String recommendedServices;
  String image;

  Store(
      {required this.id,
      required this.storeName,
      required this.serviceCategory,
      required this.serviceType,
      required this.businessHours,
      required this.address,
      required this.floorNumber,
      this.description = '',
      this.recommendedServices = '',
      required this.image});

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
        id: json['id'],
        storeName: json['storeName'] ?? '',
        serviceCategory: json['serviceCategory'] ?? '',
        serviceType: json['serviceType'] ?? '',
        businessHours: json['businessHours'] ?? '',
        address: json['address'] ?? '天街商场',
        floorNumber: json['floorNumber'] ?? 0,
        description: json['description'] ?? '',
        recommendedServices: json['recommendedServices'] ?? '',
        image: json['image'] ?? '');
  }
}

class StoreTotalPage extends StatefulWidget {
  _StoreTotalPageState createState() => _StoreTotalPageState();
}

class _StoreTotalPageState extends State<StoreTotalPage> {
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
    _preloadImages();
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

  void _preloadImages() {
    for (var store in _storeInfo) {
      if (store.image.isNotEmpty) {
        precacheImage(NetworkImage(store.image), context);
      } else {
        precacheImage(AssetImage('assets/image_lost.jpg'), context);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 搜索框
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: '搜索商场内商户',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StoreSearchPage()),
              );
            },
            readOnly: true,
          ),
        ),
        // 列表
        Expanded(
          child: this._storeInfo.length > 0
              ? RefreshIndicator(
                  onRefresh: _fetchStoreInfo,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _storeInfo.length,
                    itemBuilder: (context, index) {
                      var store = _storeInfo[index];
                      if (index == this._storeInfo.length - 1) {
                        return Column(
                          children: <Widget>[
                            ListTile(
                              title: Text(store.storeName),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("${store.serviceCategory}+“ ”+${store.serviceType}"),
                                      Text("营业中：${store.businessHours}"),
                                      Text("${store.address}"),
                                      Text("${store.floorNumber}F"),
                                    ],
                                  ),
                                  store.image.isNotEmpty
                                      ? Image.network(store.image, width: 80)
                                      : Image.asset('assets/image_lost.jpg',
                                          width: 100),
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
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(store.serviceCategory+"  "+store.serviceType),
                                      Text("营业中：${store.businessHours}"),
                                      Text("${store.address}"),
                                      Text("${store.floorNumber}F"),
                                    ],
                                  ),
                                  store.image.isNotEmpty
                                      ? Image.network(store.image, width: 80)
                                      : Image.asset('assets/image_lost.jpg',
                                          width: 100),
                                ],
                              ),
                            ),
                            Divider(),
                          ],
                        );
                      }
                    },
                  ),
                )
              : _getMoreWidget(),
        ),
      ],
    );
  }

  //加载中的圈圈
  Widget _getMoreWidget() {
    if (_hasMore) {
      return Center(
        child: Padding(
            padding: EdgeInsets.all(10.0),
            child: CircularProgressIndicator(
              strokeWidth: 1.0,
            )),
      );
    } else {
      return Center(
        child: Text("--我是有底线的--"),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _storeInfo = [];
  }
}
