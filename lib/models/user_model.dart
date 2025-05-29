class UserModel {
  final int id;
  final String username;
  final String email;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['full_name'],
      isVerified: json['is_verified'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': username,
    'is_verified': isVerified,
  };
}
