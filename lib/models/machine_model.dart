class Machine {
  final String id;
  final String name;
  final String location;
  final bool isActive;

  Machine({
    required this.id,
    required this.name,
    required this.location,
    this.isActive = true,
  });

  factory Machine.fromFirestore(Map<String, dynamic> data, String id) {
    return Machine(
      id: id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'isActive': isActive,
    };
  }
}