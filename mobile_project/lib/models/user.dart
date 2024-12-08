// class User {
//   String? firstName;
//   String? lastName;
//   String? username;
//   String? email;
//   String? phoneNo;
//   String? password;
//   bool termsAccepted = false;

//   // Validation methods
//   String? validateName(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'This field is required';
//     }
//     return null;
//   }

//   String? validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Email is required';
//     } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//       return 'Enter a valid email';
//     }
//     return null;
//   }

//   String? validatePhone(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Phone number is required';
//     } else if (!RegExp(r'^\d{10,15}\$').hasMatch(value)) {
//       return 'Enter a valid phone number';
//     }
//     return null;
//   }

//   String? validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password is required';
//     } else if (value.length < 6) {
//       return 'Password must be at least 6 characters';
//     }
//     return null;
//   }

//   bool validateTermsAccepted() {
//     return termsAccepted;
//   }
// }
