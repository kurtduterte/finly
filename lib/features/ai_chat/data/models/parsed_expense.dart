class ParsedExpense {
  const ParsedExpense({
    required this.amountCentavos,
    required this.description,
    required this.categoryName,
    required this.accountName,
    required this.date,
  });
  final int amountCentavos;
  final String description;
  final String categoryName;
  final String accountName;
  final DateTime date;
}
