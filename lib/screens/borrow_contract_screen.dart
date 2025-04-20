// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../models/deposit_transaction.dart';
import '../models/borrow_contract_model.dart';
import '../models/compensation_transaction.dart';
import '../models/report_damage_model.dart';
import '../models/donate_item_model.dart';
import '../services/api_service.dart';
import '../widgets/homepage/custom_header.dart';
import '../widgets/homepage/custom_footer.dart';
import 'package:intl/intl.dart';

class BorrowContractScreen extends StatefulWidget {
  @override
  _BorrowContractScreenState createState() => _BorrowContractScreenState();
}

class _BorrowContractScreenState extends State<BorrowContractScreen> {
  late Future<List<BorrowContract>> _borrowContractsFuture;
  List<DepositTransaction> _depositTransactions = [];
  List<CompensationTransaction> _compensations = [];
  List<ReportDamage> _reportDamages = [];
  Map<int, DonateItem> _donateItemsById = {};

  String _formatCurrency(num amount) {
    final formatter = NumberFormat('#,###', 'en_US');
    return '${formatter.format(amount)} đ';
  }

  @override
  void initState() {
    super.initState();
    _borrowContractsFuture = ApiService().fetchBorrowContract();
    ApiService.fetchDepositTransactions().then((deposits) {
      setState(() {
        _depositTransactions = deposits;
      });
    });
    ApiService.fetchCompensationTransactions().then((list) {
      setState(() {
        _compensations = list;
      });
    });
    ApiService.fetchReportDamages().then((list) {
      setState(() {
        _reportDamages = list;
      });
    });
  }

  ReportDamage _getReportDamageForContract(int contractId) {
    final compensation = _compensations.firstWhere(
      (c) => c.contractId == contractId,
      orElse: () => CompensationTransaction.empty(),
    );
    return _reportDamages.firstWhere(
      (r) => r.reportId == compensation.reportDamageId,
      orElse: () => ReportDamage.empty(),
    );
  }

