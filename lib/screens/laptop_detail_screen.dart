import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../models/feedback_model.dart';
import '../models/product_model.dart';
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
  final ApiService apiService = ApiService();
  bool _showAllFeedbacks = false;

  @override
  void initState() {
    super.initState();
    _imagesFuture = ApiService.fetchProductImages(widget.laptop['productId']);
    _feedbacksFuture = ApiService.fetchProductFeedbacks();
    _relatedProductsFuture = _fetchRelatedProducts();
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
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  void _addToCart(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    final stock = widget.laptop['stock'] ?? 0;
    final currentQuantity = cartProvider.cart
        .where(
            (item) => item.productId == widget.laptop['productId'].toString())
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
      productId: widget.laptop['productId'].toString(),
      name: widget.laptop['productName'],
      price: widget.laptop['price']?.toDouble() ?? 0.0,
      quantity: 1,
      imageUrl: widget.laptop['imageProduct'],
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
                            const SizedBox(height: 10),
                            Text(
                              "RAM ${widget.laptop['ram']}, CPU: ${widget.laptop['cpu']}, ${widget.laptop['storage']}, ${widget.laptop['screenSize']} inch",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              formatCurrency(
                                  widget.laptop['price']?.toDouble() ?? 0.0),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        return Center(
                          child: GestureDetector(
                            onTap: () => _addToCart(context),
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
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Add to Cart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
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
                                            const SizedBox(width: 8),
                                            Text(
                                              feedback.rating.toString(),
                                              style: const TextStyle(
                                                fontSize: 14,
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
}
