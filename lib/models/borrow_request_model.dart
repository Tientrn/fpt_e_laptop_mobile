class BorrowRequest {
  final int itemId;
  final DateTime startDate;
  final DateTime endDate;

  BorrowRequest({
    required this.itemId,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      "itemId": itemId,
      "startDate": startDate.toIso8601String(),
      "endDate": endDate.toIso8601String(),
    };
  }
}
