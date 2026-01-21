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
    this.verifiedAt,
    this.photoBase64, // ← NEW
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'amount': amount,
      'machineName': machineName,
      'notes': notes,
      'operatorId': operatorId,
      'operatorName': operatorName,
      'isVerified': isVerified,
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'photoBase64': photoBase64, // ← NEW
    };
  }
}