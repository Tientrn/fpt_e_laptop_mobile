class ItemModel {
  final int itemId;
  final String itemName;
  final String itemImage;
  final String createdDate;
  final String cpu;
  final String ram;
  final String storage;
  final String screenSize;
  final String conditionItem;
  final int totalBorrowedCount;
  final String status;
  final int? categoryId;

  ItemModel({
    required this.itemId,
    required this.itemName,
    required this.itemImage,
    required this.createdDate,
    required this.cpu,
    required this.ram,
    required this.storage,
    required this.screenSize,
    required this.conditionItem,
    required this.totalBorrowedCount,
    required this.status,
    this.categoryId,
  });

  // Chuyển từ JSON sang đối tượng ItemModel
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      itemId: json['itemId'],
      itemName: json['itemName'],
      itemImage: json['itemImage'],
      createdDate: json['createdDate'],
      cpu: json['cpu'],
      ram: json['ram'],
      storage: json['storage'],
      screenSize: json['screenSize'],
      conditionItem: json['conditionItem'],
      totalBorrowedCount: json['totalBorrowedCount'],
      status: json['status'],
      categoryId: json['categoryId'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'itemImage': itemImage,
      'createdDate': createdDate,
      'cpu': cpu,
      'ram': ram,
      'storage': storage,
      'screenSize': screenSize,
      'conditionItem': conditionItem,
      'totalBorrowedCount': totalBorrowedCount,
      'status': status,
    };
  }
}
