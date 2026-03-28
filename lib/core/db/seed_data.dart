part of 'app_database.dart';

abstract class SeedData {
  static List<CategoriesCompanion> get defaultCategories => [
        _category('Food & Dining', 0xe533, '#FF6B6B'),
        _category('Transport', 0xe531, '#4ECDC4'),
        _category('Shopping', 0xe59c, '#45B7D1'),
        _category('Bills & Utilities', 0xe1f3, '#96CEB4'),
        _category('Health & Medical', 0xe548, '#FFEAA7'),
        _category('Entertainment', 0xe415, '#DDA0DD'),
        _category('Personal Care', 0xe3d3, '#98D8C8'),
        _category('Education', 0xe80c, '#F7DC6F'),
        _category('Other', 0xe8b8, '#BDC3C7'),
      ];

  static List<AccountsCompanion> get defaultAccounts => [
        _account('Cash', 'cash', '#4CAF50'),
        _account('GCash', 'ewallet', '#007DC5'),
        _account('Maya', 'ewallet', '#00C853'),
        _account('ShopeePay', 'ewallet', '#EE4D2D'),
        _account('GrabPay', 'ewallet', '#00B14F'),
        _account('UnionBank', 'bank', '#003087'),
        _account('BDO', 'bank', '#D50000'),
        _account('BPI', 'bank', '#C8102E'),
        _account('GoTyme', 'bank', '#FF6900'),
        _account('Tonik', 'bank', '#6A1B9A'),
      ];

  static CategoriesCompanion _category(
    String name,
    int iconCodepoint,
    String color,
  ) =>
      CategoriesCompanion.insert(
        name: name,
        iconCodepoint: iconCodepoint,
        color: color,
        isDefault: const Value(true),
      );

  static AccountsCompanion _account(String name, String type, String color) =>
      AccountsCompanion.insert(
        name: name,
        type: type,
        color: color,
      );
}
