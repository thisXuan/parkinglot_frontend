class StoreDTO {
  final String name;
  final double x;
  final double y;
  final String floorNumber;
  final double scale;

  StoreDTO({
    required this.name,
    required this.x,
    required this.y,
    required this.floorNumber,
    required this.scale,
  });

  factory StoreDTO.fromJson(Map<String, dynamic> json) {
    return StoreDTO(
      name: json['name'],
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      floorNumber: json['floorNumber'],
      scale: json['scale'].toDouble(),
    );
  }
} 