class DataDTO{
  int visitor;
  int parking;
  int store;

  DataDTO({
   required this.visitor,
   required this.parking,
   required this.store
});

  factory DataDTO.fromJson(Map<String, dynamic> json) {
    return DataDTO(
        visitor: json['visitor'],
        parking: json['parking'],
        store: json['store']
    );
  }
}