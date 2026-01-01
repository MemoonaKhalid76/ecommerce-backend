import '../utils/constants.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final int discount;
  final String category;
  final List<String> images;
  final String description;
  final int stock;
  final String fulldescription;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.discount,
    required this.category,
    required this.images,
    required this.description,
    required this.stock,
    required this.fulldescription,
  });

  bool get inStock => stock > 0;

  double get discountedPrice {
    if (discount <= 0) return price;
    return price - (price * discount / 100);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // ✅ FULL BACKWARD COMPATIBILITY
    List<String> imgs = [];

    if (json['images'] != null && json['images'] is List) {
      imgs = List<String>.from(json['images']);
    } else if (json['image'] != null) {
      // 'image' can be a String OR a List. Handle both.
      if (json['image'] is List) {
         imgs = List<String>.from(json['image']);
      } else if (json['image'] is String) {
         imgs = [json['image']];
      }
    } else {
      imgs = []; // SAFE FALLBACK
    }
    
    // Fix localhost URLs and handle relative paths
    final apiUri = Uri.tryParse(AppConstants.baseUrl);
    if (apiUri == null) {
      // Emergency fallback if constant is broken
      return Product(
        id: json['_id']?.toString() ?? '',
        name: json['name'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        discount: json['discount'] ?? 0,
        category: json['category'] ?? '',
        images: [],
        description: json['description'] ?? '',
        stock: json['stock'] ?? 0,
        fulldescription: json['fulldescription'] ?? '',
      );
    }
    
    final rootUrl = '${apiUri.scheme}://${apiUri.host}:${apiUri.port}';

    imgs = imgs.map((url) {
      if (url.isEmpty) return '';
      
      String finalUrl = url;
      
      // Clean up Windows backslashes if any
      finalUrl = finalUrl.replaceAll('\\', '/');

      if (finalUrl.startsWith('http')) {
         // It's a full URL, check for localhost
         if (finalUrl.contains('localhost') || finalUrl.contains('127.0.0.1')) {
           finalUrl = finalUrl.replaceFirst('localhost', apiUri.host).replaceFirst('127.0.0.1', apiUri.host);
         }
      } else {
        // It's a relative path
        String cleanPath = finalUrl;
        if (cleanPath.startsWith('/')) {
          cleanPath = cleanPath.substring(1);
        }
        finalUrl = '$rootUrl/$cleanPath';
      }

      // Validating the URL
      if (Uri.tryParse(finalUrl) == null) {
         print('ERROR: Invalid URL generated: $finalUrl');
         return ''; // Return empty to be filtered out or handled by UI
      }

      return finalUrl;
    }).where((u) => u.isNotEmpty).toList();

    return Product(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discount: json['discount'] ?? 0,
      category: json['category'] ?? '',
      images: imgs,
      description: json['description'] ?? '',
      stock: json['stock'] ?? 0,
      fulldescription: json['fulldescription'] ?? '',
    );
  }
}
