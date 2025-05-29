class User {
  final String email;
  final String name;
  final String password;
  final Map<String, dynamic>? settings;

  User({
    required this.email,
    required this.name,
    required this.password,
    this.settings,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'password': password,
    'settings': settings,
  };

  static User fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? safeSettings;
    final raw = json['settings'];
    if (raw != null) {
      if (raw is Map) {
        safeSettings = Map<String, dynamic>.from(raw);
      } else {
        safeSettings = null;
      }
    }
    return User(
      email: json['email'] as String,
      name: json['name'] as String,
      password: json['password'] as String,
      settings: safeSettings,
    );
  }
}
