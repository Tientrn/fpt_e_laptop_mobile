import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/borrow_request_item.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import '../widgets/homepage/custom_header.dart';
import '../widgets/homepage/custom_footer.dart';

class BorrowRequestsScreen extends StatefulWidget {
  const BorrowRequestsScreen({super.key});

  @override
  State<BorrowRequestsScreen> createState() => _BorrowRequestsScreenState();
}

class _BorrowRequestsScreenState extends State<BorrowRequestsScreen> {
  final ApiService _apiService = ApiService();
  List<BorrowRequestItem> _borrowRequests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBorrowRequests();
  }

  Future<void> _fetchBorrowRequests() async {
    try {
      List<BorrowRequestItem> requests =
          await _apiService.fetchUserBorrowRequests();
      setState(() {
        _borrowRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load borrow requests.";
      });
      print("❌ Error loading borrow requests: $e");
    }
  }

  Future<void> _cancelBorrowRequest(int requestId) async {
    try {
      await _apiService.deleteBorrowRequest(requestId);

      setState(() {
        _borrowRequests = _borrowRequests
            .where((request) => request.requestId != requestId)
            .toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Borrow request canceled successfully.'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    } catch (e) {
      print("❌ Error canceling borrow request: $e");
      _handleError(e.toString());
    }
  }

  void _handleError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: const Color(0xFFD32F2F),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CustomHeader(showBackButton: true, title: "Borrow Requests"),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1976D2)))
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFD32F2F),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : _borrowRequests.isEmpty
                  ? const Center(
                      child: Text(
                        "No borrow requests found!",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: _borrowRequests.length,
                      itemBuilder: (context, index) {
                        final request = _borrowRequests[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.itemName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Borrower Information",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _buildInfoRow(
                                    "Borrower Name", request.fullName),
                                _buildInfoRow("Email", request.email),
                                _buildInfoRow(
                                    "Phone Number", request.phoneNumber),
                                const SizedBox(height: 10),
                                const Text(
                                  "Borrow Details",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _buildInfoRow("Device Name", request.itemName),
                                _buildInfoRow(
                                  "Start Date",
                                  DateFormat('dd/MM/yyyy')
                                      .format(request.startDate),
                                ),
                                _buildInfoRow(
                                  "End Date",
                                  DateFormat('dd/MM/yyyy')
                                      .format(request.endDate),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          "Status: ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: Color(0xFF1A1A1A),
                                          ),
                                        ),
                                        Chip(
                                          label: Text(
                                            request.status,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          backgroundColor:
                                              _getStatusColor(request.status),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          elevation: 1,
                                          shadowColor:
                                              Colors.black.withOpacity(0.1),
                                        ),
                                      ],
                                    ),
                                    if (request.status == "Pending")
                                      GestureDetector(
                                        onTap: () =>
                                            _confirmCancel(request.requestId),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFFD32F2F),
                                                Color(0xFFF44336),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.cancel,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      bottomNavigationBar: const CustomFooter(),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF1A1A1A),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return const Color(0xFFFFB300);
      case "Approved":
        return const Color(0xFF2E7D32);
      case "Rejected":
        return const Color(0xFFD32F2F);
      default:
        return const Color(0xFF757575);
    }
  }

  void _confirmCancel(int requestId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF42A5F5), width: 1),
        ),
        title: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: const Text(
            "Cancel Request?",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        content: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            "Are you sure you want to cancel this borrow request?",
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B7280).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "No",
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _cancelBorrowRequest(requestId);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFD32F2F), Color(0xFFF44336)],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: const Text(
                    "Yes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
