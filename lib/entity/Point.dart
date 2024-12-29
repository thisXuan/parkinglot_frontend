class Point {
  final double x;
  final double y;
  final String floor;

  Point({required this.x, required this.y, required this.floor});

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
        x: json['x'].toDouble() as double,
        y: json['y'].toDouble() as double,
        floor: json['floor'] as String);
  }
}