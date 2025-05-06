import 'package:flutter/material.dart';
import 'package:mobile_fpt_e_laptop/services/api_service.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../routes/app_routes.dart';
import '../widgets/reuse/cards/card.dart';
import '../widgets/homepage/custom_header.dart';
import '../widgets/homepage/custom_footer.dart';

class LaptopShopScreen extends StatefulWidget {
  const LaptopShopScreen({super.key});

  @override
  _LaptopShopScreenState createState() => _LaptopShopScreenState();
}

class _LaptopShopScreenState extends State<LaptopShopScreen> {
  late Future<List<Product>> _laptopsFuture;
  late Future<List<Category>> _categoriesFuture;
  List<Product> allLaptops = [];
  List<Product> filteredLaptops = [];
  List<String> categories = ["All"];
  String selectedCategory = "All";
  String _sortOption = "Default";
  String _selectedRam = "All";
  String _selectedCpu = "All";
  String _selectedStorage = "All";
  String _selectedScreen = "All";
  bool _showSearch = false;
  bool _showFilters = false;
  bool _showSort = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      _categoriesFuture = ApiService().fetchCategories();
      _laptopsFuture = ApiService().getProducts();

      List<Category> fetchedCategories = await _categoriesFuture;
      List<Product> fetchedLaptops = await _laptopsFuture;

      if (mounted) {
        setState(() {
          categories.addAll(fetchedCategories.map((c) => c.categoryName));
          allLaptops = fetchedLaptops;
          _filterLaptops();
        });
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
  }

