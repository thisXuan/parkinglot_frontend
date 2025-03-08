class Coordinate{
  double xCoordinate;
  double yCoordinate;
  
  Coordinate({
    required this.xCoordinate,
    required this.yCoordinate
  });
  
  factory Coordinate.fromJson(Map<String, dynamic> json){
    return Coordinate(
        xCoordinate: json['xCoordinate'],
        yCoordinate: json['yCoordinate']
    );
  }
}