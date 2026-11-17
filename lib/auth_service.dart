import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn? _googleSignIn = kIsWeb ? null : GoogleSignIn();

  //google sign-in
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        UserCredential userCredential =
            await _auth.signInWithPopup(googleProvider);
        return userCredential.user;
      } else {
        final googleUser = await _googleSignIn!.signIn();
        if (googleUser == null) return null; // user cancelled

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        return (await _auth.signInWithCredential(credential)).user;
      }
    } catch (e) {
      print("Google sign-in error: $e");
      return null;
    }
  }

  //register
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print("Registration error: $e");
      return null;
    }
  }

  //login
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  //forgot pass
  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') return 'That email address is not valid.';
      if (e.code == 'user-not-found') return 'No account found for that email.';
      return e.message ?? 'Something went wrong. Try again.';
    } catch (e) {
      return 'Something went wrong. Try again.';
    }
  }

  //sign out
  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn?.signOut();
    }
    await _auth.signOut();
  }

  Stream<User?> get userStream => _auth.authStateChanges();
}