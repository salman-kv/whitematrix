class AppUser {
  final String name;
  final String email; // also the key that scopes this user's stored data
  final String phone;

  const AppUser({required this.name, required this.email, required this.phone});

  String get initials => name.isEmpty ? '?' : name[0].toUpperCase();

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    name: j['name'] as String,
    email: j['email'] as String,
    phone: (j['phone'] ?? '') as String,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
  };
}
