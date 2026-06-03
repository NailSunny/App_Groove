import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, int> _cart = {};
  int _selectedIndex = 0;

  Map<int, int> get cart => Map.unmodifiable(_cart);
  int get selectedIndex => _selectedIndex;

  int quantityFor(int abonementId) => _cart[abonementId] ?? 0;

  void syncFromServer(Map<int, int> items) {
    _cart
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  void setQuantity(int abonementId, int quantity) {
    if (quantity <= 0) {
      _cart.remove(abonementId);
    } else {
      _cart[abonementId] = quantity;
    }
    notifyListeners();
  }

  void addItem(int abonementId) {
    _cart[abonementId] = (_cart[abonementId] ?? 0) + 1;
    notifyListeners();
  }

  void removeItem(int abonementId) {
    if (!_cart.containsKey(abonementId)) return;
    if (_cart[abonementId]! > 1) {
      _cart[abonementId] = _cart[abonementId]! - 1;
    } else {
      _cart.remove(abonementId);
    }
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  int get totalItems => _cart.values.fold(0, (a, b) => a + b);

  void clear() {
    _cart.clear();
    notifyListeners();
  }
}
