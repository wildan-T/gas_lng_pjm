import 'package:flutter/foundation.dart';

import '../models/gas_record_model.dart';
import '../models/machine_model.dart';
import '../utils/dummy_data.dart';
import '../models/forecast_model.dart';

class DataService with ChangeNotifier {
  // ====================================================
  //                     STORAGE UTAMA
  // ====================================================
  List<GasRecord> _records = [];
  List<MachineModel> _machines = [];

  // ====================================================
  //               FORECASTS & SYSTEM SETTINGS
  // ====================================================
  List<ForecastModel> _forecasts = [];

  SystemSettings _settings = SystemSettings(
    id: 'settings_1',
    gasPricePerM3: 15000,
    efficiencyThresholdLow: -10,
    efficiencyThresholdHigh: 10,
    updatedAt: DateTime.now(),
    updatedBy: 'system',
  );

  // ====================================================
  //                     CONSTRUCTOR
  // ====================================================
  DataService() {
    // Keep machines from DummyData
    _machines = List.from(DummyData.machines);
    // Initialize sample records & forecasts
    initializeSampleData();
  }

  // ====================================================
  //             INITIALIZE SAMPLE DATA
  // ====================================================
  void initializeSampleData() {
    // Clear existing
    _records.clear();
    _forecasts.clear();

    // ========== SAMPLE GAS RECORDS (3 BULAN TERAKHIR) ==========

    // November 2024
    _records.addAll([
      GasRecord(
        id: 'nov_1',
        timestamp: DateTime(2024, 11, 5, 8, 0),
        amount: 297.0,
        machineName: 'Hot Air Oven BGK',
        operatorId: 'op_a',
        operatorName: 'Operator A',
        notes: 'Normal operation',
        isVerified: true,
        verifiedBy: 'Supervisor',
        verifiedAt: DateTime(2024, 11, 5, 16, 0),
      ),
      GasRecord(
        id: 'nov_2',
        timestamp: DateTime(2024, 11, 10, 8, 0),
        amount: 75.0,
        machineName: 'Hot Air Oven ADX',
        operatorId: 'op_b',
        operatorName: 'Operator B',
        notes: 'Normal operation',
        isVerified: true,
        verifiedBy: 'Supervisor',
        verifiedAt: DateTime(2024, 11, 10, 16, 0),
      ),
      GasRecord(
        id: 'nov_3',
        timestamp: DateTime(2024, 11, 15, 8, 0),
        amount: 83.0,
        machineName: 'Hot Air Oven Maxon',
        operatorId: 'op_c',
        operatorName: 'Operator C',
        notes: 'Normal operation',
        isVerified: true,
        verifiedBy: 'Supervisor',
        verifiedAt: DateTime(2024, 11, 15, 16, 0),
      ),
      GasRecord(
        id: 'nov_4',
        timestamp: DateTime(2024, 11, 20, 8, 0),
        amount: 205.0,
        machineName: 'Hot Air Cat TNE',
        operatorId: 'op_a',
        operatorName: 'Operator A',
        notes: 'Normal operation',
        isVerified: true,
        verifiedBy: 'Supervisor',
        verifiedAt: DateTime(2024, 11, 20, 16, 0),
      ),
      GasRecord(
        id: 'nov_5',
        timestamp: DateTime(2024, 11, 25, 8, 0),
        amount: 245.0,
        machineName: 'Hot Air Cat TNE 2',
        operatorId: 'op_b',
        operatorName: 'Operator B',
        notes: 'Normal operation',
        isVerified: true,
        verifiedBy: 'Supervisor',
        verifiedAt: DateTime(2024, 11, 25, 16, 0),
      ),
    ]);

    // December 2024
    _records.addAll([
      GasRecord(
        id: 'dec_1',
        timestamp: DateTime(2024, 12, 5, 8, 0),
        amount: 299.0,
        machineName: 'Hot Air Oven BGK',
        operatorId: 'op_a',
        operatorName: 'Operator A',
        notes: 'Normal operation',
        isVerified: true,
        verifiedBy: 'Supervisor',
        verifiedAt: DateTime(2024, 12, 5, 16, 0),
      ),
      GasRecord(
        id: 'dec_2',
        timestamp: DateTime(2024, 12, 10, 8, 0),
        amount: 84.0,
        machineName: 'Hot Air Oven ADX',
        operatorId: 'op_b',
        operatorName: 'Operator B',
        notes: 'Normal operation',
        isVerified: true,
        verifiedBy: 'Supervisor',
        verifiedAt: DateTime(2024, 12, 10, 16, 0),
      ),
      GasRecord(
        id: 'dec_3',
        timestamp: DateTime(2024, 12, 15, 8, 0),
        amount: 81.0,
        machineName: 'Hot Air Oven Maxon',
        operatorId: 'op_c',
        operatorName: 'Operator C',
        notes: 'Normal operation',
        isVerified: true,
        verifiedBy: 'Supervisor',
        verifiedAt: DateTime(2024, 12, 15, 16, 0),
      ),
      GasRecord(
        id: 'dec_4',
        timestamp: DateTime(2024, 12, 20, 8, 0),
        amount: 251.0,
        machineName: 'Hot Air Cat TNE',
        operatorId: 'op_a',
        operatorName: 'Operator A',
        notes: 'Normal operation',
        isVerified: true,
        verifiedBy: 'Supervisor',
        verifiedAt: DateTime(2024, 12, 20, 16, 0),
      ),
      GasRecord(
        id: 'dec_5',
        timestamp: DateTime(2024, 12, 25, 8, 0),
        amount: 232.0,
        machineName: 'Hot Air Cat TNE 2',
        operatorId: 'op_b',
        operatorName: 'Operator B',
        notes: 'Normal operation',
        isVerified: true,
        verifiedBy: 'Supervisor',
        verifiedAt: DateTime(2024, 12, 25, 16, 0),
      ),
    ]);

    // January 2025
    _records.addAll([
      GasRecord(
        id: 'jan_1',
        timestamp: DateTime(2025, 1, 5, 8, 0),
        amount: 288.0,
        machineName: 'Hot Air Oven BGK',
        operatorId: 'op_a',
        operatorName: 'Operator A',
        notes: 'Normal operation',
        isVerified: true,
        verifiedBy: 'Supervisor',
        verifiedAt: DateTime(2025, 1, 5, 16, 0),
      ),
      GasRecord(
        id: 'jan_2',
        timestamp: DateTime(2025, 1, 10, 8, 0),
        amount: 99.0,
        machineName: 'Hot Air Oven ADX',
        operatorId: 'op_b',
        operatorName: 'Operator B',
        notes: 'Normal operation',
        isVerified: true,
        verifiedBy: 'Supervisor',
        verifiedAt: DateTime(2025, 1, 10, 16, 0),
      ),
      GasRecord(
        id: 'jan_3',
        timestamp: DateTime(2025, 1, 15, 8, 0),
        amount: 93.0,
        machineName: 'Hot Air Oven Maxon',
        operatorId: 'op_c',
        operatorName: 'Operator C',
        notes: 'Normal operation',
        isVerified: true,
        verifiedBy: 'Supervisor',
        verifiedAt: DateTime(2025, 1, 15, 16, 0),
      ),
      GasRecord(
        id: 'jan_4',
        timestamp: DateTime(2025, 1, 20, 8, 0),
        amount: 123.0,
        machineName: 'Hot Air Cat TNE',
        operatorId: 'op_a',
        operatorName: 'Operator A',
        notes: 'Normal operation',
        isVerified: true,
        verifiedBy: 'Supervisor',
        verifiedAt: DateTime(2025, 1, 20, 16, 0),
      ),
      GasRecord(
        id: 'jan_5',
        timestamp: DateTime(2025, 1, 25, 8, 0),
        amount: 274.0,
        machineName: 'Hot Air Cat TNE 2',
        operatorId: 'op_b',
        operatorName: 'Operator B',
        notes: 'Normal operation',
        isVerified: true,
        verifiedBy: 'Supervisor',
        verifiedAt: DateTime(2025, 1, 25, 16, 0),
      ),
    ]);

    // ========== SAMPLE FORECASTS ==========
    _forecasts.addAll([
      ForecastModel(
        id: 'forecast_2025_2',
        year: 2025,
        month: 2,
        forecastProduction: 1800000,
        notes: 'Target produksi Februari 2025',
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        createdBy: 'Supervisor',
      ),
      ForecastModel(
        id: 'forecast_2025_3',
        year: 2025,
        month: 3,
        forecastProduction: 2000000,
        notes: 'Target produksi Maret 2025',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        createdBy: 'Supervisor',
      ),
    ]);

    // Log & notify
    if (kDebugMode) {
      print(
        '✅ Sample data initialized: ${_records.length} records, ${_forecasts.length} forecasts',
      );
    }
    notifyListeners();
  }

