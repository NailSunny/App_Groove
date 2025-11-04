// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, int> _cart = {};
  int _selectedIndex = 0;

  Map<String, int> get cart => _cart;
  int get selectedIndex => _selectedIndex;

  void addItem(String title) {
    _cart[title] = (_cart[title] ?? 0) + 1;
    notifyListeners();
  }

  void removeItem(String title) {
    if (!_cart.containsKey(title)) return;
    if (_cart[title]! > 1) {
      _cart[title] = _cart[title]! - 1;
    } else {
      _cart.remove(title);
    }
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  int get totalItems => _cart.values.fold(0, (a, b) => a + b);
}
