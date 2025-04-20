class BorrowHistory {
  final int borrowHistoryId;
  final int requestId;
  final int itemId;
  final int userId;
  final DateTime borrowDate;
  final DateTime returnDate;
  final String status; // Thêm trường status

  BorrowHistory({
    required this.borrowHistoryId,
    required this.requestId,
    required this.itemId,
    required this.userId,
    required this.borrowDate,
    required this.returnDate,
    required this.status, // Thêm status vào constructor
  });

  // Factory method to create BorrowHistory from JSON response
  factory BorrowHistory.fromJson(Map<String, dynamic> json) {
    return BorrowHistory(
      borrowHistoryId: json['borrowHistoryId'],
      requestId: json['requestId'],
      itemId: json['itemId'],
      userId: json['userId'],
      borrowDate: DateTime.parse(json['borrowDate']),
      returnDate: DateTime.parse(json['returnDate']),
      status: json['status'], // Lấy status từ JSON
    );
  }
}
