import 'package:flutter/material.dart';

class CheckoutButton extends StatelessWidget {
  const CheckoutButton({super.key}); // Thêm key nếu cần

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          // Implement checkout functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Proceeding to Checkout')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal, // Đặt màu nền của nút thành teal
          foregroundColor: Colors.white, // Đặt màu chữ thành trắng
          padding: const EdgeInsets.symmetric(
              vertical: 16.0, horizontal: 32.0), // Tăng padding cho nút
        ),
        child: const Text(
          'Proceed to Checkout',
          style: TextStyle(
            fontSize: 18, // Tăng kích thước chữ
          ),
        ),
      ),
    );
  }
}
