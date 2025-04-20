import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_fpt_e_laptop/screens/laptop_borrow_detail_screen.dart';
import 'package:mobile_fpt_e_laptop/screens/order_history_screen.dart';
import 'package:mobile_fpt_e_laptop/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'models/cart_item.dart';
import 'routes/app_routes.dart';
import 'providers/cart_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/laptop_shop_screen.dart';
import 'screens/laptop_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/laptop_borrow_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/borrow_requests_screen.dart';
import 'screens/borrow_history_detail.dart';
import 'screens/borrow_contract_screen.dart';
import 'screens/contact_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CartItemAdapter());

  await Hive.openBox('appBox');

  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Laptop Sharing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.home:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case AppRoutes.register:
            return MaterialPageRoute(
                builder: (_) => const RegisterStudentScreen());
          case AppRoutes.laptopShop:
            return MaterialPageRoute(builder: (_) => const LaptopShopScreen());
          case AppRoutes.laptopBorrowRequest:
            return MaterialPageRoute(
                builder: (_) => const BorrowRequestsScreen());
          case AppRoutes.laptopDetail:
            final args = settings.arguments as Map<String, dynamic>?;

            if (args == null) {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text("Không có dữ liệu sản phẩm")),
                ),
              );
            }

            return MaterialPageRoute(
              builder: (_) =>
                  LaptopDetailScreen(laptop: args), // Truyền dữ liệu đúng
            );
          case AppRoutes.cart: // Thêm case cho giỏ hàng
            return MaterialPageRoute(
                builder: (_) =>
                    const CartScreen()); // Điều hướng đến CartScreen
          case AppRoutes.checkout:
            return MaterialPageRoute(builder: (_) => const CheckoutScreen());
          case AppRoutes.orderhistory:
            return MaterialPageRoute(
                builder: (_) => const OrderHistoryScreen());
          case AppRoutes.borrowContract:
            return MaterialPageRoute(builder: (_) => BorrowContractScreen());
          case AppRoutes.laptopborrow:
            return MaterialPageRoute(
                builder: (_) => const LaptopBorrowScreen());
          case AppRoutes.contact:
            return MaterialPageRoute(builder: (_) => const ContactScreen());
          case AppRoutes.orderDetail:
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null &&
                args.containsKey('borrowHistoryId') &&
                args.containsKey('requestId')) {
              final int borrowHistoryId = args['borrowHistoryId'];
              final int requestId = args['requestId'];
              return MaterialPageRoute(
                builder: (_) => BorrowHistoryDetailScreen(
                    borrowHistoryId: borrowHistoryId, requestId: requestId),
              );
            }
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(
                  child: Text('Không có thông tin chi tiết đơn hàng'),
                ),
              ),
            );
          case AppRoutes.laptopBorrowDetail:
            final args = settings.arguments;

            // ✅ Kiểm tra kiểu dữ liệu của args để tránh lỗi
            if (args is Map<String, dynamic>) {
              return MaterialPageRoute(
                builder: (_) => const LaptopBorrowDetailScreen(),
                settings: RouteSettings(arguments: args),
              );
            }

            // 🔥 Trường hợp không có dữ liệu hợp lệ
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(
                  child: Text(
                    "Không có dữ liệu laptop",
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                ),
              ),
            );
          case AppRoutes.profile:
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}
