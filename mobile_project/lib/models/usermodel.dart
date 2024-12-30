import 'package:mobile_project/utils/formatters/formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/models/role.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  String firstName;
  String lastName;
  String phoneNumber;
  String profilePicture;
  Role role;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.profilePicture,
    required this.role,
  });

  String get fullName => '$firstName $lastName';

  String get formattedPhoneNumber => TFormatter.formatPhoneNumber(phoneNumber);

  static List<String> nameParts(String fullName) => fullName.split(" ");

  static String generateUsername(String fullName) {
    List<String> nameParts = fullName.split(" ");
    String firstName = nameParts[0].toLowerCase();
    String lastName = nameParts.length > 1 ? nameParts[1].toLowerCase() : "";

    String camelCaseUsername = "$firstName$lastName";
    String usernameWithPrefix = "cwt_$camelCaseUsername";
    return usernameWithPrefix;
  }

  // Static function to create an empty user model.
  static UserModel empty() => UserModel(
        id: "",
        firstName: "",
        lastName: "",
        username: "",
        email: "",
        phoneNumber: "",
        profilePicture: "",
        role: Role.user,
      );

  // Convert model to JSON structure for storing data in Firebase.
  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'Username': username,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'ProfilePicture': profilePicture,
      'Role': role.toValue(), // Convert enum to string
    };
  }

  // Factory method to create a UserModel from a Firebase document snapshot.
  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return UserModel(
      id: document.id,
      firstName: data['FirstName'] ?? "",
      lastName: data['LastName'] ?? "",
      username: data['Username'] ?? "",
      email: data['Email'] ?? "",
      phoneNumber: data['PhoneNumber'] ?? "",
      profilePicture: data['ProfilePicture'] ?? "",
      role: Role.fromValue(data['Role'] ?? "user"), // Convert string to enum
    );
  }

  // Factory method to create a UserModel from a map
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      firstName: map['FirstName'] ?? "",
      lastName: map['LastName'] ?? "",
      username: map['Username'] ?? "",
      email: map['Email'] ?? "",
      phoneNumber: map['PhoneNumber'] ?? "",
      profilePicture: map['ProfilePicture'] ?? "",
      role: Role.fromValue(map['Role'] ?? "user"), // Convert string to enum
    );
  }

  // Convert UserModel to a map for easier handling
  Map<String, dynamic> toMap() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'Username': username,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'ProfilePicture': profilePicture,
      'Role': role.toValue(), // Convert enum to string
    };
  }
}
