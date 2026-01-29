import 'package:cloud_firestore/cloud_firestore.dart';

class GasRecord {
  final String id;
  final DateTime timestamp;
  final double amount;
  final String machineName;
  final String? notes;
  final String operatorId;
  final String operatorName;
  final bool isVerified;
  final String? verifiedBy;
  final String? verifiedByName;
  final DateTime? verifiedAt;
  final String? photoBase64; // ← NEW

  GasRecord({
    required this.id,
    required this.timestamp,
    required this.amount, 
    required this.machineName,
    this.notes,
    required this.operatorId,
    required this.operatorName,
    this.isVerified = false,
    this.verifiedBy,
    this.verifiedByName,
    this.verifiedAt,
    this.photoBase64, // ← NEW
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'amount': amount,
      'machineName': machineName,
      'notes': notes,
      'operatorId': operatorId,
      'operatorName': operatorName,
      'isVerified': isVerified,
      'verifiedBy': verifiedBy,
      'verifiedByName': verifiedByName,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'photoBase64': photoBase64, // ← NEW
    };
  }

  // Update method fromMap/fromFirestore
  factory GasRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GasRecord(
      id: doc.id, // Gunakan ID dokumen dari Firebase
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      amount: (data['amount'] ?? 0).toDouble(),
      machineName: data['machineName'] ?? '',
      notes: data['notes'],
      operatorId: data['operatorId'] ?? '',
      operatorName: data['operatorName'] ?? 'Unknown',
      isVerified: data['isVerified'] ?? false,
      verifiedBy: data['verifiedBy'],
      verifiedByName: data['verifiedByName'],
      verifiedAt: data['verifiedAt'] != null
          ? (data['verifiedAt'] as Timestamp).toDate()
          : null,
      photoBase64: data['photoBase64'],
    );
  }
}
