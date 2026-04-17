class GuardianModel {
  final int id;
  final String name;
  final String phone;
  final bool isPrimary;
  final String relation;

  const GuardianModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.isPrimary,
    required this.relation,
  });

  factory GuardianModel.fromJson(Map<String, dynamic> json) => GuardianModel(
        id: json['id'] as int,
        name: json['name'] as String,
        phone: json['phone'] as String,
        isPrimary: json['isPrimary'] as bool,
        relation: json['relation'] as String,
      );
}
