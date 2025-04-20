class BorrowRequestItem {
  final int requestId;
  final int userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final int itemId;
  final String itemName;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final String? majorName;

  BorrowRequestItem({
    required this.requestId,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.itemId,
    required this.itemName,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.majorName,
  });

  factory BorrowRequestItem.fromJson(Map<String, dynamic> json) {
    return BorrowRequestItem(
      requestId: json['requestId'],
      userId: json['userId'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      itemId: json['itemId'],
      itemName: json['itemName'],
      status: json['status'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      majorName: json['majorName'], // Nếu có
    );
  }
}
