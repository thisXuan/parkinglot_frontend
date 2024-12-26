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

class StoreSelectPage extends StatefulWidget {
  final String category;

  StoreSelectPage({Key? key, required this.category}) : super(key: key);

  @override
  _StoreSelectPageState createState() => _StoreSelectPageState();
}

class _StoreSelectPageState extends State<StoreSelectPage> {
  List<Store> _storeInfo = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStoreInfo();
  }

  Future<void> _fetchStoreInfo() async {
    // 根据传入的类别参数获取店铺信息
    String category = widget.category;
    var result = await StoreApi().GetServiceCategory(category);
    if (result != null) {
      var data = result['data'];
      if (data != null) {
        setState(() {
          _storeInfo =
              (data as List).map((json) => Store.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _storeInfo.length,
              itemBuilder: (context, index) {
                var store = _storeInfo[index];
                return ListTile(
                  title: Text(store.storeName),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          : Image.asset('assets/image_lost.jpg', width: 100),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
