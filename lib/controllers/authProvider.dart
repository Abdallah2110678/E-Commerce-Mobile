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
    data: (user) => user?.uid,
    loading: () => null,
    error: (error, stack) => null,
  );
});