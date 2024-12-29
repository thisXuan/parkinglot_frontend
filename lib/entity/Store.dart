class Store {
  int id;
  String storeName;
  String serviceCategory;
  String serviceType;
  String businessHours;
  String address;
  int floorNumber;
  String description;
  String recommendedServices;
  String image;

  Store(
      {required this.id,
        required this.storeName,
        required this.serviceCategory,
        required this.serviceType,
        required this.businessHours,
        required this.address,
        required this.floorNumber,
        this.description = '',
        this.recommendedServices = '',
        required this.image});

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
        id: json['id'],
        storeName: json['storeName'] ?? '',
        serviceCategory: json['serviceCategory'] ?? '',
        serviceType: json['serviceType'] ?? '',
        businessHours: json['businessHours'] ?? '营业时间未知',
        address: json['address'] ?? '',
        floorNumber: json['floorNumber'] ?? 0,
        description: json['description'] ?? '',
        recommendedServices: json['recommendedServices'] ?? '',
        image: json['image'] ?? '');
  }
}