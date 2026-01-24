import 'package:cloud_firestore/cloud_firestore.dart';

// ==========================================
// 1. FORECAST ORDER (Disimpan di DB)
// ==========================================
class ForecastModel {
  final String id;
  final int year;
  final int month;
  final double forecastProduction;
  final String notes;
  final DateTime createdAt;
  final String createdBy;

  ForecastModel({
    required this.id,
    required this.year,
    required this.month,
    required this.forecastProduction,
    this.notes = '',
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'forecastProduction': forecastProduction,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt), // Gunakan Timestamp
      'createdBy': createdBy,
    };
  }

  factory ForecastModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ForecastModel(
      id: doc.id,
      year: data['year'] ?? 0,
      month: data['month'] ?? 0,
      forecastProduction: (data['forecastProduction'] ?? 0).toDouble(),
      notes: data['notes'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(), // Baca Timestamp
      createdBy: data['createdBy'] ?? '',
    );
  }

  String get periodName {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    // Safety check agar tidak error jika month index salah
    if (month < 1 || month > 12) return '$month $year';
    return '${months[month - 1]} $year';
  }
}

// ==========================================
// 2. SYSTEM SETTINGS (Disimpan di DB)
// ==========================================
class SystemSettings {
  final String id;
  final double gasPricePerM3;
  final double efficiencyThresholdLow;
  final double efficiencyThresholdHigh;
  final DateTime updatedAt;
  final String updatedBy;

  SystemSettings({
    required this.id,
    this.gasPricePerM3 = 15000,
    this.efficiencyThresholdLow = -10,
    this.efficiencyThresholdHigh = 10,
    required this.updatedAt,
    required this.updatedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'gasPricePerM3': gasPricePerM3,
      'efficiencyThresholdLow': efficiencyThresholdLow,
      'efficiencyThresholdHigh': efficiencyThresholdHigh,
      'updatedAt': Timestamp.fromDate(updatedAt), // Gunakan Timestamp
      'updatedBy': updatedBy,
    };
  }

  factory SystemSettings.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SystemSettings(
      id: doc.id,
      gasPricePerM3: (data['gasPricePerM3'] ?? 15000).toDouble(),
      efficiencyThresholdLow: (data['efficiencyThresholdLow'] ?? -10)
          .toDouble(),
      efficiencyThresholdHigh: (data['efficiencyThresholdHigh'] ?? 10)
          .toDouble(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(), // Baca Timestamp
      updatedBy: data['updatedBy'] ?? '',
    );
  }
}

// ==========================================
// 3. GAS ESTIMATION (Hasil Hitungan, biasanya tidak disimpan DB)
// ==========================================
class GasEstimation {
  final int year;
  final int month;
  final double forecastProduction;
  final double historicalAvgGas;
  final double estimatedGas;
  final double estimatedCost;
  final double gasPricePerM3;

  GasEstimation({
    required this.year,
    required this.month,
    required this.forecastProduction,
    required this.historicalAvgGas,
    required this.gasPricePerM3,
  }) : estimatedGas = historicalAvgGas,
       estimatedCost = historicalAvgGas * gasPricePerM3;

  String get periodName {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    if (month < 1 || month > 12) return '$month $year';
    return '${months[month - 1]} $year';
  }
}

// ==========================================
// 4. EFFICIENCY EVALUATION (Hasil Hitungan)
// ==========================================
enum EfficiencyCategory { efficient, normal, wasteful }

class EfficiencyEvaluation {
  final int year;
  final int month;
  final double actualConsumption;
  final double averageHistorical;
  final double deviation;
  final EfficiencyCategory category;
  final double? forecastProduction;
  final double? actualProduction;

  EfficiencyEvaluation({
    required this.year,
    required this.month,
    required this.actualConsumption,
    required this.averageHistorical,
    required double thresholdLow,
    required double thresholdHigh,
    this.forecastProduction,
    this.actualProduction,
  }) : deviation = averageHistorical > 0
           ? ((actualConsumption - averageHistorical) / averageHistorical) * 100
           : 0,
       category = _determineCategory(
         averageHistorical > 0
             ? ((actualConsumption - averageHistorical) / averageHistorical) *
                   100
             : 0,
         thresholdLow,
         thresholdHigh,
       );

  static EfficiencyCategory _determineCategory(
    double deviation,
    double thresholdLow,
    double thresholdHigh,
  ) {
    if (deviation <= thresholdLow) return EfficiencyCategory.efficient;
    if (deviation <= thresholdHigh) return EfficiencyCategory.normal;
    return EfficiencyCategory.wasteful;
  }

  String get categoryLabel {
    switch (category) {
      case EfficiencyCategory.efficient:
        return 'Efisien';
      case EfficiencyCategory.normal:
        return 'Normal';
      case EfficiencyCategory.wasteful:
        return 'Boros';
    }
  }

  String get periodName {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    if (month < 1 || month > 12) return '$month $year';
    return '${months[month - 1]} $year';
  }
}
