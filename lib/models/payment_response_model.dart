class PaymentResponse {
  final int paymentId;
  final int orderId;
  final int paymentMethodId;
  final String email;
  final String fullName;
  final int amount;
  final String status;
  final String paymentDate;
  final String transactionCode;

  PaymentResponse({
    required this.paymentId,
    required this.orderId,
    required this.paymentMethodId,
    required this.email,
    required this.fullName,
    required this.amount,
    required this.status,
    required this.paymentDate,
    required this.transactionCode,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      paymentId: json['paymentId'],
      orderId: json['orderId'],
      paymentMethodId: json['paymentMethodId'],
      email: json['email'],
      fullName: json['fullName'],
      amount: (json['amount'] as num).toInt(),
      status: json['status'],
      paymentDate: json['paymentDate'],
      transactionCode: json['transactionCode'],
    );
  }
}
