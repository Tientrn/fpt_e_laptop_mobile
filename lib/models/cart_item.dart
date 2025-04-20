import 'package:hive/hive.dart';

part 'cart_item.g.dart'; // Dùng để tạo Adapter

@HiveType(typeId: 0)
class CartItem extends HiveObject {
  @HiveField(0)
  String productId;

  @HiveField(1)
  String name;

  @HiveField(2)
  double price;

  @HiveField(3)
  int quantity;

  @HiveField(4)
  String imageUrl;

  @HiveField(5)
  final int stock; // Đảm bảo stock là kiểu int và không thể null

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.stock, // Đảm bảo stock không phải null
  });

  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      "name": name,
      "price": price,
      "quantity": quantity,
      "imageUrl": imageUrl,
      "stock": stock, // Lưu stock vào JSON
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json["productId"],
      name: json["name"],
      price: json["price"],
      quantity: json["quantity"],
      imageUrl: json["imageUrl"],
      stock: json["stock"] ?? 0,
    );
  }
}
