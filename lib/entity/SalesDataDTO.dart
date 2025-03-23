class SalesDataDTO{
  String saleDate;
  int totalSales;

  SalesDataDTO({
   required this.saleDate,
   required this.totalSales
});

  factory SalesDataDTO.fromJson(Map<String, dynamic> json) {
    return SalesDataDTO(
        saleDate: json['saleDate'],
        totalSales: json['totalSales']
    );
  }
}