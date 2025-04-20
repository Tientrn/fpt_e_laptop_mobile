class OrderDetail {
  final int orderItemId;
  final int orderId;
  final int productId;
  final int quantity;
  final num priceItem;

  OrderDetail({
    required this.orderItemId,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.priceItem,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      orderItemId: json['orderItemId'],
      orderId: json['orderId'],
      productId: json['productId'],
      quantity: json['quantity'],
      priceItem: json['priceItem'],
    );
  }
}
