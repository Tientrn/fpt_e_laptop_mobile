import 'package:flutter/material.dart';

class HighlightFeatureSection extends StatefulWidget {
  final Map<String, String> images;

  const HighlightFeatureSection({
    Key? key,
    required this.images,
  }) : super(key: key);

  @override
  State<HighlightFeatureSection> createState() =>
      _HighlightFeatureSectionState();
}

class _HighlightFeatureSectionState extends State<HighlightFeatureSection> {
  bool _isHovered1 = false;
  bool _isHovered2 = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5FA),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 768;

          return Column(
            children: [
              if (isMobile) ...[
                _buildImages(),
                const SizedBox(height: 12),
                _buildContent(),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _buildImages()),
                    const SizedBox(width: 24),
                    Expanded(child: _buildContent()),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, double opacity, child) {
              return Opacity(
                opacity: opacity,
                child: child,
              );
            },
            child: Text(
              'Budget-Friendly Student Laptops',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1976D2),
              ),
              textAlign: MediaQuery.of(context).size.width < 768
                  ? TextAlign.center
                  : TextAlign.left,
            ),
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, double opacity, child) {
              return Opacity(
                opacity: opacity,
                child: child,
              );
            },
            child: RichText(
              textAlign: MediaQuery.of(context).size.width < 768
                  ? TextAlign.center
                  : TextAlign.left,
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        'Explore our collection of high-quality laptops at affordable prices.\n\n',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  TextSpan(
                    text:
                        'Perfect for students with long-lasting battery, lightweight design, reliable performance, official warranty, and student-friendly payment plans.',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/laptopShop');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Redirecting to shop!',
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
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: MediaQuery.of(context).size.width < 768
                      ? double.infinity
                      : 160,
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Shop Now',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildImages() {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered1 = true),
              onExit: (_) => setState(() => _isHovered1 = false),
              child: TweenAnimationBuilder(
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  transform: Matrix4.identity()
                    ..scale(_isHovered1 ? 1.06 : 1.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isHovered1
                          ? const Color(0xFF42A5F5).withOpacity(0.3)
                          : Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(_isHovered1 ? 0.15 : 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      widget.images['img1'] ?? 'assets/images/placeholder.jpg',
                      width: 240,
                      height: 240,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _imageErrorWidget();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered2 = true),
              onExit: (_) => setState(() => _isHovered2 = false),
              child: TweenAnimationBuilder(
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  transform: Matrix4.identity()
                    ..scale(_isHovered2 ? 1.06 : 1.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isHovered2
                          ? const Color(0xFF42A5F5).withOpacity(0.3)
                          : Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(_isHovered2 ? 0.15 : 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      widget.images['img2'] ?? 'assets/images/placeholder.jpg',
                      width: 240,
                      height: 240,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _imageErrorWidget();
                      },
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

  Widget _imageErrorWidget() {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(10),
      ),
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
    );
  }
}
