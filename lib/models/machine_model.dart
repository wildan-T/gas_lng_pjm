import 'package:cloud_firestore/cloud_firestore.dart';

class MachineModel {
  final String id;
  final String name;
  final String location;
  final bool isActive;

  MachineModel({
    required this.id,
    required this.name,
    required this.location,
    this.isActive = true,
  });

  // Update: Menerima DocumentSnapshot agar konsisten dengan model lain
  factory MachineModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MachineModel(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'location': location, 'isActive': isActive};
  }
}
