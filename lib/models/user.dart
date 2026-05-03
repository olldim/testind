class User {
  final int id;
  final String fullName;
  final String group;
  final String login;

  User({
    required this.id,
    required this.fullName,
    required this.group,
    required this.login,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      group: json['group'] as String,
      login: json['login'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'group': group,
      'login': login,
    };
  }
}
