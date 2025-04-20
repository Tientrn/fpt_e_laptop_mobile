import 'package:flutter/material.dart';
import '../reuse/cards/card.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../models/product_model.dart';

class ListLaptop extends StatefulWidget {
  const ListLaptop({super.key});

  @override
  State<ListLaptop> createState() => _ListLaptopState();
}

class _ListLaptopState extends State<ListLaptop> {
  final ScrollController _scrollController = ScrollController();
  late Future<List<Product>> _futureLaptops = _fetchLaptops();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _futureLaptops = _fetchLaptops();
  }

  Future<List<Product>> _fetchLaptops() async {
    try {
      List<Product> laptops = await ApiService().getProducts();
      setState(() => isLoading = false);
      return laptops;
    } catch (e) {
      setState(() => isLoading = false);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
      color: const Color(0xFFF5F6FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Laptops',
            style: TextStyle(
              fontSize: 20,
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
            height: 450,
            child: FutureBuilder<List<Product>>(
              future: _futureLaptops,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1976D2),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Failed to load laptops.",
                          style: TextStyle(
                            color: Color(0xFFD32F2F),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _futureLaptops = _fetchLaptops();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF1976D2),
                                  Color(0xFF42A5F5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              "Try Again",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No laptops available.",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                final laptops = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  itemCount: laptops.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: TweenAnimationBuilder(
                        tween: Tween<double>(begin: 20.0, end: 0.0),
                        duration: const Duration(milliseconds: 300),
                        builder: (context, double offset, child) {
                          return Transform.translate(
                            offset: Offset(offset, 0),
                            child: child,
                          );
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.laptopDetail,
                                arguments: laptops[index],
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
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: ProductCard(
                                  product: {
                                    'productId': laptops[index].productId,
                                    'name': laptops[index].productName,
                                    'description':
                                        "RAM ${laptops[index].ram}, CPU: ${laptops[index].cpu}, ${laptops[index].storage}",
                                    'image': laptops[index].imageProduct,
                                    'price': laptops[index].price,
                                    'screenSize': laptops[index].screenSize,
                                    'categoryname': laptops[index].categoryName,
                                    'stock': laptops[index].quantity
                                  },
                                  onNavigateToDetail: (id) {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.laptopDetail,
                                      arguments: laptops[index].toJson(),
                                    );
                                  },
                                  onAddToCart: (id) {
                                    // Logic để thêm sản phẩm vào giỏ hàng
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.laptopShop,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'See All Laptops',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
