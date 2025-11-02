class User {
  final int id;
  final String username;
  final String displayName;
  final String role;
  final String? fcmToken;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    this.fcmToken,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      displayName: json['display_name'],
      role: json['role'],
      fcmToken: json['fcm_token'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'role': role,
      'fcm_token': fcmToken,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
