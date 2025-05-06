class Shop {
  final int shopId;
  final int userId;
  final String shopName;
  final String shopAddress;
  final String shopPhone;
  final String businessLicense;
  final String bankName;
  final String bankNumber;
  final String status;
  final DateTime createdDate;
  final DateTime? updatedDate;

  Shop({
    required this.shopId,
    required this.userId,
    required this.shopName,
    required this.shopAddress,
    required this.shopPhone,
    required this.businessLicense,
    required this.bankName,
    required this.bankNumber,
    required this.status,
    required this.createdDate,
    this.updatedDate,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      shopId: json['shopId'],
      userId: json['userId'],
      shopName: json['shopName'],
      shopAddress: json['shopAddress'],
      shopPhone: json['shopPhone'],
      businessLicense: json['businessLicense'],
      bankName: json['bankName'],
      bankNumber: json['bankNumber'],
      status: json['status'],
      createdDate: DateTime.parse(json['createdDate']),
      updatedDate: json['updatedDate'] != null
          ? DateTime.parse(json['updatedDate'] as String)
          : null,
    );
  }
}
