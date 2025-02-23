import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/api/store.dart';
import 'package:parkinglot_frontend/entity/Order.dart';
import 'package:parkinglot_frontend/utils/util.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String _selectedStatus = '全部';
  final List<String> orderStatus = ['全部', '待付款', '待使用', '已完成', '已退款'];
  List<Order> orders = []; // 假设这里是空的订单列表
  int _selectedType = 0;

  @override
  void initState() {
    getOrderByType();
    super.initState();
  }

  void getOrderByType() async{
    var result = await StoreApi().GetOrder(_selectedType);
    if(result!=null){
      var code = result['code'];
      var data = result['data'];
      var msg = result['msg'];
      if(code==200){
        setState(() {
          orders = (data as List).map((json) => Order.fromJson(json)).toList();
        });
      }else{
        ElToast.info(msg);
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '我的订单',
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
            Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 均匀分布
              children: orderStatus.map((status) {
                final isSelected = status == _selectedStatus;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStatus = status;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                          color: isSelected ? Color(0xFF1E3F7C) : Colors.grey,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          height: 2,
                          width: 24,
                          color: Color(0xFF1E3F7C), // 选中状态下的下划线
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          // 订单列表或空状态
          Expanded(
            child: Container(
              color: Color(0xFFF5F5F5), // 设置背景颜色为灰色
              child: orders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _buildOrderCard(order);
                      },
                    ),
            ),
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
            'assets/empty.jpg',  // 请确保添加空状态图片
            width: 120,
            height: 120,
          ),
          SizedBox(height: 16),
          Text(
            '您还没有相关订单',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/image_lost.jpg',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.voucherId.toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '¥${order.payValue}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF6B35).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.type.toString(),
                    style: TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}