import 'package:flutter/material.dart';

class DemoAccount {
  final String name;
  final String email;
  final String phone;
  final String password;
  final Color accent;

  const DemoAccount({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.accent,
  });
}

/// Hard-coded *logins* (there is no backend). Only the credentials are fixed:
/// the cart, wishlist, orders and recent searches of each account are created
/// by that user and stored separately under their e-mail address.
class DemoAccounts {
  DemoAccounts._();

  static const salman = DemoAccount(
    name: 'Salman Khan',
    email: 'salman@gmail.com',
    phone: '9876543210',
    password: 'Shop@123',
    accent: Color(0xFF1F64F2),
  );

  static const aisha = DemoAccount(
    name: 'Aisha Rahman',
    email: 'aisha@shopease.com',
    phone: '9123456780',
    password: 'Aisha@456',
    accent: Color(0xFFE11D74),
  );

  static const rahul = DemoAccount(
    name: 'Rahul Nair',
    email: 'rahul@shopease.com',
    phone: '9000011111',
    password: 'Rahul@789',
    accent: Color(0xFF059669),
  );

  static const all = [salman, aisha, rahul];

  /// Returns the account matching the e-mail/phone + password, else null.
  static DemoAccount? authenticate(String identifier, String password) {
    final id = identifier.trim().toLowerCase();
    for (final a in all) {
      if ((id == a.email || id == a.phone) && password == a.password) return a;
    }
    return null;
  }
}
