import 'package:flutter/material.dart';

class HighlightFeatureCard extends StatefulWidget {
  final String title;
  final String image;
  final String sectionId;
  final VoidCallback onTap;

  const HighlightFeatureCard({
    super.key,
    required this.title,
    required this.image,
    required this.sectionId,
    required this.onTap,
  });

  @override
  State<HighlightFeatureCard> createState() => _HighlightFeatureCardState();
}

class _HighlightFeatureCardState extends State<HighlightFeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
          milliseconds: 200), // Giảm thời gian animation để nhẹ nhàng hơn
      vsync: this,
    );
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 1.03).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.only(
                bottom: 16), // Giảm khoảng cách để gọn gàng hơn
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                  12), // Bo tròn nhẹ để tạo cảm giác thanh thoát
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background Image
                  SizedBox(
                    height: 180, // Chiều cao gọn gàng hơn
                    width: double.infinity,
                    child: Image.asset(
                      widget.image.isNotEmpty
                          ? widget.image
                          : 'assets/images/placeholder.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200], // Màu xám sáng hơn
                          child: const Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.grey,
                              size: 30,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Overlay with subtle gradient
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.2), // Gradient nhẹ nhàng
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),

                  // Title
                  Positioned(
                    bottom: 12, // Khoảng cách ít hơn, tạo không gian thoáng
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16, // Font size vừa phải, dễ đọc
                        fontWeight:
                            FontWeight.w600, // Độ đậm nhẹ, không quá mạnh
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 1),
                            blurRadius: 5, // Blur nhẹ nhàng
                            color: Colors.black.withOpacity(0.6),
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
}
