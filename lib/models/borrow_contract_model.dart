class BorrowContract {
  final int contractId;
  final int requestId;
  final int itemId;
  final int userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String status;
  final DateTime contractDate;
  final String terms;
  final String conditionBorrow;
  final int itemValue;
  final DateTime expectedReturnDate;
  Map<String, dynamic>? requestDetail;

  BorrowContract({
    required this.contractId,
    required this.requestId,
    required this.itemId,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.status,
    required this.contractDate,
    required this.terms,
    required this.conditionBorrow,
    required this.itemValue,
    required this.expectedReturnDate,
    this.requestDetail,
  });

  factory BorrowContract.fromJson(Map<String, dynamic> json) {
    return BorrowContract(
      contractId: json['contractId'],
      requestId: json['requestId'],
      itemId: json['itemId'],
      userId: json['userId'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      status: json['status'],
      contractDate: DateTime.parse(json['contractDate']),
      terms: json['terms'],
      conditionBorrow: json['conditionBorrow'],
      itemValue: (json['itemValue'] as num).toInt(),
      expectedReturnDate: DateTime.parse(json['expectedReturnDate']),
      requestDetail: null,
    );
  }
}
