import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/api/user.dart';
import 'package:parkinglot_frontend/entity/Coupon.dart';
import 'package:parkinglot_frontend/utils/util.dart';

class PointsExchangePage extends StatefulWidget {
  @override
  _PointsExchangePageState createState() => _PointsExchangePageState();
}

class _PointsExchangePageState extends State<PointsExchangePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '推荐';
  
  final List<String> categories = [
    '推荐', '时尚女装', '家居美学', '运动户外', '穿搭配饰'
  ];

  List<Coupon> products = [];

  Future<void> getCoupons() async{
    String type = "";
    if(_selectedCategory!='推荐'){
      type = _selectedCategory;
    }
    var result = await UserApi().GetCoupon(type);
    if(result!=null){
      var data = result['data'];
      var code = result['code'];
      var msg = result['msg'];
      if(code!=200){
        ElToast.info(msg);
      }else{
       setState(() {
         products = (data as List).map((json) => Coupon.fromJson(json)).toList();
       });
      }
    }
  }

  @override
  void initState() {
    getCoupons();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 36,
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(18),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '蕉下墨镜',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              suffixIcon: Icon(Icons.camera_alt_outlined, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 分类导航
          Container(
            height: 44,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: categories.map((category) {
                bool isSelected = category == _selectedCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.grey,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // 商品网格
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 商品图片
                      Expanded(
                        child: GestureDetector(
                          child: Image.asset(
                            "assets/image_lost.jpg",
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          onTap: (){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Text(
                                    '确认兑换?',
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
                                              onPressed: () {
                                                Navigator.of(context).pop(); // 关闭弹窗
                                              },
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
                                              onPressed: () async {
                                                var result = await UserApi().ExchangeCoupon(product.id);
                                                if(result!=null){
                                                  var code = result['code'];
                                                  var msg = result['msg'];
                                                  if(code==200){
                                                    ElToast.info("兑换成功");
                                                  }else{
                                                    ElToast.info(msg);
                                                  }
                                                }
                                              },
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
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 商品名称
                            Text(
                              product.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            // 价格和销量
                            Row(
                              children: [
                                Text(
                                  '${product.payPoint}',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Text(
                                  '成长值',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '${product.saleCount}人已兑换',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
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
              },
            ),
          ),
        ],
      ),
    );
  }
}