  Widget _buildReturnStatus(DonateItem donateItem, num originalDeposit,
      num usedDeposit, ReportDamage? reportDamage) {
    final returned = originalDeposit - usedDeposit;
    if (reportDamage == null || reportDamage.reportId == 0) {
      return const Text(
        "🔵 Returned - Processing",
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      );
    } else if (reportDamage.damageFee > 0) {
      return RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text: "🟠 Returned - With Damage Fee - ",
              style:
                  TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: _formatCurrency(returned),
              style: const TextStyle(
                  color: Colors.orange, fontWeight: FontWeight.bold),
            ),
            const TextSpan(
              text: " returned",
              style:
                  TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            )
          ],
        ),
      );
    } else {
      return const Text(
        "✅ Returned - No Issues",
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CustomHeader(showBackButton: true, title: "Borrow Contracts"),
      ),
      body: FutureBuilder<List<BorrowContract>>(
        future: _borrowContractsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1976D2)),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(
                  color: Color(0xFFD32F2F),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No contracts found",
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          List<BorrowContract> contracts = snapshot.data!;
          contracts.sort((a, b) => b.contractId.compareTo(a.contractId));

          return FutureBuilder<List<DonateItem>>(
            future: Future.wait(
                contracts.map((c) => ApiService.fetchDonateItemById(c.itemId))),
            builder: (context, itemSnap) {
              if (itemSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (itemSnap.hasError) {
                return Center(child: Text("Error loading item data"));
              } else {
                final items = itemSnap.data ?? [];
                _donateItemsById = {for (var item in items) item.itemId: item};

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  itemCount: contracts.length,
                  itemBuilder: (context, index) {
                    final contract = contracts[index];
                    final deposit = _depositTransactions.firstWhere(
                      (d) => d.contractId == contract.contractId,
                      orElse: () => DepositTransaction.empty(),
                    );
                    final compensation = _compensations.firstWhere(
                      (c) => c.contractId == contract.contractId,
                      orElse: () => CompensationTransaction.empty(),
                    );
                    final donateItem = _donateItemsById[contract.itemId];
                    final reportDamage =
                        _getReportDamageForContract(contract.contractId);

                    final originalDeposit = deposit.amount;
                    final damageFee = reportDamage.damageFee;
                    final usedFromDeposit = compensation.usedDepositAmount;
                    final extraPayment = compensation.extraPaymentRequired;
                    final returnedToYou = originalDeposit - usedFromDeposit;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        iconColor: Colors.transparent,
                        collapsedIconColor: Colors.transparent,
                        leading: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.description,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        title: const Text(
                          'Borrow Contract',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            if (donateItem != null)
                              _buildReturnStatus(donateItem, originalDeposit,
                                  usedFromDeposit, reportDamage),
                            const SizedBox(height: 4),
                            Text(
                              'Borrower: ${contract.fullName}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.expand_more,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(12)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle("Contract Details"),
                                _buildInfoRow(
                                    Icons.email, 'Email:', contract.email),
                                _buildInfoRow(Icons.phone, 'Phone Number:',
                                    contract.phoneNumber),
                                _buildInfoRow(
                                    Icons.monetization_on,
                                    'Device Value:',
                                    _formatCurrency(contract.itemValue)),
                                _buildInfoRow(
                                    Icons.calendar_today,
                                    'Expected Return Date:',
                                    _formatDate(contract.expectedReturnDate
                                        .toString())),
                                const Divider(height: 20, thickness: 1),
                                if (contract.requestDetail != null) ...[
                                  _buildSectionTitle("Borrow Request Details"),
                                  _buildInfoRow(
                                      Icons.laptop,
                                      'Device Name:',
                                      contract.requestDetail!['data']
                                              ['itemName'] ??
                                          'N/A'),
                                  _buildInfoRow(
                                      Icons.event,
                                      'Start Date:',
                                      _formatDate(
                                          contract.requestDetail!['data']
                                              ['startDate'])),
                                  _buildInfoRow(
                                      Icons.event,
                                      'End Date:',
                                      _formatDate(contract
                                          .requestDetail!['data']['endDate'])),
                                ],
                                const Divider(height: 20, thickness: 1),
                                _buildSectionTitle("Financial Summary"),
                                _buildInfoRow(Icons.money, 'Original Deposit:',
                                    _formatCurrency(originalDeposit)),
                                if (donateItem?.status == 'Return processing')
                                  const Text(
                                    '⌛ Your return is being processed, deposit status pending...',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  )
                                else if (damageFee > 0) ...[
                                  _buildInfoRow(Icons.warning, 'Damage Fee:',
                                      _formatCurrency(damageFee),
                                      valueColor: Colors.red),
                                  _buildInfoRow(
                                      Icons.remove_circle_outline,
                                      'Used from Deposit:',
                                      _formatCurrency(usedFromDeposit),
                                      valueColor: Colors.orange),
                                  if (extraPayment > 0)
                                    _buildInfoRow(
                                        Icons.attach_money,
                                        'Extra Payment Required:',
                                        _formatCurrency(extraPayment),
                                        valueColor: Colors.red),
                                  _buildInfoRow(
                                      Icons.arrow_circle_down,
                                      'Returned to You:',
                                      _formatCurrency(returnedToYou),
                                      valueColor: Colors.green),
                                  const Text(
                                    '✓ Device returned with damage – partial deposit refunded after compensation.',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  )
                                ] else
                                  _buildInfoRow(
                                      Icons.arrow_circle_down,
                                      'Returned to You:',
                                      _formatCurrency(originalDeposit),
                                      valueColor: Colors.green),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
      bottomNavigationBar: const CustomFooter(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Color(0xFF1976D2),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1976D2), size: 18),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF1A1A1A),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? const Color(0xFF6B7280),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