  // ====================================================
  //                        GAS RECORDS
  // ====================================================

  Future<void> addGasRecord(GasRecord record) async {
    await Future.delayed(Duration(milliseconds: 500));
    _records.insert(0, record);
    notifyListeners();
  }

  Future<List<GasRecord>> getGasRecords() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List.from(_records);
  }

  Future<List<GasRecord>> getRecordsByOperator(String operatorId) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _records
        .where((r) => r.operatorId == operatorId && !r.isVerified)
        .toList();
  }

  Future<List<GasRecord>> getUnverifiedRecords() async {
    await Future.delayed(Duration(milliseconds: 300));
    return _records.where((r) => !r.isVerified).toList();
  }

  Future<void> verifyRecord(
    String recordId,
    String supervisorId,
    String supervisorName,
  ) async {
    await Future.delayed(Duration(milliseconds: 500));

    final index = _records.indexWhere((r) => r.id == recordId);
    if (index != -1) {
      final old = _records[index];
      _records[index] = GasRecord(
        id: old.id,
        timestamp: old.timestamp,
        amount: old.amount,
        machineName: old.machineName,
        operatorId: old.operatorId,
        operatorName: old.operatorName,
        notes: old.notes,
        isVerified: true,
        verifiedBy: supervisorId,
        verifiedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  Future<void> updateRecord(
    String recordId,
    Map<String, dynamic> updates,
  ) async {
    await Future.delayed(Duration(milliseconds: 500));

    final index = _records.indexWhere((r) => r.id == recordId);
    if (index != -1) {
      final old = _records[index];
      _records[index] = GasRecord(
        id: old.id,
        timestamp: old.timestamp,
        amount: updates['amount'] ?? old.amount,
        machineName: updates['machineName'] ?? old.machineName,
        operatorId: old.operatorId,
        operatorName: old.operatorName,
        notes: updates['notes'] ?? old.notes,
        isVerified: old.isVerified,
        verifiedBy: old.verifiedBy,
        verifiedAt: old.verifiedAt,
      );
      notifyListeners();
    }
  }

  Future<void> deleteRecord(String recordId) async {
    await Future.delayed(Duration(milliseconds: 500));
    _records.removeWhere((r) => r.id == recordId);
    notifyListeners();
  }

  // ====================================================
  //                        MACHINES
  // ====================================================

  Future<List<MachineModel>> getMachines() async {
    await Future.delayed(Duration(milliseconds: 200));
    return List.from(_machines.where((m) => m.isActive));
  }

  Future<void> addMachine(MachineModel machine) async {
    await Future.delayed(Duration(milliseconds: 500));
    _machines.add(machine);
    notifyListeners();
  }

  Future<void> updateMachine(String id, MachineModel machine) async {
    await Future.delayed(Duration(milliseconds: 500));
    final index = _machines.indexWhere((m) => m.id == id);
    if (index != -1) {
      _machines[index] = machine;
      notifyListeners();
    }
  }

  Future<void> deleteMachine(String id) async {
    await Future.delayed(Duration(milliseconds: 500));
    final index = _machines.indexWhere((m) => m.id == id);
    if (index != -1) {
      _machines[index] = MachineModel(
        id: _machines[index].id,
        name: _machines[index].name,
        location: _machines[index].location,
        isActive: false,
      );
      notifyListeners();
    }
  }

  // ====================================================
  //                     MONTHLY SUMMARY
  // ====================================================

  Future<Map<String, dynamic>> getMonthlySummary(int year, int month) async {
    await Future.delayed(Duration(milliseconds: 500));

    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final filtered = _records
        .where(
          (r) =>
              r.timestamp.isAfter(startDate) &&
              r.timestamp.isBefore(endDate) &&
              r.isVerified,
        )
        .toList();

    double totalConsumption = 0;
    final machineConsumption = <String, double>{};
    final dailyConsumption = <int, double>{};

    for (var record in filtered) {
      totalConsumption += record.amount;

      machineConsumption[record.machineName] =
          (machineConsumption[record.machineName] ?? 0) + record.amount;

      final day = record.timestamp.day;
      dailyConsumption[day] = (dailyConsumption[day] ?? 0) + record.amount;
    }

    final totalCost = totalConsumption * _settings.gasPricePerM3;

    return {
      'totalConsumption': totalConsumption,
      'totalCost': totalCost,
      'avgDaily': totalConsumption / endDate.day,
      'machineConsumption': machineConsumption,
      'dailyConsumption': dailyConsumption,
      'recordCount': filtered.length,
      'pricePerM3': _settings.gasPricePerM3,
    };
  }

  // ====================================================
  //                  FORECAST MANAGEMENT
  // ====================================================

  Future<List<ForecastModel>> getForecasts() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List.from(_forecasts)..sort((a, b) {
      if (a.year != b.year) return b.year.compareTo(a.year);
      return b.month.compareTo(a.month);
    });
  }

  Future<ForecastModel?> getForecast(int year, int month) async {
    await Future.delayed(Duration(milliseconds: 300));
    try {
      return _forecasts.firstWhere((f) => f.year == year && f.month == month);
    } catch (e) {
      return null;
    }
  }

  Future<void> addOrUpdateForecast(ForecastModel forecast) async {
    await Future.delayed(Duration(milliseconds: 500));

    _forecasts.removeWhere(
      (f) => f.year == forecast.year && f.month == forecast.month,
    );

    _forecasts.add(forecast);

    notifyListeners();
  }

  Future<void> deleteForecast(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    _forecasts.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  // ====================================================
  //                    SYSTEM SETTINGS
  // ====================================================

  Future<SystemSettings> getSystemSettings() async {
    await Future.delayed(Duration(milliseconds: 300));
    return _settings;
  }

  Future<void> updateSystemSettings(SystemSettings settings) async {
    await Future.delayed(Duration(milliseconds: 500));
    _settings = settings;
    notifyListeners();
  }

  // ====================================================
  //                   GAS ESTIMATION
  // ====================================================

  Future<GasEstimation?> getGasEstimation(int year, int month) async {
    await Future.delayed(Duration(milliseconds: 500));

    final forecast = await getForecast(year, month);
    if (forecast == null) return null;

    final now = DateTime.now();
    final threeMonthsAgo = DateTime(now.year, now.month - 3, 1);

    double totalGas = 0;
    int monthCount = 0;

    for (var record in _records) {
      if (record.isVerified && record.timestamp.isAfter(threeMonthsAgo)) {
        totalGas += record.amount;
        monthCount++;
      }
    }

    final avgGas = monthCount > 0 ? totalGas / 3 : 2200.0;

    return GasEstimation(
      year: year,
      month: month,
      forecastProduction: forecast.forecastProduction,
      historicalAvgGas: avgGas,
      gasPricePerM3: _settings.gasPricePerM3,
    );
  }

  // ====================================================
  //                EFFICIENCY EVALUATION
  // ====================================================

  Future<EfficiencyEvaluation?> getEfficiencyEvaluation(
    int year,
    int month,
  ) async {
    await Future.delayed(Duration(milliseconds: 500));

    final summary = await getMonthlySummary(year, month);
    final actualConsumption = (summary['totalConsumption'] ?? 0.0) as double;

    if (actualConsumption == 0) return null;

    final currentPeriod = DateTime(year, month);
    double totalGas = 0;
    int monthCount = 0;

    Map<String, double> monthlyData = {};
    for (var record in _records) {
      if (!record.isVerified) continue;

      final recordMonth = DateTime(
        record.timestamp.year,
        record.timestamp.month,
      );

      if (recordMonth == currentPeriod) continue;

      final key = '${record.timestamp.year}-${record.timestamp.month}';
      monthlyData[key] = (monthlyData[key] ?? 0) + record.amount;
    }

    if (monthlyData.isNotEmpty) {
      totalGas = monthlyData.values.reduce((a, b) => a + b);
      monthCount = monthlyData.length;
    }

    final avgHistorical = monthCount > 0 ? totalGas / monthCount : 2200.0;

    final forecast = await getForecast(year, month);

    return EfficiencyEvaluation(
      year: year,
      month: month,
      actualConsumption: actualConsumption,
      averageHistorical: avgHistorical,
      thresholdLow: _settings.efficiencyThresholdLow,
      thresholdHigh: _settings.efficiencyThresholdHigh,
      forecastProduction: forecast?.forecastProduction,
    );
  }

  Future<List<EfficiencyEvaluation>> getEfficiencyHistory({
    int limit = 12,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));

    List<EfficiencyEvaluation> history = [];

    Map<String, double> monthlyConsumption = {};
    for (var record in _records) {
      if (!record.isVerified) continue;

      final key = '${record.timestamp.year}-${record.timestamp.month}';
      monthlyConsumption[key] = (monthlyConsumption[key] ?? 0) + record.amount;
    }

    Set<String> periods = monthlyConsumption.keys.toSet();

    for (var periodKey in periods) {
      final parts = periodKey.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      final eval = await getEfficiencyEvaluation(year, month);
      if (eval != null) history.add(eval);
    }

    history.sort((a, b) {
      if (a.year != b.year) return b.year.compareTo(a.year);
      return b.month.compareTo(a.month);
    });

    return history.take(limit).toList();
  }
}
