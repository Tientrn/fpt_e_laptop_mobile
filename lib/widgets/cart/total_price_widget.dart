import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class TotalPriceWidget extends StatelessWidget {
  const TotalPriceWidget({super.key}); // Thêm key nếu cần

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final totalPrice = cartProvider.getTotalPrice();

    return Container(
      color: Colors.teal, // Đặt màu nền cho widget
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Total Price: \$${totalPrice.toStringAsFixed(2)}',
        style: const TextStyle(
          fontSize: 24, // Tăng kích thước chữ
          fontWeight: FontWeight.bold,
          color: Colors.white, // Đặt màu chữ thành trắng
        ),
      ),
    );
  }
}
