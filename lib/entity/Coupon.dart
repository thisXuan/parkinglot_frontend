class Coupon {
  int id;
  int storeId;
  String title;
  String rules;
  int payPoint;
  int status;
  String image;
  int saleCount;

  Coupon({
    required this.id,
    required this.storeId,
    required this.title,
    required this.rules,
    required this.payPoint,
    required this.status,
    required this.image,
    required this.saleCount
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      storeId: json['storeId'],
      title: json['title'],
      rules: json['rules'],
      payPoint: json['payPoint'],
      status: json['status'],
      image: json['image']??'',
      saleCount: json['saleCount']
    );
  }

}