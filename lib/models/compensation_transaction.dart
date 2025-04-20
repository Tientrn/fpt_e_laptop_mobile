class CompensationTransaction {
  final int compensationId;
  final int contractId;
  final int userId;
  final int reportDamageId;
  final int depositTransactionId;
  final num compensationAmount;
  final num usedDepositAmount;
  final num extraPaymentRequired;
  final String status;

  CompensationTransaction({
    required this.compensationId,
    required this.contractId,
    required this.userId,
    required this.reportDamageId,
    required this.depositTransactionId,
    required this.compensationAmount,
    required this.usedDepositAmount,
    required this.extraPaymentRequired,
    required this.status,
  });

  factory CompensationTransaction.fromJson(Map<String, dynamic> json) {
    return CompensationTransaction(
      compensationId: json['compensationId'],
      contractId: json['contractId'],
      userId: json['userId'],
      reportDamageId: json['reportDamageId'],
      depositTransactionId: json['depositTransactionId'],
      compensationAmount: json['compensationAmount'],
      usedDepositAmount: json['usedDepositAmount'],
      extraPaymentRequired: json['extraPaymentRequired'],
      status: json['status'],
    );
  }
  factory CompensationTransaction.empty() {
    return CompensationTransaction(
      compensationId: 0,
      contractId: 0,
      userId: 0,
      reportDamageId: 0,
      depositTransactionId: 0,
      compensationAmount: 0,
      usedDepositAmount: 0,
      extraPaymentRequired: 0,
      status: '',
    );
  }
}
