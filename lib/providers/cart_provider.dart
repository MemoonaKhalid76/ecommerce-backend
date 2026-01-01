import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  // =====================
  // GETTERS
  // =====================

  /// 🔹 All cart items
  Map<String, CartItem> get items => _items;

  /// 🔹 Unique products count (agar kahin use ho raha ho)
  int get uniqueItemCount => _items.length;

  /// 🔹 🔥 TOTAL QUANTITY (FOR BADGE ON CART ICON)
  int get itemCount {
    int count = 0;
    for (var item in _items.values) {
      count += item.quantity;
    }
    return count;
  }

  /// 🔹 🔥 FINAL TOTAL (DISCOUNT SAFE)
  double get totalAmount {
    double total = 0;
    for (var item in _items.values) {
      total += item.totalPrice; // CartItem already uses discountedPrice
    }
    return total;
  }

  /// 🔹 🔥 ALIAS (OLD UI SAFETY)
  double get totalPrice => totalAmount;

  // =====================
  // CART ACTIONS
  // =====================

  /// 🔹 Add product to cart
  void addToCart(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  /// 🔹 Increase quantity
  void increaseQuantity(String productId) {
    if (!_items.containsKey(productId)) return;
    _items[productId]!.quantity++;
    notifyListeners();
  }

  /// 🔹 Decrease quantity
  void decreaseQuantity(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity--;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  /// 🔹 Remove item completely
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  /// 🔹 Clear cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // =====================
  // FUTURE READY
  // =====================

  /// 🔹 Place order (COD placeholder)
  /// (Actual API already handled in AddressScreen)
  void placeOrderCOD() {
    _items.clear();
    notifyListeners();
  }
}
