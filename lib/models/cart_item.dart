import 'product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  // 🔥 ALWAYS USE DISCOUNTED PRICE
  double get totalPrice => product.discountedPrice * quantity;
}
