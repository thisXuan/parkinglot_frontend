class Voucher{
  int id;
  int storeId;
  String title;
  String subtitle;
  String rules;
  double payValue;
  int actualValue;
  String image;

  Voucher({
   required this.id,
    required this.storeId,
    required this.title,
    required this.subtitle,
    required this.rules,
    required this.payValue,
    required this.actualValue,
    required this.image
});

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
        id: json['id'],
        storeId: json['storeid'],
        title: json['title']??'',
        subtitle: json['subtitle']??'',
        rules: json['rules']??'',
        payValue: json['payvalue']??0,
        actualValue: json['actualvalue']??0,
        image: json['image']??''
    );
  }
}