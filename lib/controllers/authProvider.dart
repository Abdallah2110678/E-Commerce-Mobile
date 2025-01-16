import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Provider for Firebase Auth user stream
final authProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Provider for the user ID
final userIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.when(
    data: (user) => user?.uid, // Return the user ID if the user is authenticated
    loading: () => null, // Return null while loading
    error: (error, stack) => null, // Return null if there's an error
  );
});