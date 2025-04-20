import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _cart = [];
  bool _isLoading = false;
  List<CartItem> get cart => _cart;
  bool get isLoading => _isLoading;

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');
    if (userId == null) {
      print("❌ Không tìm thấy userId, vui lòng đăng nhập lại.");
      _isLoading = false;
      notifyListeners();
      return;
    }

    final box = await Hive.openBox<CartItem>('cartBox_$userId');
    _cart = box.values.toList(); // Đảm bảo giỏ hàng được cập nhật

    // In giỏ hàng sau khi tải
    print("🔄 Giỏ hàng sau khi tải: ${_cart.map((e) => e.toJson()).toList()}");

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart(CartItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');
    if (userId == null) return;

    final box = await Hive.openBox<CartItem>('cartBox_$userId');

    // Kiểm tra xem sản phẩm đã có trong giỏ hàng chưa
    if (box.containsKey(item.productId)) {
      final existingItem = box.get(item.productId)!;
      existingItem.quantity += item.quantity;
      existingItem.save();
    } else {
      box.put(item.productId, item); // Thêm mới nếu chưa có
    }

    _cart = box.values.toList(); // Đọc lại toàn bộ giỏ hàng

    // In giỏ hàng ra để kiểm tra sau khi thêm
    print("Giỏ hàng sau khi thêm: ${_cart.map((e) => e.toJson()).toList()}");

    notifyListeners();
  }

  Future<void> removeItem(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');
    if (userId == null) return;

    final box = await Hive.openBox<CartItem>('cartBox_$userId');
    box.delete(productId);

    _cart = box.values.toList();
    notifyListeners();
  }

  Future<void> decreaseQuantity(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');
    if (userId == null) return;

    final box = await Hive.openBox<CartItem>('cartBox_$userId');
    if (box.containsKey(productId)) {
      final existingItem = box.get(productId)!;
      if (existingItem.quantity > 1) {
        existingItem.quantity -= 1;
        existingItem.save();
      } else {
        box.delete(productId);
      }
    }

    _cart = box.values.toList();
    notifyListeners();
  }

  Future<void> increaseQuantity(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');
    if (userId == null) return;

    final box = await Hive.openBox<CartItem>('cartBox_$userId');
    if (box.containsKey(productId)) {
      final existingItem = box.get(productId)!;
      final stock =
          existingItem.stock ?? 0; // Kiểm tra null và gán giá trị mặc định là 0

      // Kiểm tra nếu số lượng giỏ hàng chưa vượt quá tồn kho
      if (existingItem.quantity < stock) {
        existingItem.quantity += 1; // Tăng số lượng trong giỏ
        existingItem.save(); // Lưu thay đổi vào Hive
      } else {
        // Hiển thị thông báo nếu số lượng vượt quá tồn kho
        print('❌ Không thể tăng số lượng. Vượt quá số lượng tồn kho.');
      }
    }

    _cart = box.values.toList();

    // In giỏ hàng sau khi tăng số lượng
    print(
        "Giỏ hàng sau khi tăng số lượng: ${_cart.map((e) => e.toJson()).toList()}");

    notifyListeners();
  }

  double getTotalPrice() {
    return _cart.fold(0, (total, item) => total + (item.price * item.quantity));
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');
    if (userId == null) return;

    final box = await Hive.openBox<CartItem>('cartBox_$userId');
    box.clear();

    _cart = [];
    notifyListeners();
  }
}
