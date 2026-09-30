class Fmt {
  Fmt._();

  static String money(num v) => '\$${v.toStringAsFixed(2)}';

  static String compactCount(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  static String titleCase(String slug) => slug
      .split(RegExp(r'[-_ ]'))
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
