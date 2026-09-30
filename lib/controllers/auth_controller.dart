import 'package:flutter/foundation.dart';

import '../core/demo_accounts.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

/// Hard-coded authentication against [DemoAccounts]. The session is persisted
/// so the splash screen can skip the login page on the next launch. Logging in
/// scopes [StorageService] to that account, so every account has its own data.
class AuthController extends ChangeNotifier {
  AuthController(this._storage) : _user = _storage.readUser() {
    _storage.useAccount(_user?.email);
  }

  final StorageService _storage;
  AppUser? _user;
  bool _loading = false;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _loading;

  /// The demo account behind the current session (for avatar colour etc.).
  DemoAccount? get account {
    final email = _user?.email;
    for (final a in DemoAccounts.all) {
      if (a.email == email) return a;
    }
    return null;
  }

  /// Returns true on success, false when the credentials are wrong.
  Future<bool> login(String identifier, String password) async {
    _loading = true;
    notifyListeners();
    await Future<void>.delayed(
      const Duration(milliseconds: 1000),
    ); // fake latency
    final found = DemoAccounts.authenticate(identifier, password);
    if (found != null) {
      _storage.useAccount(found.email);
      _user = AppUser(name: found.name, email: found.email, phone: found.phone);
      await _storage.saveUser(_user);
    }
    _loading = false;
    notifyListeners();
    return found != null;
  }

  Future<void> logout() async {
    _user = null;
    _storage.useAccount(null);
    await _storage.saveUser(null);
    notifyListeners();
  }
}
