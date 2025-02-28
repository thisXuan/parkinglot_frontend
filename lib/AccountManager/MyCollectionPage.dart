import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/api/store.dart';
import 'package:parkinglot_frontend/entity/Store.dart';
import 'package:parkinglot_frontend/utils/util.dart';


class MyCollectionPage extends StatefulWidget {
  @override
  _MyCollectionPageState createState() => _MyCollectionPageState();
}

class _MyCollectionPageState extends State<MyCollectionPage> {
  String _selectedTab = '品牌';
  List<Store> stores = [];


  void _loadFavorite() async{
    var result = await StoreApi().ViewLikes();
    if(result!=null){
      var code = result['code'];
      var data = result['data'];
      var msg = result['msg'];
      if(code==200){
       setState(() {
         stores.addAll((data as List)
             .map((json) => Store.fromJson(json))
             .toList());
       });
      }else{
        ElToast.info(msg);
      }
    }
  }

  @override
  void initState() {
    _loadFavorite();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '我的收藏',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 标签选择
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                _buildTab('品牌'),
              ],
            ),
          ),
          Divider(height: 1),
          // 收藏列表或空状态
                    Expanded(
            child: Container(
              color: Color(0xFFF5F5F5),
              child: stores.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: stores.length,
                      itemBuilder: (context, index) {
                        final store = stores[index];
                        return Dismissible(
                          key: Key(store.id.toString()),
                          direction: DismissDirection.endToStart, // 只允许从右向左滑动
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 16),
                            color: Colors.white, // 白色背景
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.delete,  // 垃圾桶图标
                                      color: Colors.red,
                                      size: 24,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '取消收藏',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            // 显示确认对话框
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Text(
                                    '确定取消收藏该店铺吗?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                    top: 20,
                                    bottom: 10,
                                    left: 24,
                                    right: 24,
                                  ),
                                  actions: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(color: Color(0xFF1E3F7C)),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(22),
                                                ),
                                                minimumSize: Size(0, 44),
                                              ),
                                              child: Text(
                                                '取消',
                                                style: TextStyle(color: Color(0xFF1E3F7C)),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(0xFF1E3F7C),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(22),
                                                ),
                                                minimumSize: Size(0, 44),
                                              ),
                                              child: Text(
                                                '确认',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            // TODO: 调用API取消收藏
                            setState(() {
                              stores.removeAt(index);
                            });
                           ElToast.info("已取消收藏");
                          },
                          child: _buildStoreCard(store),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title) {
    bool isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
      },
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Color(0xFF1E3F7C) : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Container(
            height: 2,
            width: 20,
            color: isSelected ? Color(0xFF1E3F7C) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/empty.jpg',
            width: 120,
            height: 120,
          ),
          SizedBox(height: 16),
          Text(
            '您还没有相关收藏',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(Store store) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // 店铺图片
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                store.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/image_lost.jpg',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            SizedBox(width: 12),
            // 店铺信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.storeName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${store.serviceCategory} | ${store.serviceType}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 8),
                  // TODO: tags
                  // Row(
                  //   children: store.tags.map((tag) {
                  //     return Container(
                  //       margin: EdgeInsets.only(right: 8),
                  //       padding: EdgeInsets.symmetric(
                  //         horizontal: 8,
                  //         vertical: 2,
                  //       ),
                  //       decoration: BoxDecoration(
                  //         border: Border.all(
                  //           color: Color(0xFFFF9966),
                  //         ),
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //       child: Text(
                  //         tag,
                  //         style: TextStyle(
                  //           color: Color(0xFFFF9966),
                  //           fontSize: 12,
                  //         ),
                  //       ),
                  //     );
                  //   }).toList(),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
