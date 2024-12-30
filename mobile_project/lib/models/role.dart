enum Role {
  admin,
  user;

  String toValue() {
    return name; // Directly returns the enum name as a string
  }

  // Convert string to enum
  static Role fromValue(String value) {
    return Role.values
        .firstWhere((e) => e.name == value, orElse: () => Role.user);
  }
}
