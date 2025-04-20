import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../widgets/homepage/custom_header.dart';
import '../widgets/homepage/custom_footer.dart';
import '../widgets/homepage/highlight_feature_card.dart';
import '../widgets/homepage/hero_section.dart';
import '../widgets/homepage/highlight_feature_section.dart';
import '../widgets/homepage/highlight_feature_section_2.dart';
import '../widgets/homepage/list_laptop.dart';
import '../widgets/homepage/list_laptop_borrow.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _affordableLaptopsKey = GlobalKey();
  final GlobalKey _hassleFreeBorrowingKey = GlobalKey();

  void _scrollToSection(String sectionId) {
    if (sectionId == 'affordable-laptops') {
      Scrollable.ensureVisible(
        _affordableLaptopsKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else if (sectionId == 'hassle-free-borrowing') {
      Scrollable.ensureVisible(
        _hassleFreeBorrowingKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CartProvider>(context, listen: false).loadCart();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeroSection(),
                    const SizedBox(height: 24),
                    _buildFeatureCards(),
                    const SizedBox(height: 32),
                    _buildLaptopLists(),
                    const SizedBox(height: 32),
                    _buildHighlightSections(),
                    const SizedBox(height: 24),
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

  Widget _buildFeatureCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 180,
        child: Row(
          children: [
            Expanded(
              child: HighlightFeatureCard(
                title: 'Affordable Laptops',
                image: 'assets/images/laptopsell.jpg',
                sectionId: 'affordable-laptops',
                onTap: () => _scrollToSection('affordable-laptops'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: HighlightFeatureCard(
                title: 'Hassle-Free Borrowing',
                image: 'assets/images/laptopborrow.jpg',
                sectionId: 'hassle-free-borrowing',
                onTap: () => _scrollToSection('hassle-free-borrowing'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaptopLists() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ListLaptop(), // Đã có tiêu đề bên trong
        const SizedBox(height: 24),
        const ListLaptopBorrow(), // Đã có tiêu đề bên trong
      ],
    );
  }

  Widget _buildHighlightSections() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          HighlightFeatureSection(
            key: _affordableLaptopsKey,
            images: {
              'img1': 'assets/images/laptopsell1.jpg',
              'img2': 'assets/images/laptopsell2.jpg',
            },
          ),
          const SizedBox(height: 24),
          HighlightFeatureSection2(
            key: _hassleFreeBorrowingKey,
            image: 'assets/images/laptopborrow1.jpg',
          ),
        ],
      ),
    );
  }
}
