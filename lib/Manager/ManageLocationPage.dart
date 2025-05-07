import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/api/store.dart';
import 'package:parkinglot_frontend/utils/util.dart';

import '../entity/Store.dart';
//import 'package:parkinglot_frontend/api/shop.dart';

class ManagerLocationPage extends StatefulWidget {
  @override
  _ManagerLocationPageState createState() => _ManagerLocationPageState();
}

class _ManagerLocationPageState extends State<ManagerLocationPage> {
  bool _isLoading = true;
  int _page = 1;
  bool _hasMore = true; //判断有没有数据
  ScrollController _scrollController = new ScrollController();
  String selectedFloor = "全部楼层";
  String selectedCategory = "全部";
  List<Store> _storeInfo = [];
  bool _isLoadingMore = false;
  final List<String> floors = ['B1', 'M', 'F1', 'F2', 'F3', 'F4', 'F5', '全部楼层'];
  String selectedShopNumber = '1';
  String selectedBuilding = 'A';
  final List<String> buildings = ['A', 'B']; // 场馆选项
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStoreInfo();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreData();
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (!_hasMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    await _fetchStoreInfo();
    
    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _fetchStoreInfo() async {
    if (!_hasMore) return;
    
    if (_page == 1) {
      setState(() {
        _isLoading = true;
      });
    }
    
    try {
      var result = await StoreApi().GetStoreInfoWithFilters(
        selectedCategory,
        selectedFloor,
        _page,
        10,
      );
      
      if (result != null && result['code'] == 200 && result['data'] != null) {
        List<Store> newStores = (result['data'] as List)
            .map((json) => Store.fromJson(json))
            .toList();
            
        setState(() {
          if (_page == 1) {
            _storeInfo = newStores;
          } else {
            _storeInfo.addAll(newStores);
          }
          
          // 判断是否还有更多数据
          _hasMore = newStores.length == 10;
          if (_hasMore) {
            _page++;
          }
        });
      } else {
        setState(() {
          _hasMore = false;
        });
      }
    } catch (e) {
      print('Error fetching store info: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _page = 1;
      _hasMore = true;
      _storeInfo = [];
      selectedFloor = "全部楼层"; // 重置selectedFloor为"全部楼层"
    });
    await _fetchStoreInfo();
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
    } else {
      ElToast.info(result['msg']);
      _fetchStoreInfo();
    }
  }

