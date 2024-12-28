import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/api/store.dart';
import 'package:parkinglot_frontend/utils/util.dart';

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
        address: json['address'] ?? '',
        floorNumber: json['floorNumber'] ?? 0,
        description: json['description'] ?? '',
        recommendedServices: json['recommendedServices'] ?? '',
        image: json['image'] ?? '');
  }
}

class StoreSearchPage extends StatefulWidget {
  _StoreSearchPageState createState() => _StoreSearchPageState();
}

class _StoreSearchPageState extends State<StoreSearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<Store> _searchResults = [];

  Future<void> _performSearch(String data) async {
    var result = await StoreApi().QueryStoreInfo(data);
    if (result != null && result['code'] == 200 && result['data'] != null) {
      setState(() {
        _searchResults = (result['data'] as List)
            .map((json) => Store.fromJson(json))
            .toList();
      });
    }else{
      ElToast.info(result['msg']);
      setState(() {
        _searchResults = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("搜索"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '输入搜索内容',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    if(_searchController.text.isEmpty){
                      ElToast.info("请输入想要搜索的内容");
                      return;
                    }
                    _performSearch(_searchController.text);
                  }, // 点击按钮执行搜索
                )
              ],
            ),
          ),
          Expanded(
            child: _searchResults.isNotEmpty
                ? ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      var store = _searchResults[index];
                      if (index == this._searchResults.length - 1) {
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
                                      Text("服务类型: ${store.serviceCategory}"),
                                      Text("具体种类: ${store.serviceType}"),
                                      Text("营业时间: ${store.businessHours}"),
                                      Text("店铺位置: ${store.address}"),
                                      Text("所处楼层: ${store.floorNumber}F"),
                                    ],
                                  ),
                                  store.image.isNotEmpty
                                      ? Image.network(store.image, width: 100)
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
                                      Text("服务类型: ${store.serviceCategory}"),
                                      Text("具体种类: ${store.serviceType}"),
                                      Text("营业时间: ${store.businessHours}"),
                                      Text("店铺位置: ${store.address}"),
                                      Text("所处楼层: ${store.floorNumber}F"),
                                    ],
                                  ),
                                  store.image.isNotEmpty
                                      ? Image.network(store.image, width: 100)
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
                  )
                : const Center(
                    child: Text(
                      '无结果',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _getMoreWidget() {
    return Center(
      child: Text("--我是有底线的--"),
    );
  }
}
