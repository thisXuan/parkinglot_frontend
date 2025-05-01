import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/api/store.dart';
import 'package:parkinglot_frontend/utils/util.dart';

import '../entity/Store.dart';
//import 'package:parkinglot_frontend/api/shop.dart';

class ManagerLocationPage extends StatefulWidget {
  @override
  _ShopManagementScreenState createState() => _ShopManagementScreenState();
}

class _ShopManagementScreenState extends State<ManagerLocationPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: _isLoading && _page == 1
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: _buildShopList(),
            ),
    );
  }

  Widget _buildShopList() {
    if (_storeInfo.isEmpty) {
      return Center(child: Text('暂无商铺信息'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _storeInfo.length + 1,
      padding: EdgeInsets.all(8.0),
      itemBuilder: (context, index) {
        if (index == _storeInfo.length) {
          return _buildFooter();
        }
        
        var shop = _storeInfo[index];
        return Card(
          color: Colors.white,
          margin: EdgeInsets.symmetric(vertical: 8.0),
          elevation: 2.0,
          child: InkWell(
            onTap: () => _showShopDetails(shop),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.amber[100],
                    child: Text(
                      shop.storeName.substring(0, 1),
                      style: TextStyle(color: Colors.amber[800]),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.storeName,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          '位置: ${shop.address}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_location_alt, color: Colors.blue),
                    onPressed: () => _showChangeShopLocationDialog(shop),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    if (_isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (!_hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text('我已经到底了', style: TextStyle(color: Colors.grey))),
      );
    } else {
      return SizedBox.shrink();
    }
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
          ElevatedButton(
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
            child: Text('保存'),
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