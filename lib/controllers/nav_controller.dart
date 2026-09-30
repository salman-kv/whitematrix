import 'package:flutter/foundation.dart';

/// Which bottom-navigation tab is selected.
class NavController extends ChangeNotifier {
  static const home = 0;
  static const categories = 1;
  static const cart = 2;
  static const wishlist = 3;
  static const profile = 4;

  int _index = home;
  int get index => _index;

  void select(int i) {
    if (i == _index) return;
    _index = i;
    notifyListeners();
  }
}
