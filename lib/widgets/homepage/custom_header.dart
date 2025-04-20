import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';

class CustomHeader extends StatelessWidget {
  final bool showBackButton;
  final String? title;

  const CustomHeader({
    super.key,
    this.showBackButton = false,
    this.title,
  });

  Future<void> _logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken');

      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception("No refresh token found.");
      }

      final success = await ApiService().logout(refreshToken);

      if (success) {
        await prefs.clear();
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        throw Exception("Logout failed");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C3E50), // Màu xanh đậm
            Color(0xFF3498DB), // Màu xanh dương
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button or Logo
            Row(
              children: [
                if (showBackButton)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.home);
                        }
                      },
                    ),
                  )
                else ...[
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.laptop,
                      color: Color(0xFF2C3E50),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'FPT E-Laptop',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),

            // Title in Center (if provided)
            if (title != null)
              Expanded(
                child: Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

            // Menu Button
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Color(0xFF2C3E50),
                onSelected: (String value) {
                  if (value == 'logout') {
                    _logout(context);
                  } else if (value == 'history') {
                    Navigator.pushNamed(context, AppRoutes.orderhistory);
                  } else if (value == 'borrow_request') {
                    Navigator.pushNamed(context, AppRoutes.laptopBorrowRequest);
                  } else if (value == 'borrow_contract') {
                    Navigator.pushNamed(context, AppRoutes.borrowContract);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  _buildMenuItem('Order History', 'history'),
                  _buildMenuItem('Borrow Requests', 'borrow_request'),
                  _buildMenuItem('Borrow Contracts', 'borrow_contract'),
                  _buildMenuItem('Logout', 'logout', isDestructive: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String text, String value,
      {bool isDestructive = false}) {
    return PopupMenuItem<String>(
      value: value,
      child: Text(
        text,
        style: TextStyle(
          color: isDestructive ? Color(0xFFE74C3C) : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
