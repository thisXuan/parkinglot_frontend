class Order{
  int id;
  int userId;
  int voucherId;
  String time;
  double payValue;
  int type;

  Order({
    required this.id,
    required this.userId,
    required this.voucherId,
    required this.time,
    required this.payValue,
    required this.type
});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
        id: json['id'],
        userId: json['userId'],
        voucherId: json['voucherId'],
        time: json['time'],
        payValue: json['payValue'],
        type: json['type']
    );
  }
}