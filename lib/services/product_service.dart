import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String? image;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.image,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'category': category,
        'image': image,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        price: json['price'].toDouble(),
        category: json['category'],
        image: json['image'],
      );
}

class ProductService {
  static const String _productsKey = 'stored_products';
  static ProductService? _instance;
  List<Product> _products = [];

  static ProductService get instance {
    _instance ??= ProductService._internal();
    return _instance!;
  }

  ProductService._internal() {
    _initializeDefaultProducts();
  }

  void _initializeDefaultProducts() {
    _products = [
      Product(
        id: 'prod_1',
        name: 'Organic Bananas',
        price: 2.99,
        category: 'Fruits',
        image:
            'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
      ),
      Product(
        id: 'prod_2',
        name: 'Greek Yogurt',
        price: 4.49,
        category: 'Dairy',
        image:
            'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400&h=400&fit=crop',
      ),
      Product(
        id: 'prod_3',
        name: 'Whole Wheat Bread',
        price: 3.29,
        category: 'Bakery',
        image:
            'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop',
      ),
      Product(
        id: 'prod_4',
        name: 'Extra Virgin Olive Oil',
        price: 8.99,
        category: 'Pantry',
        image:
            'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&h=400&fit=crop',
      ),
      Product(
        id: 'prod_5',
        name: 'Fresh Salmon Fillet',
        price: 12.99,
        category: 'Seafood',
        image:
            'https://images.unsplash.com/photo-1544943910-4c1dc44aab44?w=400&h=400&fit=crop',
      ),
      Product(
        id: 'prod_6',
        name: 'Organic Spinach',
        price: 3.49,
        category: 'Vegetables',
        image:
            'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400&h=400&fit=crop',
      ),
      Product(
        id: 'prod_7',
        name: 'Milk',
        price: 4.99,
        category: 'Dairy',
        image:
            'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400&h=400&fit=crop',
      ),
      Product(
        id: 'prod_8',
        name: 'Eggs',
        price: 3.99,
        category: 'Dairy',
        image:
            'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=400&h=400&fit=crop',
      ),
      Product(
        id: 'prod_9',
        name: 'Chicken Breast',
        price: 12.99,
        category: 'Meat',
        image:
            'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400&h=400&fit=crop',
      ),
      Product(
        id: 'prod_10',
        name: 'Apples',
        price: 5.99,
        category: 'Fruits',
        image:
            'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400&h=400&fit=crop',
      ),
    ];
  }

  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getString(_productsKey);

    if (productsJson != null) {
      final List<dynamic> productList = json.decode(productsJson);
      _products = productList.map((json) => Product.fromJson(json)).toList();
    }
  }

  Future<void> saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = json.encode(_products.map((p) => p.toJson()).toList());
    await prefs.setString(_productsKey, productsJson);
  }

  List<Product> get products => List.unmodifiable(_products);

  Product? findProductByName(String name) {
    try {
      return _products.firstWhere(
        (product) => product.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return [];

    final lowercaseQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
          product.category.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<void> addProduct(Product product) async {
    _products.add(product);
    await saveProducts();
  }

  Future<void> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      await saveProducts();
    }
  }

  Future<void> deleteProduct(String productId) async {
    _products.removeWhere((p) => p.id == productId);
    await saveProducts();
  }

  double getProductPrice(String productName) {
    final product = findProductByName(productName);
    return product?.price ?? 0.00;
  }

  Product? getProductDetails(String productName) {
    return findProductByName(productName);
  }

  List<Product> getRecentProducts({int limit = 10}) {
    return _products.take(limit).toList();
  }
}
