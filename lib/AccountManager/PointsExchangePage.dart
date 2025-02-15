import 'package:flutter/material.dart';

// TODO：花成长值，接口未设计，后端未对接
class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  final int salesCount;
  final String? tag;
  final String? promotion;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.salesCount,
    this.tag,
    this.promotion,
  });
}

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

  // 模拟商品数据
  final List<Product> products = [
    Product(
      id: '1',
      name: '【限时优惠 直充到账】三毛游全球景区博物馆自助讲',
      price: 138,
      image: 'assets/image_lost.jpg',
      salesCount: 2000,
      tag: '退货包运费',
    ),
    Product(
      id: '2',
      name: 'FUJIFILM·拍立得相纸适用mini7+/8/9/11/12/25/90/E',
      price: 65,
      image: 'assets/image_lost.jpg',
      salesCount: 3000,
    ),
    Product(
      id: '2',
      name: 'FUJIFILM·拍立得相纸适用mini7+/8/9/11/12/25/90/E',
      price: 65,
      image: 'assets/image_lost.jpg',
      salesCount: 3000,
    ),
    Product(
      id: '2',
      name: 'FUJIFILM·拍立得相纸适用mini7+/8/9/11/12/25/90/E',
      price: 65,
      image: 'assets/image_lost.jpg',
      salesCount: 3000,
    ),
    Product(
      id: '2',
      name: 'FUJIFILM·拍立得相纸适用mini7+/8/9/11/12/25/90/E',
      price: 65,
      image: 'assets/image_lost.jpg',
      salesCount: 3000,
    ),
    Product(
      id: '2',
      name: 'FUJIFILM·拍立得相纸适用mini7+/8/9/11/12/25/90/E',
      price: 65,
      image: 'assets/image_lost.jpg',
      salesCount: 3000,
    ),
    Product(
      id: '2',
      name: 'FUJIFILM·拍立得相纸适用mini7+/8/9/11/12/25/90/E',
      price: 65,
      image: 'assets/image_lost.jpg',
      salesCount: 3000,
    ),
    Product(
      id: '2',
      name: 'FUJIFILM·拍立得相纸适用mini7+/8/9/11/12/25/90/E',
      price: 65,
      image: 'assets/image_lost.jpg',
      salesCount: 3000,
    ),
  ];

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 商品图片
                      Expanded(
                        child: Image.asset(
                          product.image,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 商品名称
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            // 价格和销量
                            Row(
                              children: [
                                Text(
                                  '${product.price}',
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
                                  '${product.salesCount}人已兑换',
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