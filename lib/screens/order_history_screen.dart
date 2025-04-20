import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/borrow_history_model.dart';
import '../models/order_detail.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import '../widgets/homepage/custom_header.dart';
import '../widgets/homepage/custom_footer.dart';
import 'OrderDetailsScreen.dart';
import 'borrow_history_detail.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  DateTime? selectedDate;
  bool isLoading = false;
  bool showAllBorrow = false;
  bool showAllOrder = false;

  List<BorrowHistory> borrowOrders = [];
  List<OrderResponse> purchaseOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory();
  }

  Future<void> _fetchOrderHistory() async {
    setState(() => isLoading = true);
    try {
      final apiService = ApiService();
      borrowOrders = await apiService.getBorrowHistory();
      purchaseOrders = await apiService.getOrdersByUserId();
    } catch (e) {
      debugPrint('Error fetching data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<BorrowHistory> _getFilteredBorrowOrders() {
    List<BorrowHistory> filtered = borrowOrders.where((order) {
      return selectedDate == null ||
          order.borrowDate.toIso8601String().split('T')[0] ==
              selectedDate!.toIso8601String().split('T')[0];
    }).toList();

    filtered.sort((a, b) => b.borrowHistoryId.compareTo(a.borrowHistoryId));
    return filtered;
  }

  List<OrderResponse> _getFilteredPurchaseOrders() {
    List<OrderResponse> filtered = purchaseOrders.where((order) {
      DateTime createdDate = DateTime.parse(order.createdDate);
      return selectedDate == null ||
          createdDate.toIso8601String().split('T')[0] ==
              selectedDate!.toIso8601String().split('T')[0];
    }).toList();

    filtered.sort((a, b) => b.orderId.compareTo(a.orderId));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    List<BorrowHistory> borrowList = _getFilteredBorrowOrders();
    List<BorrowHistory> visibleBorrowOrders =
        showAllBorrow ? borrowList : borrowList.take(3).toList();

    List<OrderResponse> orderList = _getFilteredPurchaseOrders();
    List<OrderResponse> visiblePurchaseOrders =
        showAllOrder ? orderList : orderList.take(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(
              showBackButton: true,
              title: "Order & Borrow History",
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildDateFilterSection(),
                    ),
                    const SizedBox(height: 12),
                    isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF1976D2),
                            ),
                          )
                        : Expanded(
                            child: ListView(
                              children: [
                                _buildSectionTitle("Borrow History"),
                                if (visibleBorrowOrders.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      'No borrow history!',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  )
                                else
                                  ...visibleBorrowOrders
                                      .map(_buildBorrowOrderCard),
                                if (borrowList.length > 3)
                                  TextButton(
                                    onPressed: () => setState(
                                        () => showAllBorrow = !showAllBorrow),
                                    child: Text(
                                      showAllBorrow ? 'Show Less' : 'Show More',
                                      style: const TextStyle(
                                          color: Color(0xFF1976D2)),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                _buildSectionTitle("Order History"),
                                if (visiblePurchaseOrders.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      'No order history!',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  )
                                else
                                  ...visiblePurchaseOrders
                                      .map(_buildPurchaseOrderCard),
                                if (orderList.length > 3)
                                  TextButton(
                                    onPressed: () => setState(
                                        () => showAllOrder = !showAllOrder),
                                    child: Text(
                                      showAllOrder ? 'Show Less' : 'Show More',
                                      style: const TextStyle(
                                          color: Color(0xFF1976D2)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1976D2),
        ),
      ),
    );
  }

  Widget _buildBorrowOrderCard(BorrowHistory order) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BorrowHistoryDetailScreen(
              borrowHistoryId: order.borrowHistoryId,
              requestId: order.requestId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0).withOpacity(0.5),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Borrow Record',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.calendar_today, 'Borrow Date:',
                _formatDate(order.borrowDate)),
            _buildInfoRow(Icons.calendar_today, 'Return Date:',
                _formatDate(order.returnDate)),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseOrderCard(OrderResponse order) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(
              orderId: order.orderId,
              orderStatus: order.status,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0).withOpacity(0.5),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Record',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.calendar_today, 'Order Date:',
                _formatDate(DateTime.parse(order.createdDate))),
            _buildInfoRow(Icons.location_on, 'Address:', order.orderAddress),
            _buildInfoRow(Icons.attach_money, 'Total:',
                '\$${_formatCurrency(order.totalPrice)}'),
            _buildInfoRow(Icons.info, 'Status:', order.status,
                color: _getStatusColor(order.status)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? color}) {
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
                color: color ?? const Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterSection() {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (pickedDate != null) {
          setState(() => selectedDate = pickedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              selectedDate == null ? 'Select Date' : _formatDate(selectedDate!),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF2E7D32);
      case 'pending':
        return const Color(0xFFFFB300);
      case 'cancelled':
        return const Color(0xFFD32F2F);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
  String _formatCurrency(num value) => NumberFormat('#,###').format(value);
}
