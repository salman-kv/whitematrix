import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

enum AppThemeMode { light, dark, system }

/// Holds the user's theme choice (Light / Dark / Follow system) and persists it.
class ThemeController extends ChangeNotifier {
  ThemeController(this._storage)
    : _mode = AppThemeMode.values[_storage.readThemeMode().clamp(0, 2)];

  final StorageService _storage;
  AppThemeMode _mode;

  AppThemeMode get mode => _mode;

  /// Whether the dark palette should be used, given the device brightness.
  bool resolveDark(Brightness platform) => switch (_mode) {
    AppThemeMode.light => false,
    AppThemeMode.dark => true,
    AppThemeMode.system => platform == Brightness.dark,
  };

  void setMode(AppThemeMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    _storage.saveThemeMode(mode.index);
    notifyListeners();
  }
}
