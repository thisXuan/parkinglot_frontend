import 'package:flutter/material.dart';

class MemberActivityCenterPage extends StatelessWidget {
  final List<Map<String, dynamic>> activities = [
    {
      'title': '会员专享健身课程',
      'date': '5月01日 - 5月31日',
      'location': '渝北人才健身中心 主馆',
      'quota': '剩余名额: 20人',
      'desc': '专为会员打造的健身课程，包含瑜伽、普拉提、有氧运动等多种选择，由专业教练一对一指导。',
      'badge': '会员免费',
      'badgeColor': Color(0xFF2563EB),
      'img': 'assets/MemberActivity/exercise.png',
    },
    {
      'title': '高端美食品鉴会',
      'date': '5月10日 - 5月15日',
      'location': '来福士洲际酒店宴会厅',
      'quota': '剩余名额: 30人',
      'desc': '邀请米其林星级厨师现场烹饪，品尝独家创意美食，了解美食背后的故事与文化。',
      'badge': '会员价¥399',
      'badgeColor': Color(0xFF2563EB),
      'img': 'assets/MemberActivity/exhibition.jpeg',
    },
    {
      'title': '艺术展览专场',
      'date': '5月05日 - 5月25日',
      'location': '重庆城市艺术中心',
      'quota': '剩余名额: 50人',
      'desc': '汇集国内外知名艺术家作品，会员专享展览服务，深入了解艺术创作背后的灵感与技巧。',
      'badge': '会员半价',
      'badgeColor': Color(0xFF2563EB),
      'img': 'assets/MemberActivity/food.jpeg',
    },
    {
      'title': '高尔夫球会体验日',
      'date': '5月18日 - 5月20日',
      'location': '庆隆南山高尔夫球场',
      'quota': '剩余名额: 15人',
      'desc': '在顶级高尔夫球场体验挥杆乐趣，专业教练指导，适合各级别球友参与。',
      'badge': '会员价¥599',
      'badgeColor': Color(0xFF2563EB),
      'img': 'assets/MemberActivity/golf.jpg',
    },
    {
      'title': '葡萄酒品鉴会',
      'date': '5月20日 - 5月22日',
      'location': '重庆市源著天街5楼VIP室',
      'quota': '剩余名额: 25人',
      'desc': '由专业侍酒师带领品鉴，品尝来自世界各地的顶级美酒，了解葡萄酒文化与品鉴技巧。',
      'badge': '会员价¥299',
      'badgeColor': Color(0xFF2563EB),
      'img': 'assets/MemberActivity/wine.jpg',
    },
    {
      'title': '日本冬季温泉之旅',
      'date': '12月24日 - 12月26日',
      'location': '日本箱根',
      'quota': '剩余名额: 10人',
      'desc': '在寒冷的冬季，享受温泉带来的舒适与放松，配合专业SPA服务，焕发身心活力。',
      'badge': '会员价¥3888',
      'badgeColor': Color(0xFF2563EB),
      'img': 'assets/MemberActivity/spring.jpg',
    },
  ];

  final List<Map<String, String>> privileges = [
    {
      'title': '积分兑换',
      'desc': '参与活动可获得双倍积分，可兑换礼品或抵扣未来活动费用',
    },
    {
      'title': '专属客服',
      'desc': '会员专线客服，优先解决问题，提供一对一活动咨询',
    },
    {
      'title': '提前预约',
      'desc': '热门活动提前7天预约的权利，确保您不错过任何精彩体验',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('会员活动'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 24),
              Text('会员专享活动中心', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event, color: Colors.grey[600], size: 18),
                  SizedBox(width: 4),
                  Text('活动时间: 2025年5月01日 - 2025年5月31日', style: TextStyle(fontSize: 15, color: Colors.grey[700])),
                ],
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '尊敬的会员，我们为您精心准备了一系列专属活动，涵盖健身、美食、艺术、运动等多个领域，让您的会员身份带来更多精彩体验与尊贵权益。',
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: activities.map((activity) => _buildActivityCard(context, activity)).toList(),
                ),
              ),
              SizedBox(height: 32),
              Text('更多会员专属权益', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: privileges.map((priv) => _buildPrivilegeCard(priv)).toList(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text('了解更多会员权益', style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 32),
              Divider(),
              SizedBox(height: 8),
              Text('© 2025 会员活动中心. 保留所有权利.', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              SizedBox(height: 4),
              Text('如有疑问，请联系客服热线：400-123-4567', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, Map<String, dynamic> activity) {
    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                child: Image.asset(
                  activity['img'],
                  height: 120,
                  width: 340,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: activity['badgeColor'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    activity['badge'],
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity['title'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(activity['date'], style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(activity['location'], style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(activity['quota'], style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                  ],
                ),
                SizedBox(height: 8),
                Text(activity['desc'], style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF7B61FF)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('立即报名', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivilegeCard(Map<String, String> priv) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: priv['title'] == '提前预约'
              ? Color(0xFFE8F8F0)
              : priv['title'] == '专属客服'
                  ? Color(0xFFEAF1FF)
                  : Color(0xFFF2F7FD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(priv['title']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Text(priv['desc']!, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
} 