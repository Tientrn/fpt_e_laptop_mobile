import 'package:flutter/material.dart';

class LaptopActions extends StatelessWidget {
  final VoidCallback onAddToCart;

  const LaptopActions({
    super.key,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              debugPrint("🛒 Button Add To Cart được nhấn!");
              onAddToCart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent, // Màu nền trong suốt
              foregroundColor: const Color(0xFF0288D1), // Màu chữ và icon
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Bo góc nhẹ
                side: const BorderSide(
                    color: Color(0xFF0288D1), width: 1), // Viền nhẹ
              ),
              elevation: 0, // Không có bóng
            ),
            icon: const Icon(
              Icons.add_shopping_cart,
              color: Color(0xFF0288D1), // Màu icon đồng bộ
            ),
            label: const Text(
              "Thêm vào giỏ hàng",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500), // Font nhẹ nhàng
            ),
          ),
        ),
      ],
    );
  }
}
