import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/cart_item.dart';
import '../../../providers/cart_provider.dart';

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(String) onNavigateToDetail;
  final Function(String) onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onNavigateToDetail,
    required this.onAddToCart,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

String formatCurrency(dynamic price) {
  final formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 0,
  );
  return formatter.format(price ?? 0);
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
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
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () {
            final productId = widget.product['productId'];
            if (productId != null) {
              widget.onNavigateToDetail(productId.toString());
            } else {
              debugPrint("Error: productId is missing!");
            }
          },
          child: Container(
            width: 260,
            // Removed fixed height to allow dynamic sizing
            constraints: const BoxConstraints(
              minHeight: 280,
              maxHeight: 320,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isHovered
                    ? const Color(0xFF42A5F5).withOpacity(0.3)
                    : const Color(0xFFE0E0E0).withOpacity(0.5),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_isHovered ? 0.1 : 0.08),
                  blurRadius: _isHovered ? 10 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child: Image.network(
                      widget.product['image'] ?? '',
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: double.infinity,
                          height: 140,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF1976D2),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 140,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Text(
                            'No Image',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(10), // Reduced padding slightly
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product['name'] ?? 'No name',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6), // Reduced spacing
                          Text(
                            widget.product['description'] ?? 'No description',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formatCurrency(widget.product['price']),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildInfoRow(
                            Icons.laptop,
                            '${widget.product['screenSize'] ?? 'N/A'} inch',
                          ),
                          _buildInfoRow(
                            Icons.devices,
                            widget.product['categoryname'] ?? 'No category',
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.centerRight,
                            child: MouseRegion(
                              onEnter: (_) => setState(() => _isHovered = true),
                              onExit: (_) => setState(() => _isHovered = false),
                              child: GestureDetector(
                                onTap: () {
                                  final cartProvider =
                                      Provider.of<CartProvider>(context,
                                          listen: false);
                                  final productId =
                                      widget.product['productId'].toString();
                                  final stock = widget.product['stock'] ?? 0;

                                  final currentQuantity = cartProvider.cart
                                      .where(
                                          (item) => item.productId == productId)
                                      .map((item) => item.quantity)
                                      .fold(
                                          0, (prev, element) => prev + element);

                                  if (currentQuantity + 1 > stock) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Cannot add more. Stock limit reached.',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        margin: const EdgeInsets.all(10),
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                    return;
                                  }

                                  final cartItem = CartItem(
                                    productId: productId,
                                    name: widget.product['name'] ??
                                        'Unknown Product',
                                    price: (widget.product['price'] ?? 0)
                                        .toDouble(),
                                    quantity: 1,
                                    imageUrl: widget.product['image'] ?? '',
                                    stock: stock,
                                  );
                                  cartProvider.addToCart(cartItem);
                                  widget.onAddToCart(productId);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${widget.product['name']} added to cart!',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFF2E7D32),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      margin: const EdgeInsets.all(10),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 36,
                                  width: 36,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF1976D2),
                                        Color(0xFF42A5F5),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(
                                            _isHovered ? 0.25 : 0.2),
                                        blurRadius: _isHovered ? 8 : 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: AnimatedRotation(
                                    turns: _isHovered ? 0.05 : 0.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: const Icon(
                                      Icons.add_shopping_cart,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6), // Reduced padding
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFF1976D2),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
