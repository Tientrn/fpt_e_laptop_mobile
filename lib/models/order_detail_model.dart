class OrderDetailRequest {
  final int orderId;
  final int productId;
  final int quantity;
  final int priceItem;

  OrderDetailRequest({
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.priceItem,
  });

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "productId": productId,
      "quantity": quantity,
      "priceItem": priceItem,
    };
  }
}
