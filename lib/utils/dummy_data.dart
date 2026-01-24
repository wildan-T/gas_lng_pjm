import '../models/user_model.dart';
import '../models/gas_record_model.dart';
import '../models/machine_model.dart';

class DummyData {
  // Dummy Users
  static final users = [
    UserModel(
      uid: 'op1',
      name: 'Operator Budi',
      email: 'operator@pjm.com',
      role: UserRole.operator,
    ),
    UserModel(
      uid: 'spv1',
      name: 'Supervisor Agus',
      email: 'supervisor@pjm.com',
      role: UserRole.supervisor,
    ),
    UserModel(
      uid: 'adm1',
      name: 'Admin Siti',
      email: 'admin@pjm.com',
      role: UserRole.admin,
    ),
    UserModel(
      uid: 'mgmt1',
      name: 'Manager Dewi',
      email: 'manager@pjm.com',
      role: UserRole.management,
    ),
  ];

  // Dummy Machines
  static final machines = [
    MachineModel(id: 'm1', name: 'Burner Maxon A', location: 'Line 1'),
    MachineModel(id: 'm2', name: 'Burner Maxon B', location: 'Line 2'),
    MachineModel(id: 'm3', name: 'Oven Dryer', location: 'Line 3'),
  ];

  // Dummy Gas Records (3 bulan terakhir)
  static List<GasRecord> generateDummyRecords() {
    final records = <GasRecord>[];
    final now = DateTime.now();

    for (int i = 90; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));

      // 2-3 records per day
      for (int j = 0; j < 2; j++) {
        records.add(
          GasRecord(
            id: 'rec_${i}_$j',
            timestamp: date.add(Duration(hours: 8 + j * 6)),
            amount: 100 + (i % 50).toDouble(),
            machineName: machines[j % machines.length].name,
            operatorId: 'op1',
            operatorName: 'Operator Budi',
            isVerified: i > 7, // Last 7 days belum verified
            verifiedBy: i > 7 ? 'spv1' : null,
            verifiedAt: i > 7 ? date.add(Duration(hours: 20)) : null,
          ),
        );
      }
    }

    return records;
  }

  static double currentGasPrice = 15000; // Rp per m³
}
