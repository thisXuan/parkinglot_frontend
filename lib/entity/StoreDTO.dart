class StoreDTO {
  final String name;
  final double x;
  final double y;
  final String floorNumber;

  StoreDTO({
    required this.name,
    required this.x,
    required this.y,
    required this.floorNumber,
  });

  factory StoreDTO.fromJson(Map<String, dynamic> json) {
    return StoreDTO(
      name: json['name'],
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      floorNumber: json['floorNumber'],
    );
  }
} 