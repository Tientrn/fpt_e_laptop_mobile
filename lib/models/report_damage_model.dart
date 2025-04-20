class ReportDamage {
  final int reportId;
  final int itemId;
  final int borrowHistoryId;
  final String note;
  final String conditionBeforeBorrow;
  final String conditionAfterReturn;
  final String createdDate;
  final num damageFee;
  final String imageUrlReport;

  ReportDamage({
    required this.reportId,
    required this.itemId,
    required this.borrowHistoryId,
    required this.note,
    required this.conditionBeforeBorrow,
    required this.conditionAfterReturn,
    required this.createdDate,
    required this.damageFee,
    required this.imageUrlReport,
  });

  factory ReportDamage.fromJson(Map<String, dynamic> json) {
    return ReportDamage(
      reportId: json['reportId'],
      itemId: json['itemId'],
      borrowHistoryId: json['borrowHistoryId'],
      note: json['note'],
      conditionBeforeBorrow: json['conditionBeforeBorrow'],
      conditionAfterReturn: json['conditionAfterReturn'],
      createdDate: json['createdDate'],
      damageFee: json['damageFee'] ?? 0,
      imageUrlReport: json['imageUrlReport'],
    );
  }
  static ReportDamage empty() {
    return ReportDamage(
      reportId: 0,
      itemId: 0,
      borrowHistoryId: 0,
      note: '',
      conditionBeforeBorrow: '',
      conditionAfterReturn: '',
      createdDate: '',
      damageFee: 0,
      imageUrlReport: '',
    );
  }
}
