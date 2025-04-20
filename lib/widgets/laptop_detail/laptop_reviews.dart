import 'package:flutter/material.dart';

class LaptopReviews extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;

  const LaptopReviews({Key? key, required this.reviews}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đánh giá',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50), // Màu sắc tối giản cho tiêu đề
          ),
        ),
        const SizedBox(height: 12),
        // Nếu không có đánh giá, hiển thị thông báo
        if (reviews.isEmpty)
          const Text(
            'Chưa có đánh giá nào.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        // Nếu có đánh giá, hiển thị danh sách đánh giá
        ...reviews.map((review) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(0.05), // Giảm độ mờ của bóng đổ
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên người đánh giá và đánh giá sao
                Row(
                  children: [
                    Text(
                      review['user'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF34495E), // Màu sắc tối giản
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(
                        review['rating'],
                        (index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Bình luận đánh giá
                Text(
                  review['comment'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5, // Tăng khoảng cách dòng để dễ đọc hơn
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
