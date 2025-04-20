import 'package:flutter/material.dart';

class LaptopInfo extends StatelessWidget {
  final String name;
  final String description;
  final double price;
  final String? specifications; // Thêm thông số kỹ thuật

  const LaptopInfo({
    super.key,
    required this.name,
    required this.description,
    required this.price,
    this.specifications, // Thêm thông số kỹ thuật vào constructor
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề phần thông tin sản phẩm
        const Text(
          'Thông tin sản phẩm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50), // Màu sắc dịu nhẹ cho tiêu đề
          ),
        ),
        const SizedBox(height: 12),
        // Tên sản phẩm
        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF34495E), // Màu sắc tối giản
          ),
        ),
        const SizedBox(height: 8),
        // Mô tả sản phẩm
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        // Thông số kỹ thuật (nếu có)
        if (specifications != null) ...[
          const Text(
            'Thông số kỹ thuật:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF7F8C8D), // Màu sắc nhẹ nhàng
            ),
          ),
          const SizedBox(height: 4),
          Text(
            specifications!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
        ],
        // Giá sản phẩm
        Text(
          "${price.toStringAsFixed(0)} VND",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF27AE60), // Màu sắc cho giá cả
          ),
        ),
      ],
    );
  }
}
