class Car {
  int id;
  String carName;
  String updateTime;
  int userId;

  Car(
      {required this.id,
        required this.carName,
        required this.updateTime,
        required this.userId});

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
        id: json['id'],
        carName: json['carname'] ?? '',
        updateTime: json['updatetime'] ?? '',
        userId: json['userid'] ?? 0);
  }
}