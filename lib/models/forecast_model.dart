class ForecastOrder {
  final String id;
  final int year;
  final int month;
  final double forecastProduction; // Forecast produksi (Pcs)
  final String notes;
  final DateTime createdAt;
  final String createdBy;

  ForecastOrder({
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
      'id': id,
      'year': year,
      'month': month,
      'forecastProduction': forecastProduction,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory ForecastOrder.fromMap(Map<String, dynamic> map, String id) {
    return ForecastOrder(
      id: id,
      year: map['year'],
      month: map['month'],
      forecastProduction: (map['forecastProduction'] ?? 0).toDouble(),
      notes: map['notes'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      createdBy: map['createdBy'] ?? '',
    );
  }

  String get periodName {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[month - 1]} $year';
  }
}

class SystemSettings {
  final String id;
  final double gasPricePerM3; // Harga gas per m³
  final double efficiencyThresholdLow; // Threshold efisien (%)
  final double efficiencyThresholdHigh; // Threshold boros (%)
  final DateTime updatedAt;
  final String updatedBy;

  SystemSettings({
    required this.id,
    this.gasPricePerM3 = 15000, // Default Rp 15,000/m³
    this.efficiencyThresholdLow = -10, // < -10% = Efisien
    this.efficiencyThresholdHigh = 10, // > +10% = Boros
    required this.updatedAt,
    required this.updatedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'gasPricePerM3': gasPricePerM3,
      'efficiencyThresholdLow': efficiencyThresholdLow,
      'efficiencyThresholdHigh': efficiencyThresholdHigh,
      'updatedAt': updatedAt.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  factory SystemSettings.fromMap(Map<String, dynamic> map, String id) {
    return SystemSettings(
      id: id,
      gasPricePerM3: (map['gasPricePerM3'] ?? 15000).toDouble(),
      efficiencyThresholdLow: (map['efficiencyThresholdLow'] ?? -10).toDouble(),
      efficiencyThresholdHigh: (map['efficiencyThresholdHigh'] ?? 10).toDouble(),
      updatedAt: DateTime.parse(map['updatedAt']),
      updatedBy: map['updatedBy'] ?? '',
    );
  }
}

class GasEstimation {
  final int year;
  final int month;
  final double forecastProduction; // Forecast produksi (Pcs)
  final double historicalAvgGas; // Rata-rata gas historis (m³)
  final double estimatedGas; // Estimasi kebutuhan gas (m³)
  final double estimatedCost; // Estimasi biaya
  final double gasPricePerM3;

  GasEstimation({
    required this.year,
    required this.month,
    required this.forecastProduction,
    required this.historicalAvgGas,
    required this.gasPricePerM3,
  })  : estimatedGas = historicalAvgGas, // Simplified: pakai rata-rata historis
        estimatedCost = historicalAvgGas * gasPricePerM3;

  String get periodName {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[month - 1]} $year';
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'forecastProduction': forecastProduction,
      'historicalAvgGas': historicalAvgGas,
      'estimatedGas': estimatedGas,
      'estimatedCost': estimatedCost,
      'gasPricePerM3': gasPricePerM3,
    };
  }
}

class EfficiencyEvaluation {
  final int year;
  final int month;
  final double actualConsumption; // Konsumsi aktual (m³)
  final double averageHistorical; // Rata-rata historis (m³)
  final double deviation; // Deviasi (%)
  final EfficiencyCategory category;
  final double? forecastProduction; // Optional: forecast produksi
  final double? actualProduction; // Optional: produksi aktual

  EfficiencyEvaluation({
    required this.year,
    required this.month,
    required this.actualConsumption,
    required this.averageHistorical,
    required double thresholdLow, // dari SystemSettings
    required double thresholdHigh, // dari SystemSettings
    this.forecastProduction,
    this.actualProduction,
  })  : deviation = averageHistorical > 0
            ? ((actualConsumption - averageHistorical) / averageHistorical) * 100
            : 0,
        category = _determineCategory(
          averageHistorical > 0
              ? ((actualConsumption - averageHistorical) / averageHistorical) * 100
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
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[month - 1]} $year';
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'actualConsumption': actualConsumption,
      'averageHistorical': averageHistorical,
      'deviation': deviation,
      'category': category.toString().split('.').last,
      'forecastProduction': forecastProduction,
      'actualProduction': actualProduction,
    };
  }
}

enum EfficiencyCategory {
  efficient, // Efisien
  normal,    // Normal
  wasteful   // Boros
}