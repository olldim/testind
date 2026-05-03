bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final normalized = value.toLowerCase();
    return normalized == '1' || normalized == 'true' || normalized == 'yes';
  }
  return false;
}

class User {
  final int id;
  final String fullName;
  final String group;
  final String login;
  final bool isAdmin;

  User({
    required this.id,
    required this.fullName,
    required this.group,
    required this.login,
    required this.isAdmin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      group: json['group'] as String,
      login: json['login'] as String,
      isAdmin: _parseBool(json['is_admin']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'group': group,
      'login': login,
      'is_admin': isAdmin,
    };
  }
}
