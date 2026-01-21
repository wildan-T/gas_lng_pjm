class GasPrice {
  final String id;
  final int year;
  final int month;
  final double pricePerM3;
  final DateTime updatedAt;
  final String updatedBy;

  GasPrice({
    required this.id,
    required this.year,
    required this.month,
    required this.pricePerM3,
    required this.updatedAt,
    required this.updatedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'pricePerM3': pricePerM3,
      'updatedAt': updatedAt.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }
}