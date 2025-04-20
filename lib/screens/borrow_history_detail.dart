import 'package:flutter/material.dart';
import 'package:mobile_fpt_e_laptop/services/api_service.dart';
import '../utils/api_constants.dart';
import '../widgets/homepage/custom_header.dart';
import '../widgets/homepage/custom_footer.dart';

class BorrowHistoryDetailScreen extends StatefulWidget {
  final int requestId;
  final int borrowHistoryId;

  const BorrowHistoryDetailScreen({
    Key? key,
    required this.borrowHistoryId,
    required this.requestId,
  }) : super(key: key);

  @override
  _BorrowHistoryDetailScreenState createState() =>
      _BorrowHistoryDetailScreenState();
}

class _BorrowHistoryDetailScreenState extends State<BorrowHistoryDetailScreen> {
  bool isLoading = false;
  Map<String, dynamic>? requestDetails;
  final TextEditingController _feedbackController = TextEditingController();
  double _rating = 5.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchRequestDetails();
  }

  Future<void> _fetchRequestDetails() async {
    setState(() => isLoading = true);
    try {
      final apiService = ApiService();
      final response = await apiService
          .getRequest(ApiConstants.getBorrowRequest(widget.requestId));

      if (response.containsKey('data')) {
        setState(() {
          requestDetails = response['data'];
        });
      } else {
        _showSnackBar("No details available.");
      }
    } catch (e) {
      _showSnackBar("Error loading data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitFeedback() async {
    if (_feedbackController.text.isEmpty) {
      _showSnackBar("Please enter a comment.");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final apiService = ApiService();
      final feedbackData = {
        "borrowHistoryId": widget.borrowHistoryId,
        "itemId": requestDetails?["itemId"],
        "rating": _rating.toInt(),
        "comments": _feedbackController.text,
      };

      final response = await apiService.postFeedback(feedbackData);

      if (response["isSuccess"]) {
        _showSnackBar("Feedback submitted successfully!");
        _feedbackController.clear();
        setState(() {
          _rating = 5.0;
        });
      } else {
        _showSnackBar(response["message"] ?? "Unknown error.");
      }
    } catch (e) {
      _showSnackBar("Error submitting feedback: $e");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: message.contains("success")
            ? const Color(0xFF2E7D32)
            : const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child:
            CustomHeader(showBackButton: true, title: "Borrow History Details"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1976D2)))
          : requestDetails == null
              ? const Center(
                  child: Text(
                    "No details available.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection(),
                      const SizedBox(height: 16),
                      _buildFeedbackSection(),
                    ],
                  ),
                ),
      bottomNavigationBar: const CustomFooter(),
    );
  }

  Widget _buildDetailSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              requestDetails?["itemName"] ?? "Unknown Name",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.event,
              "Start Date",
              requestDetails?["startDate"],
            ),
            _buildInfoRow(
              Icons.event,
              "End Date",
              requestDetails?["endDate"],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1976D2), size: 18),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF1A1A1A),
            ),
          ),
          Expanded(
            child: Text(
              value?.split('T')[0] ?? "Unknown",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Submit Feedback",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Enter your comment...",
                labelStyle: const TextStyle(color: Color(0xFF6B7280)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF1976D2)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Rating:",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  "${_rating.toInt()}/5",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Slider(
              value: _rating,
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: const Color(0xFF1976D2),
              inactiveColor: const Color(0xFFE0E0E0),
              thumbColor: Colors.white,
              label: _rating.toInt().toString(),
              onChanged: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                  shadowColor: const Color(0xFF1976D2).withOpacity(0.3),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.transparent,
                ).copyWith(
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) => Colors.transparent,
                  ),
                  overlayColor: MaterialStateProperty.all(Colors.white10),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Submit Feedback",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
