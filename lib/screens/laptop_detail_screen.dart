import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../models/feedback_model.dart';
import '../models/product_model.dart';
import '../models/shop_model.dart';
import '../providers/cart_provider.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../widgets/laptop_detail/laptop_images.dart';
import '../widgets/laptop_detail/laptop_reviews.dart';
import '../widgets/laptop_detail/laptop_actions.dart';
import '../widgets/reuse/cards/card.dart';
import '../widgets/homepage/custom_header.dart';
import '../widgets/homepage/custom_footer.dart';

class LaptopDetailScreen extends StatefulWidget {
  final Map<String, dynamic> laptop;

  const LaptopDetailScreen({super.key, required this.laptop});

  @override
  State<LaptopDetailScreen> createState() => _LaptopDetailScreenState();
}

class _LaptopDetailScreenState extends State<LaptopDetailScreen> {
  late Future<List<String>> _imagesFuture;
  late Future<List<FeedbackModel>> _feedbacksFuture;
  late Future<List<Product>> _relatedProductsFuture;
  late Future<Product?> _productDetailsFuture;
  final ApiService apiService = ApiService();
  bool _showAllFeedbacks = false;
  Product? _productDetails;
  Shop? _shop;

  @override
  void initState() {
    super.initState();
    _imagesFuture = ApiService.fetchProductImages(widget.laptop['productId']);
    _feedbacksFuture = ApiService.fetchProductFeedbacks();
    _relatedProductsFuture = _fetchRelatedProducts();
    _fetchProductDetails();
    _fetchShop();
  }