  List<Store> get _filteredStores {
    if (_searchText.isEmpty) return _storeInfo;
    return _storeInfo.where((store) => store.storeName.contains(_searchText)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '商铺管理',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '管理您的所有商铺信息',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // 添加商铺逻辑
                    },
                    icon: Icon(Icons.add),
                    label: Text('添加商铺'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  _searchText = value;
                  if (value.isEmpty) {
                    _hasMore = true;
                    _page = 1;
                    _fetchStoreInfo();
                  } else {
                    _performSearch(value);
                  }
                },
                decoration: InputDecoration(
                  hintText: '搜索商铺...',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!_isLoadingMore && _hasMore && scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                      _loadMoreData();
                    }
                    return false;
                  },
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _filteredStores.isEmpty
                          ? Center(child: Text('暂无商铺信息'))
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: _filteredStores.length + 1,
                              itemBuilder: (context, index) {
                                if (index == _filteredStores.length) {
                                  if (!_hasMore) {
                                    return Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        child: Text('我是有底线的', style: TextStyle(color: Colors.grey)),
                                      ),
                                    );
                                  } else if (_isLoadingMore) {
                                    return Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  } else {
                                    return SizedBox.shrink();
                                  }
                                }
                                final store = _filteredStores[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: _buildStoreCard(store),
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreCard(Store store) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: store.image.isNotEmpty
                ? Image.network(
                    store.image,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Icon(Icons.store, size: 48, color: Colors.grey[400]),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        store.storeName,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, size: 18),
                      onPressed: () {
                        // 编辑商铺逻辑
                        _showChangeShopLocationDialog(store);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(store.address, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                SizedBox(height: 4),
                Text('联系方式: ${store.serviceType}', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                SizedBox(height: 4),
                Text('服务类型: ${store.serviceCategory}', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                SizedBox(height: 4),
                Text('营业时间: ${store.businessHours}', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: store.businessHours.contains('休息') ? Colors.grey[200] : Color(0xFFE6F4EA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        store.businessHours.contains('休息') ? '休息中' : '营业中',
                        style: TextStyle(
                          color: store.businessHours.contains('休息') ? Colors.grey : Color(0xFF34A853),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeShopLocationDialog(Store shop) {
    final storeNameController = TextEditingController(text: shop.storeName);
    final serviceCategoryController = TextEditingController(text: shop.serviceCategory);
    final serviceTypeController = TextEditingController(text: shop.serviceType);
    final businessHoursController = TextEditingController(text: shop.businessHours);
    final addressController = TextEditingController(text: shop.address);
    final floorNumberController = TextEditingController(text: shop.floorNumber.toString());
    final descriptionController = TextEditingController(text: shop.description);
    final recommendedServicesController = TextEditingController(text: shop.recommendedServices);
    final imageController = TextEditingController(text: shop.image);
    String floor1 = shop.floorNumber.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('编辑商铺信息'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: storeNameController,
                decoration: InputDecoration(labelText: '商铺名称'),
              ),
              TextField(
                controller: serviceCategoryController,
                decoration: InputDecoration(labelText: '服务类别'),
              ),
              TextField(
                controller: serviceTypeController,
                decoration: InputDecoration(labelText: '服务类型'),
              ),
              TextField(
                controller: businessHoursController,
                decoration: InputDecoration(labelText: '营业时间'),
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true, // 设置isExpanded为true
                      decoration: InputDecoration(
                        labelText: '场馆',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      value: selectedBuilding,
                      items: buildings.map((String building) {
                        return DropdownMenuItem<String>(
                          value: building,
                          child: Text('${building}馆'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedBuilding = newValue;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true, // 设置isExpanded为true
                      decoration: InputDecoration(
                        labelText: '楼层',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      value: selectedFloor,
                      items: floors.map((String floor) {
                        return DropdownMenuItem<String>(
                          value: floor,
                          child: Text(floor),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedFloor = newValue;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true, // 设置isExpanded为true
                      decoration: InputDecoration(
                        labelText: '店铺号',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      value: selectedShopNumber,
                      items: List<String>.generate(40, (index) => (index + 1).toString())
                          .map((String number) {
                        return DropdownMenuItem<String>(
                          value: number,
                          child: Text(number),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedShopNumber = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: '描述'),
              ),
              TextField(
                controller: recommendedServicesController,
                decoration: InputDecoration(labelText: '推荐服务'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              // 创建更新后的商铺对象
              Store updatedStore = Store(
                id: shop.id,
                storeName: storeNameController.text,
                serviceCategory: serviceCategoryController.text,
                serviceType: serviceTypeController.text,
                businessHours: businessHoursController.text,
                address: getFullAddress(),
                floorNumber: int.tryParse(floorNumberController.text) ?? shop.floorNumber,
                description: descriptionController.text,
                recommendedServices: recommendedServicesController.text,
                image: imageController.text,
              );
              
              try {
                // 将Store对象转换为Map
                Map<String, dynamic> storeMap = {
                  'id': updatedStore.id,
                  'storeName': updatedStore.storeName,
                  'serviceCategory': updatedStore.serviceCategory,
                  'serviceType': updatedStore.serviceType,
                  'businessHours': updatedStore.businessHours,
                  'address': updatedStore.address,
                  'floorNumber': updatedStore.floorNumber,
                  'description': updatedStore.description,
                  'recommendedServices': updatedStore.recommendedServices,
                  'image': updatedStore.image,
                };
                
                var result = await StoreApi().UpdateStore(storeMap);

                if (result != null && result['code'] == 200) {
                  Navigator.pop(context);
                  _refreshData(); // 刷新商铺列表
                  ElToast.info('商铺信息更新成功');
                } else {
                  ElToast.info(result['msg']);
                }
              } catch (e) {
                print('发生错误: $e');
              }
            },
            icon: Icon(Icons.save),
            label: Text('保存'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showShopDetails(Store store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('商铺详情'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('商铺名称'),
              subtitle: Text(store.storeName),
            ),
            ListTile(
              title: Text('位置'),
              subtitle: Text(store.address),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('关闭'),
          ),
        ],
      ),
    );
  }

  String getFullAddress() {
    return '${selectedBuilding}馆-$selectedFloor-$selectedShopNumber';
  }
}