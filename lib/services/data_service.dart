import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gas_lng_pjm/models/user_model.dart';

// Import Models
import '../models/gas_record_model.dart';
import '../models/machine_model.dart';
import '../models/gas_price_model.dart';
import '../models/forecast_model.dart'; // Isinya: ForecastModel, SystemSettings, EfficiencyEvaluation

class DataService with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================
  // COLLECTION REFERENCES
  // ==========================================
  CollectionReference get _recordsRef => _db.collection('gas_records');
  CollectionReference get _machinesRef => _db.collection('machines');
  CollectionReference get _settingsRef => _db.collection('settings');
  CollectionReference get _forecastsRef => _db.collection('forecasts');

  // ==========================================
  // 1. GAS RECORDS (Operator & Umum)
  // ==========================================

  // Create
  Future<void> addGasRecord(GasRecord record) async {
    try {
      await _recordsRef.add(record.toMap());
      notifyListeners();
    } catch (e) {
      print('Error adding record: $e');
      rethrow;
    }
  }

  // Read All (General History)
  Future<List<GasRecord>> getGasRecords() async {
    try {
      QuerySnapshot snapshot = await _recordsRef
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) => GasRecord.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting records: $e');
      return [];
    }
  }

  // Read by Operator (Untuk History Screen Operator)
  Future<List<GasRecord>> getRecordsByOperator(String operatorId) async {
    try {
      // Note: Pastikan membuat composite index di Firebase Console jika diminta
      QuerySnapshot snapshot = await _recordsRef
          .where('operatorId', isEqualTo: operatorId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => GasRecord.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting operator records: $e');
      return [];
    }
  }

  // Read Unverified (Untuk Supervisor Verification)
  Future<List<GasRecord>> getUnverifiedRecords() async {
    try {
      QuerySnapshot snapshot = await _recordsRef
          .where('isVerified', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) => GasRecord.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting unverified records: $e');
      return [];
    }
  }

  // Update Verification
  Future<void> verifyRecord(
    String recordId,
    String supervisorId,
    String supervisorName,
  ) async {
    try {
      await _recordsRef.doc(recordId).update({
        'isVerified': true,
        'verifiedBy': supervisorId,
        'verifiedAt': Timestamp.now(),
      });
      notifyListeners();
    } catch (e) {
      print('Error verifying: $e');
      rethrow;
    }
  }

  // Delete
  Future<void> deleteRecord(String recordId) async {
    await _recordsRef.doc(recordId).delete();
    notifyListeners();
  }

  // ==========================================
  // 2. MACHINES (Admin)
  // ==========================================

  Future<List<MachineModel>> getMachines() async {
    try {
      QuerySnapshot snapshot = await _machinesRef.get();
      return snapshot.docs
          .map((doc) => MachineModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting machines: $e');
      return [];
    }
  }

  Future<void> addMachine(MachineModel machine) async {
    await _machinesRef.add(machine.toMap());
    notifyListeners();
  }

  Future<void> updateMachine(MachineModel machine) async {
    await _machinesRef.doc(machine.id).update(machine.toMap());
    notifyListeners();
  }

  Future<void> deleteMachine(MachineModel machine) async {
    try {
      await _machinesRef.doc(machine.id).delete();
      notifyListeners();
    } catch (e) {
      print('Error deleting record: $e');
      rethrow;
    }
  }

  // ==========================================
  // 3. SETTINGS & PRICE (Admin)
  // ==========================================

  // Harga Gas (GasPrice)
  Future<GasPriceModel?> getCurrentGasPrice() async {
    try {
      DocumentSnapshot doc = await _settingsRef.doc('current_price').get();
      if (doc.exists) return GasPriceModel.fromFirestore(doc);
      return null;
    } catch (e) {
      print('Error fetching gas price: $e');
      return null;
    }
  }

  Future<void> updateGasPrice(double price, String userId) async {
    final now = DateTime.now();
    final gasPrice = GasPriceModel(
      id: 'current_price',
      year: now.year,
      month: now.month,
      pricePerM3: price,
      updatedAt: now,
      updatedBy: userId,
    );
    await _settingsRef
        .doc('current_price')
        .set(gasPrice.toMap(), SetOptions(merge: true));
    notifyListeners();
  }

  // System Settings (Efficiency Thresholds, etc.)
  Future<SystemSettings?> getSystemSettings() async {
    try {
      DocumentSnapshot doc = await _settingsRef.doc('system_config').get();
      if (doc.exists) {
        return SystemSettings.fromFirestore(doc);
      }
      // Return default jika belum ada di DB
      return SystemSettings(
        id: 'system_config',
        updatedAt: DateTime.now(),
        updatedBy: 'system',
      );
    } catch (e) {
      print('Error fetching system settings: $e');
      return null;
    }
  }

  Future<void> updateSystemSettings(SystemSettings settings) async {
    try {
      await _settingsRef
          .doc('system_config')
          .set(settings.toMap(), SetOptions(merge: true));
      notifyListeners();
    } catch (e) {
      print('Error updating system settings: $e');
      rethrow;
    }
  }

  // ==========================================
  // 4. FORECAST (Supervisor)
  // ==========================================

  // Method untuk mengambil 1 forecast spesifik (digunakan di ForecastInputScreen)
  Future<ForecastModel?> getForecast(int year, int month) async {
    try {
      QuerySnapshot snapshot = await _forecastsRef
          .where('year', isEqualTo: year)
          .where('month', isEqualTo: month)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return ForecastModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting single forecast: $e');
      return null;
    }
  }

  // Digunakan untuk Input/Edit Forecast
  Future<void> addOrUpdateForecast(ForecastModel forecast) async {
    try {
      // Cek apakah sudah ada forecast untuk bulan & tahun ini?
      QuerySnapshot existing = await _forecastsRef
          .where('year', isEqualTo: forecast.year)
          .where('month', isEqualTo: forecast.month)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        // Update existing
        await _forecastsRef
            .doc(existing.docs.first.id)
            .update(forecast.toMap());
      } else {
        // Create new
        await _forecastsRef.add(forecast.toMap());
      }
      notifyListeners();
    } catch (e) {
      print('Error saving forecast: $e');
      rethrow;
    }
  }

  // ==========================================
  // 5. BUSINESS LOGIC / ANALYTICS (Supervisor & Management)
  // ==========================================

  // Dashboard Summary (Management Dashboard)
  Future<Map<String, dynamic>> getSummary() async {
    // Logic: Ambil data bulan ini
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);

    QuerySnapshot snapshot = await _recordsRef
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .get();

    List<GasRecord> records = snapshot.docs
        .map((doc) => GasRecord.fromFirestore(doc))
        .toList();

    double totalUsage = records.fold(0, (sum, item) => sum + item.amount);

    // Ambil harga gas
    GasPriceModel? price = await getCurrentGasPrice();
    double currentPrice = price?.pricePerM3 ?? 0;

    return {
      'totalUsage': totalUsage,
      'totalCost': totalUsage * currentPrice,
      'recordCount': records.length,
      'lastUpdate': DateTime.now(), // Mocked for now
    };
  }

  // Monthly Summary (Export Report)
  Future<Map<String, dynamic>> getMonthlySummary(int month, int year) async {
    DateTime start = DateTime(year, month, 1);
    DateTime end = DateTime(year, month + 1, 0, 23, 59, 59); // Akhir bulan

    QuerySnapshot snapshot = await _recordsRef
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    List<GasRecord> records = snapshot.docs
        .map((doc) => GasRecord.fromFirestore(doc))
        .toList();
    double totalUsage = records.fold(0, (sum, item) => sum + item.amount);

    return {
      'month': month,
      'year': year,
      'totalUsage': totalUsage,
      'records': records,
    };
  }

  // Gas Estimation (Supervisor)
  Future<GasEstimation?> getGasEstimation(int month, int year) async {
    // 1. Ambil Forecast Produksi
    QuerySnapshot forecastSnap = await _forecastsRef
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .limit(1)
        .get();

    if (forecastSnap.docs.isEmpty) return null; // Tidak ada forecast

    ForecastModel forecast = ForecastModel.fromFirestore(
      forecastSnap.docs.first,
    );

    // 2. Ambil Harga Gas
    GasPriceModel? priceObj = await getCurrentGasPrice();
    double price = priceObj?.pricePerM3 ?? 15000;

    // 3. Hitung Historical Average (Sederhana: ambil rata-rata 3 bulan terakhir)
    // Disini kita mock logika historical sederhananya
    // (Idealnya query DB bulan lalu, 2 bulan lalu, dst)
    double historicalAvg = 12000.0; // Dummy value jika data kurang

    return GasEstimation(
      year: year,
      month: month,
      forecastProduction: forecast.forecastProduction,
      historicalAvgGas: historicalAvg,
      gasPricePerM3: price,
    );
  }

  // Efficiency Evaluation (Supervisor)
  Future<EfficiencyEvaluation?> getEfficiencyEvaluation(
    int month,
    int year,
  ) async {
    // 1. Ambil Total Penggunaan Aktual Bulan Ini
    var summary = await getMonthlySummary(month, year);
    double actualUsage = summary['totalUsage'];

    // 2. Ambil Settings (Thresholds)
    SystemSettings? settings = await getSystemSettings();
    double low = settings?.efficiencyThresholdLow ?? -10;
    double high = settings?.efficiencyThresholdHigh ?? 10;

    // 3. Ambil Forecast (Sebagai pembanding / target)
    // Asumsi: Target gas = Forecast Produksi * Standar Gas per Unit (misal)
    // Disini kita gunakan logika sederhana: Bandingkan Actual vs Rata-rata Historis
    double historicalAvg = 10000.0; // Dummy baseline

    return EfficiencyEvaluation(
      year: year,
      month: month,
      actualConsumption: actualUsage,
      averageHistorical: historicalAvg,
      thresholdLow: low,
      thresholdHigh: high,
    );
  }

  // History Efficiency (Grafik)
  Future<List<EfficiencyEvaluation>> getEfficiencyHistory({
    int limit = 12,
  }) async {
    // Return data dummy atau query real 6 bulan terakhir
    // Ini contoh return kosong agar tidak error, logika sama dengan getEfficiencyEvaluation loop
    return [];
  }

  // ==========================================
  // 6. USER MANAGEMENT (Admin)
  // ==========================================

  // Ambil semua user
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _db.collection('users').get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  // Update data user (Role & Status)
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).update(user.toMap());
      notifyListeners();
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }
}
