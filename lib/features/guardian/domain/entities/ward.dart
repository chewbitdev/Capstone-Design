class Ward {
  const Ward({
    required this.id,
    required this.name,
    required this.age,
    required this.phoneNumber,
    this.address,
    this.profileImageUrl,
    required this.status,
    required this.lastUpdated,
  });

  final String id;
  final String name;
  final int age;
  final String phoneNumber;
  final String? address;
  final String? profileImageUrl;
  final WardStatus status;
  final DateTime lastUpdated;
}

enum WardStatus { normal, warning, emergency, offline }
