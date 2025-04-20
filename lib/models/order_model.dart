class OrderRequest {
  final int userId;
  final int totalPrice;
  final String orderAddress;
  final String field;
  final String status;

  OrderRequest({
    required this.userId,
    required this.totalPrice,
    required this.orderAddress,
    required this.field,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "totalPrice": totalPrice,
      "orderAddress": orderAddress,
      "field": field,
      "status": status,
    };
  }
}

class OrderResponse {
  final int orderId;
  final int userId;
  final String createdDate;
  final num totalPrice;
  final String orderAddress;
  final String field;
  final String status;

  OrderResponse({
    required this.orderId,
    required this.userId,
    required this.createdDate,
    required this.totalPrice,
    required this.orderAddress,
    required this.field,
    required this.status,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      orderId: json['orderId'],
      userId: json['userId'],
      createdDate: json['createdDate'],
      totalPrice: json['totalPrice'],
      orderAddress: json['orderAddress'],
      field: json['field'],
      status: json['status'],
    );
  }
}
