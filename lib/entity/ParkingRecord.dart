class ParkingRecord {
  int id;
  String carName;
  String entryTime;
  String exitTime;
  String parkingSpace;
  String payment;

  ParkingRecord(
      {required this.id,
        required this.carName,
        required this.entryTime,
        required this.exitTime,
        required this.parkingSpace,
        required this.payment});

  factory ParkingRecord.fromJson(Map<String, dynamic> json) {
    return ParkingRecord(
        id: json['id'],
        carName: json['carname'] ?? '',
        entryTime: json['entrytime'] ?? '',
        exitTime: json['exittime'] ?? '尚未离开',
        parkingSpace: json['parkingspace'] ?? '',
        payment: json['payment']??'待支付'
    );
  }
}