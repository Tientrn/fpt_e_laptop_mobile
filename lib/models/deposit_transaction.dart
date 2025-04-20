class DepositTransaction {
  final int depositId;
  final int contractId;
  final int userId;
  final String status;
  final num amount;
  final DateTime depositDate;

  DepositTransaction({
    required this.depositId,
    required this.contractId,
    required this.userId,
    required this.status,
    required this.amount,
    required this.depositDate,
  });

  factory DepositTransaction.fromJson(Map<String, dynamic> json) {
    return DepositTransaction(
      depositId: json['depositId'],
      contractId: int.parse(json['contractId'].toString()),
      userId: json['userId'],
      status: json['status'],
      amount: (json['amount'] as num).toInt(),
      depositDate: DateTime.parse(json['depositDate']),
    );
  }
  factory DepositTransaction.empty() {
    return DepositTransaction(
      depositId: 0,
      contractId: 0,
      userId: 0,
      status: '',
      amount: 0,
      depositDate: DateTime.now(),
    );
  }
}
