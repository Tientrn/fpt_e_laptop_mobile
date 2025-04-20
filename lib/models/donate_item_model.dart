class DonateItem {
  final int itemId;
  final String itemName;
  final String itemImage;
  final String createdDate;
  final String updatedDate;
  final String cpu;
  final String ram;
  final String storage;
  final String screenSize;
  final String conditionItem;
  final int totalBorrowedCount;
  final String status;
  final int userId;
  final int donateFormId;
  final String serialNumber;
  final String model;
  final String color;
  final String graphicsCard;
  final String battery;
  final String ports;
  final int productionYear;
  final String operatingSystem;
  final String description;
  final int categoryId;

  DonateItem({
    required this.itemId,
    required this.itemName,
    required this.itemImage,
    required this.createdDate,
    required this.updatedDate,
    required this.cpu,
    required this.ram,
    required this.storage,
    required this.screenSize,
    required this.conditionItem,
    required this.totalBorrowedCount,
    required this.status,
    required this.userId,
    required this.donateFormId,
    required this.serialNumber,
    required this.model,
    required this.color,
    required this.graphicsCard,
    required this.battery,
    required this.ports,
    required this.productionYear,
    required this.operatingSystem,
    required this.description,
    required this.categoryId,
  });

  factory DonateItem.fromJson(Map<String, dynamic> json) {
    return DonateItem(
      itemId: json['itemId'],
      itemName: json['itemName'],
      itemImage: json['itemImage'],
      createdDate: json['createdDate'],
      updatedDate: json['updatedDate'],
      cpu: json['cpu'],
      ram: json['ram'],
      storage: json['storage'],
      screenSize: json['screenSize'],
      conditionItem: json['conditionItem'],
      totalBorrowedCount: json['totalBorrowedCount'],
      status: json['status'],
      userId: json['userId'],
      donateFormId: json['donateFormId'],
      serialNumber: json['serialNumber'],
      model: json['model'],
      color: json['color'],
      graphicsCard: json['graphicsCard'],
      battery: json['battery'],
      ports: json['ports'],
      productionYear: json['productionYear'],
      operatingSystem: json['operatingSystem'],
      description: json['description'],
      categoryId: json['categoryId'],
    );
  }
}
