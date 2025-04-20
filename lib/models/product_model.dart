class Product {
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final String imageProduct;
  final String screenSize;
  final String storage;
  final String ram;
  final String cpu;
  final String categoryName;
  final int categoryId;
  final int shopId;
  final String? shopName;
  final String createdDate;
  final String updatedDate;

  Product({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.imageProduct,
    required this.screenSize,
    required this.storage,
    required this.ram,
    required this.cpu,
    required this.categoryName,
    required this.categoryId,
    required this.shopId,
    this.shopName,
    required this.createdDate,
    required this.updatedDate,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] ?? 0, // Nếu null thì đặt mặc định là 0
      productName: json['productName'] ?? 'Không có tên',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageProduct: json['imageProduct'] ?? '',
      screenSize: json['screenSize'] ?? 'Không rõ',
      storage: json['storage'] ?? 'Không rõ',
      ram: json['ram'] ?? 'Không rõ',
      cpu: json['cpu'] ?? 'Không rõ',
      categoryName: json['categoryName'] ?? 'Không có danh mục',
      categoryId: json['categoryId'] ?? 0,
      shopId: json['shopId'] ?? 0,
      shopName: json['shopName'] ?? 'Không có thông tin',
      createdDate: json['createdDate'] ?? '',
      updatedDate: json['updatedDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'imageProduct': imageProduct,
      'screenSize': screenSize,
      'storage': storage,
      'ram': ram,
      'cpu': cpu,
      'categoryName': categoryName,
      'categoryId': categoryId,
      'shopId': shopId,
      'shopName': shopName,
      'createdDate': createdDate,
      'updatedDate': updatedDate,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': productName.isNotEmpty ? productName : 'Không có tên',
      'description':
          "RAM ${ram.isNotEmpty ? ram : 'Không rõ'}, CPU: ${cpu.isNotEmpty ? cpu : 'Không rõ'}, ${storage.isNotEmpty ? storage : 'Không rõ'}",
      'image': imageProduct.isNotEmpty ? imageProduct : '',
      'price': price,
      'screenSize': screenSize.isNotEmpty ? screenSize : 'Không rõ',
      'categoryname':
          categoryName.isNotEmpty ? categoryName : 'Không có danh mục',
      'shopName': shopName ??
          'Không có thông tin', // Nếu shopName là null thì đặt giá trị mặc định
      'createdDate': createdDate.isNotEmpty ? createdDate : '',
      'updatedDate': updatedDate.isNotEmpty ? updatedDate : '',
    };
  }
}
