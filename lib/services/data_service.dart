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
          .where('isVerified', isEqualTo: false)
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
        'verifiedByName': supervisorName,
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
  // Update: Menerima parameter bulan & tahun
  Future<Map<String, dynamic>> getSummary({int? month, int? year}) async {
    try {
      DateTime now = DateTime.now();
      int targetMonth = month ?? now.month;
      int targetYear = year ?? now.year;

      // Tentukan range tanggal awal & akhir bulan
      DateTime start = DateTime(targetYear, targetMonth, 1);
      DateTime end = DateTime(targetYear, targetMonth + 1, 0, 23, 59, 59);

      QuerySnapshot snapshot = await _recordsRef
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      List<GasRecord> records = snapshot.docs
          .map((doc) => GasRecord.fromFirestore(doc))
          .toList();

      double totalUsage = 0;
      Map<int, double> dailyConsumption = {};
      Map<String, double> machineConsumption = {};

      for (var record in records) {
        totalUsage += record.amount;

        // Grouping per Hari (1-31)
        int day = record.timestamp.day;
        dailyConsumption[day] = (dailyConsumption[day] ?? 0) + record.amount;

        // Grouping per Mesin
        String machine = record.machineName;
        machineConsumption[machine] =
            (machineConsumption[machine] ?? 0) + record.amount;
      }

      // Hitung Rata-rata Harian (berdasarkan hari yang ada datanya)
      double avgDaily = dailyConsumption.isNotEmpty
          ? totalUsage / dailyConsumption.length
          : 0;

      // Ambil harga gas saat ini
      GasPriceModel? price = await getCurrentGasPrice();
      double currentPrice = price?.pricePerM3 ?? 0;

      return {
        'totalConsumption': totalUsage, // Sesuai key di UI
        'totalCost': totalUsage * currentPrice,
        'avgDaily': avgDaily,
        'recordCount': records.length,
        'dailyConsumption':
            dailyConsumption, // Map<int, double> untuk Grafik Garis
        'machineConsumption':
            machineConsumption, // Map<String, double> untuk Grafik Batang
      };
    } catch (e) {
      print('Error generating summary: $e');
      return {
        'totalConsumption': 0.0,
        'totalCost': 0.0,
        'avgDaily': 0.0,
        'recordCount': 0,
        'dailyConsumption': <int, double>{},
        'machineConsumption': <String, double>{},
      };
    }
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

    // --- MULAI PERBAIKAN LOGIKA HITUNG ---
    double totalUsage = 0;
    Map<String, double> machineConsumption =
        {}; // Definisikan tipe data eksplisit

    for (var record in records) {
      totalUsage += record.amount;

      // Hitung per mesin
      String machine = record.machineName;
      machineConsumption[machine] =
          (machineConsumption[machine] ?? 0) + record.amount;
    }

    // Hitung rata-rata harian (opsional, untuk export PDF agar tidak 0)
    // Menggunakan jumlah hari dalam bulan tersebut atau jumlah hari yang ada datanya
    int daysInMonth = DateTime(year, month + 1, 0).day;
    double avgDaily = totalUsage / daysInMonth;

    // Ambil harga (opsional untuk export)
    GasPriceModel? priceObj = await getCurrentGasPrice();
    double pricePerM3 = priceObj?.pricePerM3 ?? 0;
    double totalCost = totalUsage * pricePerM3;
    // --- SELESAI PERBAIKAN ---

    return {
      'month': month,
      'year': year,
      'totalConsumption':
          totalUsage, // Samakan key dengan yang diminta ExportService
      'totalCost': totalCost, // Tambahkan ini
      'avgDaily': avgDaily, // Tambahkan ini
      'pricePerM3': pricePerM3, // Tambahkan ini
      'recordCount': records.length, // Tambahkan ini
      'records': records,
      'machineConsumption': machineConsumption, // <--- INI YANG PALING PENTING
    };
  }

  // Gas Estimation (Supervisor)
  Future<GasEstimation?> getGasEstimation(int month, int year) async {
    // 1. Ambil Forecast Produksi
    print("DEBUG: Mencari Forecast untuk Bulan: $month, Tahun: $year");

    QuerySnapshot forecastSnap = await _forecastsRef
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .limit(1)
        .get();

    print("DEBUG: Ditemukan ${forecastSnap.docs.length} dokumen");

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
    // Gunakan 'totalConsumption' (sesuai update Export) atau 0.0 jika null
    double actualUsage = (summary['totalConsumption'] ?? 0.0) as double;

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

  // History Efficiency (Grafik & List Riwayat)
  Future<List<EfficiencyEvaluation>> getEfficiencyHistory({
    int limit = 12,
  }) async {
    List<EfficiencyEvaluation> history = [];
    DateTime now = DateTime.now();

    try {
      // Loop mundur dari bulan lalu sebanyak 'limit' kali
      for (int i = 1; i <= limit; i++) {
        DateTime targetDate = DateTime(now.year, now.month - i);

        // Panggil evaluasi untuk bulan tersebut
        EfficiencyEvaluation? eval = await getEfficiencyEvaluation(
          targetDate.month,
          targetDate.year,
        );

        // Hanya tambahkan jika ada datanya (actualConsumption > 0)
        if (eval != null && eval.actualConsumption > 0) {
          history.add(eval);
        }
      }
      return history;
    } catch (e) {
      print("Error getting history: $e");
      return [];
    }
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
