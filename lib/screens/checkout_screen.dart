import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../models/order_detail_model.dart';
import '../models/order_model.dart';
import '../models/payment_response_model.dart';
import '../utils/api_constants.dart';
import '../widgets/homepage/custom_header.dart';
import '../routes/app_routes.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with WidgetsBindingObserver {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isHandlingDeepLinkCancel = false;
  bool _isHandlingDeepLink = false;
  bool _initialUriHandled = false; // <-- thêm cờ này để kiểm tra gọi duy nhất
  final Set<String> _handledUris = {};
  AppLifecycleState? _lastState;
  int? _paymentIdToConfirm;
  OrderResponse? _lastOrderResponse;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserInfo();
    _fetchUserInfoFromApi();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wasHandled = prefs.getBool('uriHandled') ?? false;

      if (!wasHandled) {
        final initialUri = await _appLinks.getInitialAppLink();
        debugPrint('[DeepLink] Initial URI: $initialUri');
        if (initialUri != null &&
            initialUri.toString().startsWith('myapp://pay-success')) {
          await prefs.setBool('uriHandled', true); // Lưu cờ đã xử lý
          await _handlePaymentSuccess(initialUri);
        }
      }

      _linkSubscription = _appLinks.uriLinkStream.listen(
        (Uri? uri) {
          debugPrint('[DeepLink] Stream URI: $uri');
          if (uri != null && uri.toString().startsWith('myapp://pay-success')) {
            _handlePaymentSuccess(uri);
          }
        },
        onError: (err) {
          debugPrint('Error handling deep link: $err');
        },
      );
    } catch (e) {
      debugPrint('Error initializing deep links: $e');
    }
  }

  Future<void> _handlePaymentSuccess(Uri uri) async {
    final uriKey = uri.toString();
    if (!mounted || _isHandlingDeepLink || _handledUris.contains(uriKey))
      return;
    _isHandlingDeepLink = true;
    _handledUris.add(uriKey);

    debugPrint('[DeepLink] Handling URI: $uri');
    await Future.delayed(const Duration(milliseconds: 300));
    final status = uri.queryParameters['status'];
    final cancel = uri.queryParameters['cancel'] == 'true';
    final prefs = await SharedPreferences.getInstance();
    final savedPaymentId = prefs.getInt('paymentId');

    await _appLinks.getLatestAppLink(); // Gọi để reset trạng thái
    // Hoặc bạn có thể xoá thủ công mọi `paymentId` nếu cần
    await prefs.remove('paymentId');

    if (status == 'CANCELLED' || cancel) {
      _isHandlingDeepLinkCancel = true;

      if (_lastOrderResponse != null) {
        try {
          await ApiService.updateOrder(
            _lastOrderResponse!.orderId,
            _lastOrderResponse!.totalPrice.toDouble(),
            _lastOrderResponse!.orderAddress,
            _lastOrderResponse!.field,
            "Cancelled",
          );
          debugPrint(
              '[Order Update] Successfully updated order ${_lastOrderResponse!.orderId} to Cancelled');
        } catch (e) {
          debugPrint('[Order Update] Failed to update order: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Cannot update the order status.'),
              backgroundColor: const Color(0xFFEF5350),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(10),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        debugPrint('[Order Update] No order response available to update.');
      }

      if (!mounted) return;
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Payment was cancelled.'),
          backgroundColor: const Color(0xFFEF5350),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
        ),
      );

      // ⚠️ Đừng pushNamed lại chính màn hình Checkout vì sẽ gọi lại initState
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        Navigator.popUntil(context, (route) => route.isFirst);
      });

      _isHandlingDeepLink = false;
      return;
    }

    if (savedPaymentId != null && status == 'PAID') {
      final result = await ApiService.confirmPayment(savedPaymentId);
      if (result) {
        debugPrint(
            '[✅ Confirm Payment] Successfully confirmed paymentId: $savedPaymentId');

        if (_lastOrderResponse != null) {
          try {
            await ApiService.updateOrder(
              _lastOrderResponse!.orderId,
              _lastOrderResponse!.totalPrice.toDouble(),
              _lastOrderResponse!.orderAddress,
              _lastOrderResponse!.field,
              "Paid",
            );
            debugPrint(
                '[Order Update] Successfully updated order ${_lastOrderResponse!.orderId} to Paid');
          } catch (e) {
            debugPrint('[Order Update] Failed to update order: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Cannot update the order status.'),
                backgroundColor: const Color(0xFFEF5350),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.all(10),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          debugPrint('[Order Update] No order response available to update.');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Payment confirmed successfully!',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(10),
            duration: const Duration(seconds: 3),
          ),
        );
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          Navigator.popUntil(context, (route) => route.isFirst);
        });
      } else {
        debugPrint(
            '[❌ Confirm Payment] Failed to confirm paymentId: $savedPaymentId');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to confirm payment.',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            backgroundColor: Color(0xFFEF5350),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(10),
            duration: const Duration(seconds: 3),
          ),
        );
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          Navigator.popUntil(context, (route) => route.isFirst);
        });
      }
    }

    _paymentIdToConfirm = null;
    _isHandlingDeepLink = false;
    await prefs.setBool('uriHandled', false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (_lastState == AppLifecycleState.paused &&
        state == AppLifecycleState.resumed) {
      final prefs = await SharedPreferences.getInstance();
      final pendingPaymentId = prefs.getInt('pendingPaymentId');
      if (pendingPaymentId != null) {
        final result = await ApiService.confirmPayment(pendingPaymentId);
        if (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Payment confirmed successfully!',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(10),
              duration: const Duration(seconds: 3),
            ),
          );
          await prefs.remove('pendingPaymentId');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Failed to confirm payment.',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              backgroundColor: const Color(0xFFEF5350),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(10),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        _paymentIdToConfirm = null;
      }
    }
    _lastState = state;
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('fullName') ?? '';
      _addressController.text = prefs.getString('address') ?? '';
      _phoneController.text = prefs.getString('phoneNumber') ?? '';
    });
  }

  Future<void> _fetchUserInfoFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (!mounted) return;

    // ✅ Trường hợp: nếu token null → thử lại sau một chút
    if (token == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      token = prefs.getString('authToken');
    }

    // ✅ Nếu token vẫn null → kiểm tra xem có đang quay lại từ thanh toán hay không
    if (token == null && !_isHandlingDeepLinkCancel) {
      final deepLinkUri = await AppLinks().getInitialAppLink();
      final isComingFromPayment = deepLinkUri != null &&
          deepLinkUri.toString().startsWith('myapp://pay-success') &&
          deepLinkUri.queryParameters['status'] == 'PAID';

      if (!isComingFromPayment) {
        debugPrint(
            '[Auth] Token is null and not from payment. Redirecting to Login.');
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      } else {
        debugPrint('[Auth] Token is null but from payment. SKIPPING redirect.');
      }
    }

    if (token == null) {
      debugPrint('[Auth] Token still null. Skipping user info fetch.');
      return;
    }

    // ✅ Thực hiện gọi API lấy user info
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getUserInfo}'),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint(
        '[UserInfo] API response: ${response.statusCode} ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['isSuccess']) {
        final user = data['data'];
        await prefs.setInt('userId', user['userId']);
        await prefs.setString('fullName', user['fullName']);
        await prefs.setString('address', user['address']);
        await prefs.setString('phoneNumber', user['phoneNumber']);
        _loadUserInfo();
      } else {
        debugPrint('[UserInfo] Failed: ${data['message']}');
      }
    } else if (response.statusCode == 401) {
      debugPrint('[UserInfo] Unauthorized. Token invalid or expired.');
    } else {
      debugPrint('[UserInfo] Error: ${response.statusCode}');
    }
  }

  Future<void> _placeOrder() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final token = prefs.getString('authToken');

    if (cartProvider.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Your cart is empty!',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          backgroundColor: const Color(0xFFEF5350),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (userId == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please log in before placing an order!',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          backgroundColor: const Color(0xFFEF5350),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please fill in all fields!',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          backgroundColor: const Color(0xFFEF5350),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final orderRequest = OrderRequest(
      userId: userId,
      totalPrice: cartProvider.getTotalPrice().toInt(),
      orderAddress: _addressController.text,
      field: "string",
      status: "Pending",
    );

    final orderResponse = await ApiService.createOrder(orderRequest);

    if (orderResponse != null) {
      _lastOrderResponse = orderResponse;
      final orderDetails = cartProvider.cart
          .map((item) => OrderDetailRequest(
                orderId: orderResponse.orderId,
                productId: int.parse(item.productId),
                quantity: item.quantity,
                priceItem: item.price.toInt(),
              ))
          .toList();

      final allSuccess = await ApiService.createOrderDetails(orderDetails);

      if (!allSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to create order details!',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            backgroundColor: const Color(0xFFEF5350),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(10),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      final payment = await ApiService.createPayment(orderResponse.orderId);
      if (payment != null) {
        // Lưu paymentId vào SharedPreferences
        await prefs.setInt('paymentId', payment.paymentId);

        final payUrl = await ApiService.getPaymentUrl(
            payment.paymentId, "myapp://pay-success");

        if (payUrl != null) {
          cartProvider.clearCart();
          _paymentIdToConfirm = payment.paymentId;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Order placed successfully!',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(10),
              duration: const Duration(seconds: 3),
            ),
          );
          await launchUrlString(payUrl);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Unable to retrieve payment URL.',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              backgroundColor: const Color(0xFFEF5350),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(10),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to create payment.',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            backgroundColor: const Color(0xFFEF5350),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(10),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to create order.',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          backgroundColor: const Color(0xFFEF5350),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(
              showBackButton: true,
              title: "Checkout",
            ),
            Expanded(
              child: cartProvider.cart.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Your cart is empty',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, AppRoutes.laptopShop),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1976D2),
                                    Color(0xFF42A5F5),
                                  ],
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
                              child: const Text(
                                'Shop Now',
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
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
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
                                  'Cart Summary',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...cartProvider.cart.map(
                                  (item) => TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 10.0, end: 0.0),
                                    duration: const Duration(milliseconds: 300),
                                    builder: (context, double offset, child) {
                                      return Transform.translate(
                                        offset: Offset(0, offset),
                                        child: Opacity(
                                          opacity: offset == 0 ? 1.0 : 0.7,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              item.imageUrl,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Container(
                                                  width: 60,
                                                  height: 60,
                                                  color: Colors.grey[200],
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Color(0xFF1976D2),
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                width: 60,
                                                height: 60,
                                                color: Colors.grey[200],
                                                child: const Center(
                                                  child: Text(
                                                    'No Image',
                                                    style: TextStyle(
                                                      color: Color(0xFF6B7280),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF1A1A1A),
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${item.quantity} x ${currencyFormat.format(item.price)}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            currencyFormat.format(
                                                item.quantity * item.price),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1976D2),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
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
                                  'Shipping Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  "Full Name",
                                  _nameController,
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  "Address",
                                  _addressController,
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  "Phone Number",
                                  _phoneController,
                                  keyboardType: TextInputType.phone,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            _buildBottomBar(cartProvider, currencyFormat),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF42A5F5),
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildBottomBar(CartProvider cartProvider, NumberFormat format) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total: ${format.format(cartProvider.getTotalPrice())}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _placeOrder,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1976D2),
                    Color(0xFF42A5F5),
                  ],
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
              alignment: Alignment.center,
              child: const Text(
                'Place Order',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
