class Ward {
  const Ward({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    required this.status,
    required this.lastUpdated,
    this.age,
    this.address,
    this.profileImageUrl,
  });

  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final WardStatus status;
  final DateTime lastUpdated;
  final int? age;
  final String? address;
  final String? profileImageUrl;
}

enum WardStatus { normal, warning, emergency, offline }
