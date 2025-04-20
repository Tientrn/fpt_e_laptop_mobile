class FeedbackBorrow {
  final int feedbackBorrowId;
  final int borrowHistoryId;
  final int itemId;
  final int userId;
  final DateTime feedbackDate;
  final int rating;
  final String comments;
  final bool isAnonymous;

  FeedbackBorrow({
    required this.feedbackBorrowId,
    required this.borrowHistoryId,
    required this.itemId,
    required this.userId,
    required this.feedbackDate,
    required this.rating,
    required this.comments,
    required this.isAnonymous,
  });

  factory FeedbackBorrow.fromJson(Map<String, dynamic> json) {
    return FeedbackBorrow(
      feedbackBorrowId: json['feedbackBorrowId'],
      borrowHistoryId: json['borrowHistoryId'],
      itemId: json['itemId'],
      userId: json['userId'],
      feedbackDate: DateTime.parse(json['feedbackDate']),
      rating: json['rating'],
      comments: json['comments'],
      isAnonymous: json['isAnonymous'],
    );
  }
}