  void _filterLaptops() {
    setState(() {
      filteredLaptops = allLaptops.where((laptop) {
        final searchLower = _searchController.text.toLowerCase();
        final nameLower = laptop.productName.toLowerCase();
        final matchesSearch = nameLower.contains(searchLower);
        final matchesCategory = selectedCategory == "All" ||
            laptop.categoryName == selectedCategory;

        final ramValue =
            laptop.ram.toLowerCase().replaceAll(RegExp(r'[^0-9]'), '');
        final selectedRam = _selectedRam.replaceAll(RegExp(r'[^0-9]'), '');
        final matchesRam = _selectedRam == 'All' || ramValue == selectedRam;

        final cpuValue = laptop.cpu.toLowerCase();
        final matchesCpu = _selectedCpu == 'All' ||
            cpuValue.contains(_selectedCpu.toLowerCase());

        final storageRaw = laptop.storage.toLowerCase();
        final storageValue = storageRaw.contains("tb")
            ? "1024"
            : storageRaw.replaceAll(RegExp(r'[^0-9]'), '');
        final selectedStorage =
            _selectedStorage.replaceAll(RegExp(r'[^0-9]'), '');
        final matchesStorage =
            _selectedStorage == 'All' || storageValue == selectedStorage;

        final screenValue = laptop.screenSize.toLowerCase();
        final matchesScreen = _selectedScreen == 'All' ||
            screenValue.contains(_selectedScreen.toLowerCase());

        return matchesSearch &&
            matchesCategory &&
            matchesRam &&
            matchesCpu &&
            matchesStorage &&
            matchesScreen;
      }).toList();

      if (_sortOption == "Price: Low to High") {
        filteredLaptops.sort((a, b) => a.price.compareTo(b.price));
      } else if (_sortOption == "Price: High to Low") {
        filteredLaptops.sort((a, b) => b.price.compareTo(a.price));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(showBackButton: true, title: "Shop Laptops"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildToolButton(
                    icon: _showSearch ? Icons.close : Icons.search,
                    onPressed: () {
                      setState(() {
                        _showSearch = !_showSearch;
                        if (!_showSearch) _searchController.clear();
                        _filterLaptops();
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                  _buildToolButton(
                    icon: _showFilters ? Icons.tune : Icons.tune_outlined,
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                  _buildToolButton(
                    icon: _showSort ? Icons.sort : Icons.sort_outlined,
                    onPressed: () {
                      setState(() {
                        _showSort = !_showSort;
                      });
                    },
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showSearch
                  ? _buildSearchBar()
                  : const SizedBox.shrink(key: ValueKey("no_search")),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showFilters
                  ? _buildFilterOptions()
                  : const SizedBox.shrink(key: ValueKey("no_filters")),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showSort
                  ? _buildSortDropdown()
                  : const SizedBox.shrink(key: ValueKey("no_sort")),
            ),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _laptopsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1976D2),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Failed to load laptops.",
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
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
                  } else {
                    return _buildContent();
                  }
                },
              ),
            ),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFF1976D2),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => _filterLaptops(),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF1976D2),
            ),
            hintText: 'Search for laptops...',
            hintStyle: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF42A5F5),
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCpu,
                  decoration: InputDecoration(
                    labelText: "CPU",
                    labelStyle: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: const Color(0xFFE0E0E0).withOpacity(0.5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: const Color(0xFFE0E0E0).withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF42A5F5),
                        width: 1.5,
                      ),
                    ),
                  ),
                  items: ['All', 'i3', 'i5', 'i7', 'i9', 'm1']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(
                                color: Color(0xFF1976D2),
                                fontSize: 14,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedCpu = value!);
                    _filterLaptops();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedRam,
                  decoration: InputDecoration(
                    labelText: "RAM",
                    labelStyle: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: const Color(0xFFE0E0E0).withOpacity(0.5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: const Color(0xFFE0E0E0).withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF42A5F5),
                        width: 1.5,
                      ),
                    ),
                  ),
                  items: ['All', '4 GB', '8 GB', '16 GB', '32 GB']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(
                                color: Color(0xFF1976D2),
                                fontSize: 14,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedRam = value!);
                    _filterLaptops();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStorage,
                  decoration: InputDecoration(
                    labelText: "Storage",
                    labelStyle: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: const Color(0xFFE0E0E0).withOpacity(0.5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: const Color(0xFFE0E0E0).withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF42A5F5),
                        width: 1.5,
                      ),
                    ),
                  ),
                  items: ['All', '128 GB', '256 GB', '512 GB', '1 TB']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(
                                color: Color(0xFF1976D2),
                                fontSize: 14,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedStorage = value!);
                    _filterLaptops();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedScreen,
                  decoration: InputDecoration(
                    labelText: "Screen Size",
                    labelStyle: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: const Color(0xFFE0E0E0).withOpacity(0.5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: const Color(0xFFE0E0E0).withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF42A5F5),
                        width: 1.5,
                      ),
                    ),
                  ),
                  items: ['All', '13', '14', '15.6', '16']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(
                                color: Color(0xFF1976D2),
                                fontSize: 14,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedScreen = value!);
                    _filterLaptops();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Sort by:",
              style: TextStyle(
                color: Color(0xFF1976D2),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            DropdownButton<String>(
              value: ["Default", "Price: Low to High", "Price: High to Low"]
                      .contains(_sortOption)
                  ? _sortOption
                  : "Default",
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _sortOption = newValue;
                    _filterLaptops();
                  });
                }
              },
              items: [
                "Default",
                "Price: Low to High",
                "Price: High to Low",
              ]
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                      ))
                  .toList(),
              underline: const SizedBox(),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF1976D2),
              ),
              style: const TextStyle(
                color: Color(0xFF1976D2),
                fontSize: 14,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
                _filterLaptops();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF1976D2),
                          Color(0xFF42A5F5),
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : const Color(0xFFE0E0E0).withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                    shadows: isSelected
                        ? [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : [],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategorySelector(),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              itemCount: filteredLaptops.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.42,
              ),
              itemBuilder: (context, index) {
                final laptop = filteredLaptops[index];
                return TweenAnimationBuilder(
                  tween: Tween<double>(begin: 20.0, end: 0.0),
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
                    child: ProductCard(
                      product: {
                        'productId': laptop.productId,
                        'name': laptop.productName,
                        'description':
                            "RAM ${laptop.ram}, CPU: ${laptop.cpu}, ${laptop.storage}",
                        'image': laptop.imageProduct,
                        'price': laptop.price,
                        'screenSize': laptop.screenSize,
                        'categoryname': laptop.categoryName,
                        'stock': laptop.quantity,
                      },
                      onNavigateToDetail: (id) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.laptopDetail,
                          arguments: {
                            'productId': laptop.productId,
                            'productName': laptop.productName,
                            'price': laptop.price,
                            'imageProduct': laptop.imageProduct,
                            'categoryName': laptop.categoryName,
                            'ram': laptop.ram,
                            'cpu': laptop.cpu,
                            'storage': laptop.storage,
                            'screenSize': laptop.screenSize,
                            'stock': laptop.quantity,
                            'shopId': laptop.shopId,
                          },
                        );
                      },
                      onAddToCart: (id) {},
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
