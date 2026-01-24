import 'package:cloud_firestore/cloud_firestore.dart';

class GasPriceModel {
  final String id;
  final int year;
  final int month;
  final double pricePerM3;
  final DateTime updatedAt;
  final String updatedBy;

  GasPriceModel({
    required this.id,
    required this.year,
    required this.month,
    required this.pricePerM3,
    required this.updatedAt,
    required this.updatedBy,
  });

  // Tambahkan factory fromFirestore
  factory GasPriceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GasPriceModel(
      id: doc.id,
      year: data['year'] ?? 0,
      month: data['month'] ?? 0,
      pricePerM3: (data['pricePerM3'] ?? 0).toDouble(),
      // Konversi Timestamp Firestore ke DateTime Dart
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      updatedBy: data['updatedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'pricePerM3': pricePerM3,
      // Konversi DateTime Dart ke Timestamp Firestore
      'updatedAt': Timestamp.fromDate(updatedAt),
      'updatedBy': updatedBy,
    };
  }
}
