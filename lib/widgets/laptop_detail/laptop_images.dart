import 'package:flutter/material.dart';

class LaptopImages extends StatefulWidget {
  final List<String> imageUrls;

  const LaptopImages({super.key, required this.imageUrls});

  @override
  _LaptopImagesState createState() => _LaptopImagesState();
}

class _LaptopImagesState extends State<LaptopImages> {
  int _selectedIndex = 0; // Chỉ số của ảnh lớn hiện tại

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ảnh lớn
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            widget.imageUrls[_selectedIndex],
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        // Ảnh thu nhỏ
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex =
                          index; // Cập nhật chỉ số ảnh lớn khi nhấn
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedIndex == index
                            ? Colors.blueAccent
                            : Colors.transparent,
                        width: 1, // Chỉ cần viền mỏng
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      widget.imageUrls[index],
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
