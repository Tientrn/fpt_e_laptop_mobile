import 'package:flutter/material.dart';
import '../reuse/cards/card_borrow.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../models/item_model.dart';

class ListLaptopBorrow extends StatefulWidget {
  const ListLaptopBorrow({super.key});

  @override
  State<ListLaptopBorrow> createState() => _ListLaptopBorrowState();
}

class _ListLaptopBorrowState extends State<ListLaptopBorrow> {
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  Future<List<ItemModel>>? _futureLaptops;

  @override
  void initState() {
    super.initState();
    _fetchLaptops();
  }

  void _fetchLaptops() {
    setState(() {
      _futureLaptops = _apiService.fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available for Borrowing',
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
            height: 400,
            child: FutureBuilder<List<ItemModel>>(
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
                          onTap: _fetchLaptops,
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
                      "No laptops available to borrow.",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                List<ItemModel> laptops = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  itemCount: laptops.length,
                  itemBuilder: (context, index) {
                    final laptop = laptops[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: screenWidth * 0.66,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(begin: 20.0, end: 0.0),
                            duration: const Duration(milliseconds: 300),
                            builder: (context, double offset, child) {
                              return Transform.translate(
                                offset: Offset(offset, 0),
                                child: child,
                              );
                            },
                            child: CardBorrow(
                              product: {
                                'id': laptop.itemId.toString(),
                                'name': laptop.itemName,
                                'shortDescription':
                                    "CPU: ${laptop.cpu}, RAM: ${laptop.ram}, ${laptop.storage}",
                                'image': laptop.itemImage ??
                                    'https://via.placeholder.com/300',
                                'status': laptop.status,
                                'processor': laptop.cpu,
                                'ram': laptop.ram,
                                'storage': laptop.storage,
                                'screenSize': "${laptop.screenSize} inch",
                                'category': laptop.conditionItem,
                              },
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.laptopBorrowDetail,
                                  arguments: laptop.toJson(),
                                );
                              },
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
            child: GestureDetector(
              onTap: () async {
                if (_futureLaptops != null) {
                  List<ItemModel> laptops = await _futureLaptops!;
                  Navigator.pushNamed(
                    context,
                    AppRoutes.laptopborrow,
                    arguments: laptops,
                  );
                }
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
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  'See All Borrowing Options',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