  Future<void> _fetchShop() async {
    try {
      final shopId = widget.laptop['shopId'];
      print('shopId: $shopId');
      if (shopId != null) {
        final shop = await ApiService.fetchShopById(shopId);
        if (mounted && shop != null) {
          setState(() {
            _shop = shop;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching shop info: $e");
    }
  }

  Future<void> _fetchProductDetails() async {
    try {
      _productDetailsFuture =
          ApiService.fetchProduct(widget.laptop['productId']);
      final product = await _productDetailsFuture;
      if (mounted) {
        setState(() {
          _productDetails = product;
        });
      }
    } catch (e) {
      debugPrint("Error fetching product details: $e");
    }
  }

  Future<List<Product>> _fetchRelatedProducts() async {
    try {
      List<Product> allProducts = await apiService.getProducts();
      return allProducts
          .where((product) =>
              product.categoryName == widget.laptop['categoryName'] &&
              product.productId != widget.laptop['productId'])
          .toList();
    } catch (e) {
      debugPrint("Error loading related products: $e");
      return [];
    }
  }

  String formatCurrency(double price) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  void _addToCart(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    final stock = _productDetails?.quantity ?? widget.laptop['stock'] ?? 0;
    final currentQuantity = cartProvider.cart
        .where((item) =>
            item.productId ==
            (_productDetails?.productId ?? widget.laptop['productId'])
                .toString())
        .map((item) => item.quantity)
        .fold(0, (prev, element) => prev + element);

    print("Stock value: $stock");
    print("Current Quantity in Cart: $currentQuantity");

    if (stock == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Out of stock!',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          backgroundColor: Colors.red,
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

    if (currentQuantity >= stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Cannot add more. Stock limit reached.',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          backgroundColor: Colors.red,
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

    // Tiến hành thêm vào giỏ hàng
    final newItem = CartItem(
      productId:
          (_productDetails?.productId ?? widget.laptop['productId']).toString(),
      name: _productDetails?.productName ?? widget.laptop['productName'],
      price: _productDetails?.price.toDouble() ??
          widget.laptop['price']?.toDouble() ??
          0.0,
      quantity: 1,
      imageUrl: _productDetails?.imageProduct ?? widget.laptop['imageProduct'],
      stock: stock, // Lưu stock vào CartItem
    );

    await cartProvider.addToCart(newItem);

    print(
        "Cart items after adding: ${cartProvider.cart.map((e) => e.toJson()).toList()}");

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Added to cart!',
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              showBackButton: true,
              title: "${widget.laptop['productName']}",
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<List<String>>(
                      future: _imagesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 300,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return const SizedBox(
                            height: 300,
                            child: Center(
                              child: Text(
                                "Failed to load images.",
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        } else {
                          List<String> imageUrls = [];
                          if (widget.laptop['imageProduct'] != null &&
                              widget.laptop['imageProduct']
                                  .toString()
                                  .isNotEmpty) {
                            imageUrls.add(widget.laptop['imageProduct']);
                          }
                          if (snapshot.hasData) {
                            imageUrls.addAll(snapshot.data!);
                          }
                          return SizedBox(
                            height: 350,
                            child: LaptopImages(imageUrls: imageUrls),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 10.0, end: 0.0),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, double offset, child) {
                        return Transform.translate(
                          offset: Offset(0, offset),
                          child: child,
                        );
                      },
                      child: Container(
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
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.laptop['productName'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            if (_shop != null && _shop!.shopName.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.store_mall_directory,
                                      color: Color(0xFF6B7280),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _shop!.shopName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1976D2)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF1976D2)
                                          .withOpacity(0.3),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    "${widget.laptop['categoryName']}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1976D2),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (_productDetails?.productionYear != null &&
                                    _productDetails!.productionYear > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4CAF50)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFF4CAF50)
                                            .withOpacity(0.3),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      "${_productDetails!.productionYear}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF4CAF50),
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (widget.laptop['stock'] != null &&
                                            widget.laptop['stock'] > 0)
                                        ? const Color(0xFFFF9800)
                                            .withOpacity(0.1)
                                        : const Color(0xFFE53935)
                                            .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: (widget.laptop['stock'] != null &&
                                              widget.laptop['stock'] > 0)
                                          ? const Color(0xFFFF9800)
                                              .withOpacity(0.3)
                                          : const Color(0xFFE53935)
                                              .withOpacity(0.3),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    (widget.laptop['stock'] != null &&
                                            widget.laptop['stock'] > 0)
                                        ? "Stock: ${widget.laptop['stock']}"
                                        : "Out of Stock",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: (widget.laptop['stock'] != null &&
                                              widget.laptop['stock'] > 0)
                                          ? const Color(0xFFFF9800)
                                          : const Color(0xFFE53935),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1976D2)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    formatCurrency(
                                        widget.laptop['price']?.toDouble() ??
                                            0.0),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1976D2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Additional product details section
                    FutureBuilder<Product?>(
                      future: _productDetailsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF1976D2),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              "Failed to load product details.",
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data == null) {
                          return const SizedBox.shrink();
                        } else {
                          final product = snapshot.data!;
                          return TweenAnimationBuilder(
                            tween: Tween<double>(begin: 10.0, end: 0.0),
                            duration: const Duration(milliseconds: 300),
                            builder: (context, double offset, child) {
                              return Transform.translate(
                                offset: Offset(0, offset),
                                child: child,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      const Color(0xFFE0E0E0).withOpacity(0.5),
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
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Detailed Specifications',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1976D2),
                                      shadows: [
                                        Shadow(
                                          color: Colors.black12,
                                          blurRadius: 2,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Performance specifications
                                  if (product.cpu.isNotEmpty ||
                                      product.ram.isNotEmpty ||
                                      product.storage.isNotEmpty)
                                    _buildSpecCategory('Performance', [
                                      if (product.cpu.isNotEmpty)
                                        {'CPU': product.cpu},
                                      if (product.ram.isNotEmpty)
                                        {'RAM': product.ram},
                                      if (product.storage.isNotEmpty)
                                        {'Storage': product.storage},
                                      if (product.graphicsCard.isNotEmpty)
                                        {'Graphics': product.graphicsCard},
                                    ]),

                                  // Display specifications
                                  if (product.screenSize.isNotEmpty)
                                    _buildSpecCategory('Display', [
                                      {
                                        'Screen Size':
                                            '${product.screenSize} inch'
                                      },
                                    ]),

                                  // Design specifications
                                  if (product.model.isNotEmpty ||
                                      product.color.isNotEmpty)
                                    _buildSpecCategory('Design', [
                                      if (product.model.isNotEmpty)
                                        {'Model': product.model},
                                      if (product.color.isNotEmpty)
                                        {'Color': product.color},
                                      if (product.productionYear > 0)
                                        {
                                          'Year':
                                              product.productionYear.toString()
                                        },
                                    ]),

                                  // Connectivity
                                  if (product.ports.isNotEmpty)
                                    _buildSpecCategory('Connectivity', [
                                      {'Ports': product.ports},
                                    ]),

                                  // Battery
                                  if (product.battery.isNotEmpty)
                                    _buildSpecCategory('Battery', [
                                      {'Battery': product.battery},
                                    ]),

                                  // Operating System
                                  if (product.operatingSystem.isNotEmpty)
                                    _buildSpecCategory('Software', [
                                      {
                                        'Operating System':
                                            product.operatingSystem
                                      },
                                    ]),

                                  if (product.description.isNotEmpty) ...[
                                    const SizedBox(height: 20),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8F9FA),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFE0E0E0),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Description',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1976D2),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            product.description,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF6B7280),
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        return Center(
                          child: InkWell(
                            onTap: () => _addToCart(context),
                            splashColor: Colors.white24,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF1976D2),
                                    Color(0xFF42A5F5),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1976D2)
                                        .withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.shopping_cart_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Add to Cart',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<FeedbackModel>>(
                      future: _feedbacksFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF1976D2),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              "Failed to load reviews.",
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        } else {
                          final feedbacks = snapshot.data ?? [];
                          final productFeedbacks = feedbacks
                              .where((feedback) =>
                                  feedback.productId ==
                                  widget.laptop['productId'])
                              .toList();

                          double averageRating = 0.0;
                          if (productFeedbacks.isNotEmpty) {
                            averageRating = productFeedbacks
                                    .map((f) => f.rating)
                                    .reduce((a, b) => a + b) /
                                productFeedbacks.length;
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF1976D2).withOpacity(0.05),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_border_rounded,
                                      color: Color(0xFF1976D2),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Product Reviews',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1976D2),
                                        shadows: [
                                          Shadow(
                                            color: Colors.black12,
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${productFeedbacks.length} reviews',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Text(
                                    'Average Rating: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  Text(
                                    averageRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFB300),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.star,
                                    color: Color(0xFFFFB300),
                                    size: 18,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (productFeedbacks.isEmpty)
                                const Text(
                                  'No reviews yet.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ...(_showAllFeedbacks
                                      ? productFeedbacks
                                      : productFeedbacks.take(3))
                                  .map((feedback) {
                                return TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 10.0, end: 0.0),
                                  duration: const Duration(milliseconds: 300),
                                  builder: (context, double offset, child) {
                                    return Transform.translate(
                                      offset: Offset(0, offset),
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              height: 36,
                                              width: 36,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1976D2)
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  feedback.isAnonymous
                                                      ? Icons.person
                                                      : Icons.account_circle,
                                                  color:
                                                      const Color(0xFF1976D2),
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  feedback.isAnonymous
                                                      ? 'Anonymous User'
                                                      : 'User',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    color: Color(0xFF1976D2),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 6,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                                0xFFFFB300)
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            feedback.rating
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color(
                                                                  0xFFFFB300),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 2),
                                                          const Icon(
                                                            Icons.star,
                                                            color: Color(
                                                                0xFFFFB300),
                                                            size: 12,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            _buildRatingStars(feedback.rating),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          feedback.comments,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF6B7280),
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                              if (productFeedbacks.length > 3)
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _showAllFeedbacks = !_showAllFeedbacks;
                                      });
                                    },
                                    child: Text(
                                      _showAllFeedbacks
                                          ? "Hide reviews"
                                          : "Show all reviews",
                                      style: const TextStyle(
                                        color: Color(0xFF1976D2),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<Product>>(
                      future: _relatedProductsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF1976D2),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              "Failed to load related products.",
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        } else {
                          List<Product> relatedProducts = snapshot.data ?? [];
                          if (relatedProducts.isEmpty) {
                            return const Center(
                              child: Text(
                                "No related products.",
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF1976D2).withOpacity(0.05),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.recommend,
                                      color: Color(0xFF1976D2),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Related Products',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1976D2),
                                        shadows: [
                                          Shadow(
                                            color: Colors.black12,
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${relatedProducts.length} items',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 420,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: relatedProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = relatedProducts[index];
                                    return TweenAnimationBuilder(
                                      tween:
                                          Tween<double>(begin: 20.0, end: 0.0),
                                      duration:
                                          const Duration(milliseconds: 300),
                                      builder: (context, double offset, child) {
                                        return Transform.translate(
                                          offset: Offset(offset, 0),
                                          child: child,
                                        );
                                      },
                                      child: Container(
                                        width: 200,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFFE0E0E0)
                                                .withOpacity(0.5),
                                            width: 0.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.08),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ProductCard(
                                          product: {
                                            'productId': product.productId,
                                            'name': product.productName,
                                            'description':
                                                "RAM ${product.ram}, CPU: ${product.cpu}, ${product.storage}",
                                            'image': product.imageProduct,
                                            'price': product.price,
                                            'screenSize': product.screenSize,
                                            'categoryname':
                                                product.categoryName,
                                            'stock': product.quantity,
                                          },
                                          onNavigateToDetail: (id) {
                                            Navigator.pushNamed(
                                              context,
                                              AppRoutes.laptopDetail,
                                              arguments: {
                                                'productId': product.productId,
                                                'productName':
                                                    product.productName,
                                                'price': product.price,
                                                'imageProduct':
                                                    product.imageProduct,
                                                'categoryName':
                                                    product.categoryName,
                                                'ram': product.ram,
                                                'cpu': product.cpu,
                                                'storage': product.storage,
                                                'screenSize':
                                                    product.screenSize,
                                                'stock': product.quantity,
                                                'model': product.model,
                                                'color': product.color,
                                                'graphicsCard':
                                                    product.graphicsCard,
                                                'battery': product.battery,
                                                'ports': product.ports,
                                                'productionYear':
                                                    product.productionYear,
                                                'operatingSystem':
                                                    product.operatingSystem,
                                                'description':
                                                    product.description,
                                                'shopName': product.shopName,
                                                'shopId': product.shopId,
                                              },
                                            );
                                          },
                                          onAddToCart: (id) {
                                            final cartProvider =
                                                Provider.of<CartProvider>(
                                                    context,
                                                    listen: false);
                                            final newItem = CartItem(
                                              productId:
                                                  product.productId.toString(),
                                              name: product.productName,
                                              price: product.price.toDouble(),
                                              quantity: 1,
                                              imageUrl: product.imageProduct,
                                              stock: product.quantity,
                                            );
                                            cartProvider.addToCart(newItem);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  'Added to cart!',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                backgroundColor:
                                                    const Color(0xFF2E7D32),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                margin:
                                                    const EdgeInsets.all(10),
                                                duration:
                                                    const Duration(seconds: 3),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                      },
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

  Widget _buildSpecRow(String label, String value) {
    if (value.isEmpty || value == '0') return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecCategory(String category, List<Map<String, String>> specs) {
    if (specs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2).withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getCategoryIcon(category),
                size: 16,
                color: const Color(0xFF1976D2),
              ),
              const SizedBox(width: 6),
              Text(
                category,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...specs.map((spec) {
          final entry = spec.entries.first;
          return _buildSpecRow(entry.key, entry.value);
        }).toList(),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'performance':
        return Icons.speed;
      case 'display':
        return Icons.monitor;
      case 'design':
        return Icons.design_services;
      case 'connectivity':
        return Icons.usb;
      case 'battery':
        return Icons.battery_full;
      case 'software':
        return Icons.system_update;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildRatingStars(int rating) {
    int fullStars = rating;
    int emptyStars = 5 - fullStars;

    return Row(
      children: [
        ...List.generate(fullStars,
            (_) => const Icon(Icons.star, color: Color(0xFFFFB300), size: 18)),
        ...List.generate(
            emptyStars,
            (_) => const Icon(Icons.star_border,
                color: Color(0xFFFFB300), size: 18)),
      ],
    );
  }
}
