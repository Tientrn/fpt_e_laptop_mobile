import 'dart:convert';

class FeedbackModel {
  final int id;
  final int orderDetailId;
  final int productId;
  final int userId;
  final int rating;
  final String comments;
  final bool isAnonymous;
  final DateTime createdDate;

  FeedbackModel({
    required this.id,
    required this.orderDetailId,
    required this.productId,
    required this.userId,
    required this.rating,
    required this.comments,
    required this.isAnonymous,
    required this.createdDate,
  });

  // Chuyển từ JSON sang Model
  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] ?? 0,
      orderDetailId: json['orderDetailId'] ?? 0,
      productId: json['productId'] ?? 0,
      userId: json['userId'] ?? 0,
      rating: json['rating'] ?? 0,
      comments: json['comments'] ?? '',
      isAnonymous: json['isAnonymous'] ?? false,
      createdDate:
          DateTime.tryParse(json['createdDate'] ?? '') ?? DateTime(1970, 1, 1),
    );
  }

  // Chuyển từ Model sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderDetailId': orderDetailId,
      'productId': productId,
      'userId': userId,
      'rating': rating,
      'comments': comments,
      'isAnonymous': isAnonymous,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  // Chuyển danh sách JSON sang danh sách FeedbackModel
  static List<FeedbackModel> fromJsonList(String str) {
    final List<dynamic> jsonData = json.decode(str);
    return jsonData.map((item) => FeedbackModel.fromJson(item)).toList();
  }
}
