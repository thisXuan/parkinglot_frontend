import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/api/store.dart';
import 'package:parkinglot_frontend/Store/storeSearch.dart';
import 'package:parkinglot_frontend/Store/storeSelect.dart';

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
    required this.image
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
        image: json['image']??''
    );
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
  int _selectedIndex = 0; // 用于跟踪当前选中的Tab
  bool _isloading = false;

  @override
  void initState() {
    super.initState();
    this._fetchStoreInfo();
    //监听滚动条事件
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 40&&!_isloading) {
        this._fetchStoreInfo();
      }
    });
  }

  Future<void> _fetchStoreInfo() async {
    setState(() {
      _isloading = true;
    });
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
    setState(() {
      _isloading = false;
    });
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
      body: Column(
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
          BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '全部',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fastfood),
                label: '美食',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: '购物',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.beach_access),
                label: '休闲玩乐',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.style),
                label: '丽人美发',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.child_care),
                label: '亲子遛娃',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center),
                label: '运动健身',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: '学习培训',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_laundry_service),
                label: '生活服务',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
              // 根据选中的索引跳转到StoreSelectPage，并传递相应的参数
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoreSelectPage(
                    category: categories[_selectedIndex], // 假设categories是一个包含所有类别的列表
                  ),
                ),
              );
            },
            elevation: 0, // 取消阴影效果
            unselectedItemColor: Colors.black, // 设置未选中项的颜色为黑色
            selectedItemColor: Theme.of(context).colorScheme.secondary, // 设置选中项的颜色为系统紫色
          ),
          // 列表
          Expanded(
            child: this._storeInfo.length > 0
                ? RefreshIndicator(
              onRefresh: _refreshData,
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
                  }else{
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
                  }
                },
              ),
            )
                : _getMoreWidget(),
          ),
        ],
      ),

    );
  }

  final List<String> categories = [
    '全部', '美食', '购物', '休闲玩乐', '丽人美发', '亲子遛娃', '运动健身', '学习培训', '生活服务',
  ];
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