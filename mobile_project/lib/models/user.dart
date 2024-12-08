class User {
  final String id;
  String name;
  String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  // Convert JSON to User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
