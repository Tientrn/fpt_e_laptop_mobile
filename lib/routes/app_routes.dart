import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/laptop_shop_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/order_history_screen.dart';
import '../screens/laptop_borrow_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/borrow_requests_screen.dart';
import '../screens/borrow_history_detail.dart';
import '../screens/borrow_contract_screen.dart';
import '../screens/contact_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String laptopShop = '/laptopShop';
  static const String laptopDetail = '/laptopDetail';
  static const String cart = '/cart';
  static const String checkout = 'checkout';
  static const String orderhistory = '/orderhistory';
  static const String laptopborrow = '/laptopborrow';
  static const String laptopBorrowDetail = '/laptop-borrow-detail';
  static const String profile = '/profile';
  static const String laptopBorrowRequest = '/laptop-borrow-request';
  static const String orderDetail = '/order-detail';
  static const String borrowContract = '/borrow-contract';
  static const String contact = '/contact';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterStudentScreen(),
      home: (context) => const HomeScreen(),
      laptopShop: (context) => const LaptopShopScreen(),
      cart: (context) => const CartScreen(),
      checkout: (context) => const CheckoutScreen(),
      orderhistory: (context) => const OrderHistoryScreen(),
      laptopborrow: (context) => const LaptopBorrowScreen(),
      laptopBorrowRequest: (context) => const BorrowRequestsScreen(),
      orderDetail: (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        if (args != null &&
            args.containsKey('borrowHistoryId') &&
            args.containsKey('requestId')) {
          final int borrowHistoryId = args['borrowHistoryId'];
          final int requestId = args['requestId'];
          return BorrowHistoryDetailScreen(
              borrowHistoryId: borrowHistoryId,
              requestId: requestId); // Truyền requestId vào đây
        }
        return const Scaffold(
            body: Center(child: Text("Không có thông tin chi tiết")));
      },
      profile: (context) => const ProfileScreen(),
      borrowContract: (context) => BorrowContractScreen(),
      contact: (context) => const ContactScreen(),
    };
  }
}
