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
        businessHours: json['businessHours'] ?? '营业时间未知',
        address: json['address'] ?? '',
        floorNumber: json['floorNumber'] ?? 0,
        description: json['description'] ?? '',
        recommendedServices: json['recommendedServices'] ?? '',
        image: json['image'] ?? '');
  }
}

class StoreDetailPage extends StatefulWidget {
  final int storeId;

  const StoreDetailPage({Key? key, required this.storeId}) : super(key: key);

  @override
  _StoreDetailPageState createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage> {
  late Map<String, dynamic> _storeData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStoreData(widget.storeId);
  }

  // 模拟获取店铺数据
  void _fetchStoreData(int storeId) async {
    var result = await StoreApi().GetStoreInfoById(storeId);
    if (result != null) {
      var code = result['code'];
      var msg = result['msg'];
      var data = result['data'];
      if (code == 200) {
        Store store = Store.fromJson(data);
        setState(() {
          _storeData = {
            "storeName": store.storeName,
            "storeCategory": store.serviceCategory,
            "businessHours": store.businessHours,
            "storeLocation": store.address,
            "vipPrivilege": "V2-V5琉珠用户 花琉珠膨胀特权",
            "tags": ["赚琉珠", "消费20元返1琉珠", "花琉珠"],
            "imageUrl": store.image,
          };
          _isLoading = false;
        });
      } else {
        ElToast.info(msg);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("品牌详情"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 店铺 Logo 区域
                Container(
                  color: Colors.grey[100],
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: Image.network(
                    _storeData['imageUrl'],
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                // 店铺信息卡片
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      Card(
                        margin: const EdgeInsets.all(0),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _storeData['storeName'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _storeData['storeCategory'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: _storeData['tags']
                                    .map<Widget>(
                                      (tag) => Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[100],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          tag,
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoRow(Icons.access_time, "营业时间",
                                      _storeData['businessHours']),
                                  _buildInfoRow(Icons.location_on, "店铺位置",
                                      _storeData['storeLocation']),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.yellow[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.verified_user_outlined,
                                        color: Colors.orange),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _storeData['vipPrivilege'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 底部按钮栏
                // 底部按钮栏
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 10.0), // 加大左右和上下内边距
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          // 收藏逻辑
                        },
                        icon: const Icon(
                          Icons.favorite_border,
                          size: 28, // 调大图标大小
                          color: Colors.black87, // 自定义图标颜色
                        ),
                        label: const Text(
                          "收藏",
                          style: TextStyle(fontSize: 18), // 调大文字大小
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0), // 设置按钮内边距
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // 分享逻辑
                        },
                        icon: const Icon(
                          Icons.share,
                          size: 28, // 调大图标大小
                          color: Colors.black87, // 自定义图标颜色
                        ),
                        label: const Text(
                          "分享",
                          style: TextStyle(fontSize: 18), // 调大文字大小
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0), // 设置按钮内边距
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
