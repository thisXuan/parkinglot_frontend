import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/api/store.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchStoreInfo();
  }

  Future<void> _fetchStoreInfo() async {
    setState(() {
      _isLoading = true;
    });
    if (this._hasMore) {
      var result = await StoreApi().GetStoreInfoWithFilters(
        selectedCategory, // 传递选择的类别
        selectedFloor, // 传递选择的楼层
        _page,
        10, // 传递 size，假设每页显示 10 个商铺
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
      List<Store> storeList =
      (result['data'] as List).map((json) => Store.fromJson(json)).toList();
      if (storeList.length < 10) {
        setState(() {
          this._hasMore = false;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('商铺管理'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchStoreInfo,
        child: _buildShopList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //_showChangeShopLocationDialog();
        },
        child: Icon(Icons.swap_horiz),
        tooltip: '更改商铺位置',
      ),
    );
  }

  Widget _buildShopList() {
    if (_storeInfo.isEmpty) {
      return Center(child: Text('暂无商铺信息'));
    }

    return ListView.separated(
      itemCount: _storeInfo.length,
      separatorBuilder: (context, index) => Divider(height: 1),
      itemBuilder: (context, index) {
        var shop = _storeInfo[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.amber[100],
            child: Text(
              shop.storeName.substring(0, 1),
              style: TextStyle(color: Colors.amber[800]),
            ),
          ),
          title: Text(shop.storeName),
          subtitle: Text('位置: ${shop.address}'),
          trailing: IconButton(
            icon: Icon(Icons.edit_location_alt, color: Colors.blue),
            onPressed: () => _showChangeShopLocationDialog(shop),
          ),
          onTap: () {
            _showShopDetails(shop);
          },
        );
      },
    );
  }

  void _showChangeShopLocationDialog(Store shop) {
    final beforeNameController = TextEditingController(text: shop.storeName ?? '');
    final afterNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('更改商铺位置'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: beforeNameController,
                decoration: InputDecoration(labelText: '当前商铺名称'),
                readOnly: shop != null,
              ),
              TextField(
                controller: afterNameController,
                decoration: InputDecoration(labelText: '新商铺名称'),
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
              // 调用更改商铺位置的API
              try {
                var result = await _changeShopLocation(
                  beforeNameController.text,
                  afterNameController.text,
                );

                if (result != null && result['code'] == 200) {
                  Navigator.pop(context);
                  _fetchStoreInfo(); // 刷新商铺列表
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('商铺位置更改成功')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('商铺位置更改失败: ${result?['message'] ?? '未知错误'}')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('发生错误: $e')),
                );
              }
            },
            child: Text('确认更改'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _changeShopLocation(String beforeName, String afterName) async {
    // 实际API调用
    try {
      // TODO: 修改店铺名称
      // 这里应该是实际的API调用
      // return await ShopApi().changeShopLocation(beforeName, afterName);

      // 模拟API调用
      await Future.delayed(Duration(seconds: 1));
      return {
        'code': 200,
        'data': 'success'
      };
    } catch (e) {
      print('Error changing shop location: $e');
      return null;
    }
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
}