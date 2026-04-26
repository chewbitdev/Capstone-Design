class UserProfileModel {
  final int id;
  final String name;
  final String status;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.status,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        id: json['id'] as int,
        name: json['name'] as String,
        status: json['status'] as String,
      );
}
