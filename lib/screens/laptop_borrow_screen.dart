import 'package:flutter/material.dart';
import '../../models/item_model.dart';
import '../../services/api_service.dart';
import '../../routes/app_routes.dart';
import '../models/category_model.dart';
import '../widgets/reuse/cards/card_borrow.dart';
import '../widgets/homepage/custom_header.dart';
import '../widgets/homepage/custom_footer.dart';

class LaptopBorrowScreen extends StatefulWidget {
  const LaptopBorrowScreen({super.key});

  @override
  State<LaptopBorrowScreen> createState() => _LaptopBorrowScreenState();
}

class _LaptopBorrowScreenState extends State<LaptopBorrowScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  Future<List<ItemModel>>? _futureLaptops;
  List<ItemModel> _filteredLaptops = [];
  List<Category> _categories = [];
  String _selectedCategory = 'All';

  String _selectedSort = 'Default';
  String _selectedCpu = 'All';
  String _selectedStorage = 'All';
  String _selectedScreenSize = 'All';
  String _selectedRam = 'All';

  bool _showSearch = false;
  bool _showFilters = false;
  bool _showSort = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchLaptops();
  }

  void _fetchCategories() async {
    try {
      List<Category> categories = await _apiService.fetchCategories();
      setState(() {
        _categories =
            [Category(categoryId: 0, categoryName: "All")] + categories;
      });
    } catch (e) {
      debugPrint("Failed to load categories: $e");
    }
  }

  void _fetchLaptops() {
    setState(() {
      _futureLaptops = _apiService.fetchItems().then((laptops) {
        _filterLaptops(laptops, _searchController.text);
        return laptops;
      });
    });
  }

  void _filterLaptops(List<ItemModel> laptops, String query) {
    final selectedCategory = _categories.firstWhere(
      (c) => c.categoryName == _selectedCategory,
      orElse: () => Category(categoryId: 0, categoryName: "All"),
    );

    setState(() {
      _filteredLaptops = laptops.where((laptop) {
        final matchesSearch =
            laptop.itemName.toLowerCase().contains(query.toLowerCase());

        final matchesCategory = selectedCategory.categoryId == 0 ||
            laptop.categoryId == selectedCategory.categoryId;

        final cpuValue = laptop.cpu?.toLowerCase() ?? '';
        final matchesCpu = _selectedCpu == 'All' ||
            cpuValue.contains(_selectedCpu.toLowerCase());

        final rawStorage = laptop.storage?.toLowerCase() ?? '';
        final normalizedStorage = rawStorage.contains('tb')
            ? '1024'
            : rawStorage.replaceAll(RegExp(r'[^0-9]'), '');
        final selectedStorageNumber =
            _selectedStorage.replaceAll(RegExp(r'[^0-9]'), '');
        final matchesStorage = _selectedStorage == 'All' ||
            normalizedStorage == selectedStorageNumber;

        final screenValue = laptop.screenSize?.toLowerCase() ?? '';
        final matchesScreenSize = _selectedScreenSize == 'All' ||
            screenValue.contains(_selectedScreenSize.toLowerCase());

        final ramValue =
            laptop.ram.toLowerCase().replaceAll(RegExp(r'[^0-9]'), '');
        final selectedRamNumber =
            _selectedRam.replaceAll(RegExp(r'[^0-9]'), '');
        final matchesRam =
            _selectedRam == 'All' || ramValue == selectedRamNumber;

        return matchesSearch &&
            matchesCategory &&
            matchesCpu &&
            matchesStorage &&
            matchesScreenSize &&
            matchesRam;
      }).toList();

      if (_selectedSort == 'RAM: Low to High') {
        _filteredLaptops.sort((a, b) => a.ram.compareTo(b.ram));
      } else if (_selectedSort == 'RAM: High to Low') {
        _filteredLaptops.sort((a, b) => b.ram.compareTo(a.ram));
      }
    });
  }

  void _onSearchChanged(String query) {
    _futureLaptops?.then((laptops) => _filterLaptops(laptops, query));
  }

  Widget _buildControlIcons() {
    return Padding(
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
                _onSearchChanged('');
              });
            },
          ),
          const SizedBox(width: 4),
          _buildToolButton(
            icon: _showFilters ? Icons.tune : Icons.tune_outlined,
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
          ),
          const SizedBox(width: 4),
          _buildToolButton(
            icon: _showSort ? Icons.sort : Icons.sort_outlined,
            onPressed: () {
              setState(() => _showSort = !_showSort);
            },
          ),
        ],
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
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF1976D2),
            ),
            hintText: 'Search laptops...',
            hintStyle: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
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
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hint,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: hint,
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
      isExpanded: true,
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Color(0xFF1976D2),
                    fontSize: 14,
                  ),
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildFilterAndSortRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          if (_showSort)
            Container(
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
                    value: _selectedSort,
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() => _selectedSort = value);
                        _onSearchChanged(_searchController.text);
                      }
                    },
                    items: [
                      'Default',
                      'RAM: Low to High',
                      'RAM: High to Low',
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
                  ),
                ],
              ),
            ),
          if (_showFilters) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownFilter(
                    label: "CPU",
                    value: _selectedCpu,
                    items: ['All', 'i3', 'i5', 'i7', 'i9', 'm1'],
                    onChanged: (value) {
                      setState(() => _selectedCpu = value!);
                      _onSearchChanged(_searchController.text);
                    },
                    hint: "CPU",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdownFilter(
                    label: "Storage",
                    value: _selectedStorage,
                    items: ['All', '128 GB', '256 GB', '512 GB', '1 TB'],
                    onChanged: (value) {
                      setState(() => _selectedStorage = value!);
                      _onSearchChanged(_searchController.text);
                    },
                    hint: "Storage",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownFilter(
                    label: "Screen Size",
                    value: _selectedScreenSize,
                    items: ['All', '13', '14', '15.6', '16'],
                    onChanged: (value) {
                      setState(() => _selectedScreenSize = value!);
                      _onSearchChanged(_searchController.text);
                    },
                    hint: "Screen Size",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdownFilter(
                    label: "RAM",
                    value: _selectedRam,
                    items: ['All', '4 GB', '8 GB', '16 GB', '32 GB'],
                    onChanged: (value) {
                      setState(() => _selectedRam = value!);
                      _onSearchChanged(_searchController.text);
                    },
                    hint: "RAM",
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category.categoryName;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category.categoryName;
                _onSearchChanged(_searchController.text);
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
                  category.categoryName,
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

  Widget _buildLaptopList() {
    return FutureBuilder<List<ItemModel>>(
      future: _futureLaptops,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF1976D2),
            ),
          );
        } else if (snapshot.hasError) {
          return _buildErrorWidget();
        } else if (_filteredLaptops.isEmpty) {
          return const Center(
            child: Text(
              "No laptops available for borrowing.",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.45,
          ),
          itemCount: _filteredLaptops.length,
          itemBuilder: (context, index) {
            final laptop = _filteredLaptops[index];
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
                child: GestureDetector(
                  onTap: () => _navigateToDetail(laptop),
                  child: CardBorrow(
                    product: {
                      'id': laptop.itemId.toString(),
                      'name': laptop.itemName,
                      'shortDescription':
                          "CPU: ${laptop.cpu}, RAM: ${laptop.ram}, ${laptop.storage}",
                      'image':
                          laptop.itemImage ?? 'https://via.placeholder.com/300',
                      'status': laptop.status,
                      'processor': laptop.cpu,
                      'ram': laptop.ram,
                      'storage': laptop.storage,
                      'screenSize': "${laptop.screenSize} inch",
                      'category': laptop.conditionItem,
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Failed to load laptops.",
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _fetchLaptops,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                    color: Colors.black.withOpacity(0.2),
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
  }

  void _navigateToDetail(ItemModel laptop) {
    Navigator.pushNamed(
      context,
      AppRoutes.laptopBorrowDetail,
      arguments: laptop.toJson(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(
              showBackButton: true,
              title: "Borrow Laptops",
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  _buildControlIcons(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _showSearch
                        ? _buildSearchBar()
                        : const SizedBox.shrink(key: ValueKey("no_search")),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: (_showFilters || _showSort)
                        ? _buildFilterAndSortRow()
                        : const SizedBox.shrink(
                            key: ValueKey("no_filters_sort")),
                  ),
                  const SizedBox(height: 12),
                  _buildCategorySelector(),
                ],
              ),
            ),
            Expanded(
              child: _buildLaptopList(),
            ),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
