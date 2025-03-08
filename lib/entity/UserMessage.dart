class UserMessage {
  int id;
  String name;
  String phone;
  String point;
  int type;

  UserMessage({
    required this.id,
    required this.name,
    required this.phone,
    required this.point,
    required this.type,
  });

  factory UserMessage.fromJson(Map<String, dynamic> json) {
    return UserMessage(
        id: json['id']??0,
        name: json['name']??'',
        phone: json['phone']??'',
        point: json['point']??'',
        type: json['type']??0
    );
  }

  @override
  String toString() {
    return 'UserMessage{id: $id, name: $name, phone: $phone, point: $point, type: $type}';
  }
}