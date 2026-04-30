class ScanPrefill {
  const ScanPrefill({
    this.amountCentavos,
    this.description,
    this.categoryName,
    this.accountName,
    this.date,
    this.receiptId,
  });

  final int? amountCentavos;
  final String? description;
  final String? categoryName;
  final String? accountName;
  final DateTime? date;
  final int? receiptId;
}
