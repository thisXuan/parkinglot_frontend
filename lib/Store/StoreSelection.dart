import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/Store/StoreDetail.dart';
import 'package:parkinglot_frontend/api/store.dart';
import 'package:parkinglot_frontend/utils/util.dart';
import 'package:parkinglot_frontend/entity/Store.dart';

class BrandSelectionPage extends StatefulWidget {
  @override
  State<BrandSelectionPage> createState() => _BrandSelectionPageState();
}

class _BrandSelectionPageState extends State<BrandSelectionPage> {
  List<Store> _storeInfo = [];
  int _page = 1;
  bool _hasMore = true; //判断有没有数据
  ScrollController _scrollController = new ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isloading = false;

  String selectedFloor = "全部楼层";
  String selectedCategory = "全部";

  final List<String> categories = [
    '全部',
    '美食',
    '购物',
    '休闲玩乐',
    '丽人美发',
    '亲子遛娃',
    '运动健身',
    '学习培训',
    '生活服务',
  ];

  @override
  void initState() {
    super.initState();
    this._fetchStoreInfo();
    //监听滚动条事件
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
              _scrollController.position.maxScrollExtent - 40 &&
          !_isloading) {
        this._fetchStoreInfo();
      }
    });
  }

  Future<void> _fetchStoreInfo() async {
    setState(() {
      _isloading = true;
    });
    if (this._hasMore) {
      var result = await StoreApi().GetStoreInfoWithFilters(
        selectedCategory,  // 传递选择的类别
        selectedFloor,     // 传递选择的楼层
        _page,
        10,                 // 传递 size，假设每页显示 10 个商铺
      );
      if (result != null && result['code'] == 200 && result['data'] != null) {
        setState(() {
          _storeInfo.addAll((result['data'] as List)
              .map((json) => Store.fromJson(json))
              .toList());
          _page++;
        });
      }
      // 判断是否是最后一页
      List<Store> storeList = (result['data'] as List)
          .map((json) => Store.fromJson(json))
          .toList();
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

  Future<void> _performSearch(String data) async {
    _hasMore = false;
    var result = await StoreApi().QueryStoreInfo(data);
    if (result != null && result['code'] == 200 && result['data'] != null) {
      setState(() {
        _storeInfo = (result['data'] as List)
            .map((json) => Store.fromJson(json))
            .toList();
      });
    }else{
      ElToast.info(result['msg']);
      _fetchStoreInfo();
    }
  }

  Widget _buildSectionWrapper(Widget child) {
    return Container(
      //padding: EdgeInsets.all(16), // 内边距
      decoration: BoxDecoration(
        color: Colors.white, // 淡灰色背景
        borderRadius: BorderRadius.circular(0), // 圆角
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[60],
      body: Column(
        children: [
          // 搜索栏
          _buildSectionWrapper(
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          _storeInfo.clear();
                          _page = 1;
                          if(value.isEmpty){
                            _hasMore = true;
                            _fetchStoreInfo();
                          }else{
                            _performSearch(value);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "请输入",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ),
          // 楼层和分类标签
          _buildSectionWrapper(Row(
            children: [
              GestureDetector(
                onTap: () {
                  _showFloorMenu(context);
                },
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  //color: Colors.white,
                  child: Row(
                    children: [
                      Text(
                        selectedFloor,
                        style: const TextStyle(color: Colors.orange),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.orange),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      final isSelected = category == selectedCategory;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = category; // 更新选择的类别
                            _storeInfo.clear(); // 清空当前商铺列表
                            _page = 1; // 重置页码
                            _hasMore = true; // 重新设置是否还有更多数据
                            _fetchStoreInfo(); // 重新加载数据
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            border: isSelected
                                ? Border(
                              bottom: BorderSide(
                                  color: Colors.orange, width: 2),
                            )
                                : null,
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.orange : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          )),
          // 商店具体信息
          Expanded(
              child: this._storeInfo.length > 0
                  ? RefreshIndicator(
                      onRefresh: _refreshData,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _storeInfo.length,
                        itemBuilder: (context, index) {
                          final brand = _storeInfo[index];

                          // 包装 Card 为 InkWell 添加点击事件
                          Widget cardContent = Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            color: Colors.white,
                            child: ListTile(
                              leading: brand.image.isNotEmpty
                                  ? Image.network(
                                brand.image,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              )
                                  : Image.asset(
                                'assets/image_lost.jpg',
                                width: 70,
                              ),
                              title: Text(brand.storeName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(brand.serviceCategory),
                                  SizedBox(height: 2),
                                  Container(
                                    margin: const EdgeInsets.only(right: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      brand.businessHours.isEmpty ? "营业时间未知" : brand.businessHours,
                                      style: const TextStyle(color: Colors.orange, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Text(brand.floorNumber.toString() + "F"),
                            ),
                          );

                          if (index == _storeInfo.length - 1) {
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    //点击事件：跳转到详情页面
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StoreDetailPage(storeId: brand.id),
                                      ),
                                    );
                                  },
                                  child: cardContent,
                                ),
                                Divider(),
                                _getMoreWidget(),
                              ],
                            );
                          } else {
                            return InkWell(
                              onTap: () {
                                // 点击事件：跳转到详情页面
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StoreDetailPage(storeId: brand.id),
                                  ),
                                );
                              },
                              child: cardContent,
                            );
                          }
                        },
                      ))
                  : _getMoreWidget()),
          // 底部导航栏
        ],
      ),
    );
  }

  void _showFloorMenu(BuildContext context) async {
    final List<String> floors = [
      "全部楼层", "B1", "M", "1F", "2F", "3F", "4F", "5F"
    ];
    String? result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(50, 100, 50, 0),
      items: floors
          .map(
            (floor) => PopupMenuItem<String>(
          value: floor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                floor,
                style: TextStyle(
                  color: floor == selectedFloor ? Colors.deepPurple : Colors.black,
                ),
              ),
              if (floor == selectedFloor)
                const Icon(
                  Icons.check,
                  color: Colors.deepPurple,
                  size: 16,
                ),
            ],
          ),
        ),
      )
          .toList(),
    );
    if (result != null && result != selectedFloor) {
      setState(() {
        selectedFloor = result;  // 更新选择的楼层
        _storeInfo.clear();  // 清空当前商铺列表
        _page = 1;  // 重置页码
        _hasMore = true;  // 重新设置是否还有更多数据
        _fetchStoreInfo();  // 重新加载数据
      });
    }
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
}
