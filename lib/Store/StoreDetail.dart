import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/api/store.dart';
import 'package:parkinglot_frontend/api/voucher.dart';
import 'package:parkinglot_frontend/utils/util.dart';
import 'package:parkinglot_frontend/entity/Store.dart';
import 'package:parkinglot_frontend/entity/Voucher.dart';

class StoreDetailPage extends StatefulWidget {
  final int storeId;

  const StoreDetailPage({Key? key, required this.storeId}) : super(key: key);

  @override
  _StoreDetailPageState createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage> {
  List<Voucher> _voucherInfo = [];
  late Store store;
  Map<String,dynamic> _storeData = {
    "vipPrivilege": "V2-V5琉珠用户 花琉珠膨胀特权",
    "tags": ["赚琉珠", "消费20元返1琉珠", "花琉珠"],
  };
  bool _isLoading = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchStoreData(widget.storeId);
    setState(() {
      _isLoading = true;
    });
    _fetchVouchers(widget.storeId);
  }

  // 获取店铺数据
  void _fetchStoreData(int storeId) async {
    var result = await StoreApi().GetStoreInfoById(storeId);
    if (result != null) {
      var code = result['code'];
      var msg = result['msg'];
      var data = result['data'];
      if (code == 200) {
        setState(() {
          store = Store.fromJson(data);
          _isLoading = false;
        });
      } else {
        ElToast.info(msg);
      }
    }
  }

  void _fetchVouchers(int storeId) async {
    var result = await VoucherApi().GetVoucherByShopId(storeId);
    if (result != null) {
      var code = result['code'];
      var msg = result['msg'];
      var data = result['data'];
      if (code == 200) {
        setState(() {
          _voucherInfo.addAll((result['data'] as List)
              .map((json) => Voucher.fromJson(json))
              .toList());
          _isLoading = false;
        });
      } else {
        ElToast.info(msg);
      }
    }
  }

  Widget containsTags(
      String text, Color foregroundColor, Color backgroundColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: foregroundColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: backgroundColor),
      ),
    );
  }

  Widget FindVouchers(Voucher voucher) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                store.image.isNotEmpty
                    ? Image.network(
                  store.image,
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                )
                    : Image.asset(
                  'assets/image_lost.jpg',
                  width: 120,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (voucher.payValue / 100).toString() +
                            "元代" +
                            (voucher.actualValue / 100).toString() +
                            "代金券",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      containsTags(voucher.subtitle,
                          Color(0xFFFFF1E0), Colors.orange),
                      containsTags(voucher.rules, Color(0xFFFFE6E2),
                          Colors.red),
                      const SizedBox(height: 8),
                      const Text(
                        "过期退 | 可叠加",
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: Column(
                    children: [
                      Text(
                        "¥" + (voucher.payValue / 100).toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      const Text(
                        "立即购买",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("品牌详情"),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // 店铺 Logo 区域
              Container(
                color: Colors.grey[100],
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child:  store.image.isNotEmpty
                    ? Image.network(
                  store.image,
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                )
                    : Image.asset(
                  'assets/image_lost.jpg',
                  width: 120,
                ),
              ),
              // 店铺信息卡片
              Card(
                margin: const EdgeInsets.all(0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.storeName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        store.serviceCategory,
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
                              borderRadius: BorderRadius.circular(8),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoRow(Icons.access_time, "营业时间",
                              store.businessHours),
                          _buildInfoRow(Icons.location_on, "店铺位置",
                              store.address),
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
              const SizedBox(height: 16),
              if (!_voucherInfo.isEmpty)
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 2.0),
                          child: const Text(
                            "券",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "优惠卡券",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: _voucherInfo.map((voucher) {
                        return FindVouchers(voucher);
                      }).toList(),
                    ),
                  ],
                )
            ],
          )
          ),
        ),
        // 底部按钮栏
        bottomNavigationBar: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(
              horizontal: 40.0, vertical: 10.0), // 加大左右和上下内边距
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  // 收藏逻辑
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
                icon: Icon(
                  _isFavorite ? Icons.star : Icons.star_border, // 根据状态显示图标
                  size: 28,
                  color: _isFavorite ? Colors.red : Colors.black87, // 根据状态切换颜色
                ),
                label: const Text(
                  "收藏",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87, // 文字颜色同步变化
                  ),
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
        ));
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
