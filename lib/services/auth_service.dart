
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'firestore_service.dart';
import 'supabase_service.dart';
import '../core/config/api_keys.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: ApiKeys.googleServerClientId,
  );

  firebase.User? get currentUser => _auth.currentUser;

  // Memoized stream to avoid StreamBuilder resets on redraw
  late final Stream<firebase.User?> authStateChanges = _auth.authStateChanges();

  bool get isSupabaseSyncActive => 
    supabase.Supabase.instance.client.auth.currentSession != null;

  /// Initiates the Google Sign-In flow.
  ///
  /// After a successful Firebase sign-in we immediately establish a Supabase
  /// session using the SAME Google ID token.  This links both backends to the
  /// same verified Google identity so that Supabase RLS policies backed by
  /// `auth.uid()` are properly enforced — no trust-the-app workaround needed.
  Future<firebase.UserCredential?> signInWithGoogle() async {
    try {
      // 1. Prompt the user to select a Google account (with a generous timeout)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn().timeout(
        const Duration(seconds: 45),
        onTimeout: () => throw TimeoutException('Google Sign-In timed out. Please check your connection.'),
      );
      
      if (googleUser == null) {
        debugPrint('[AuthService] User cancelled Google Sign-In.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 2. Sign into Firebase with the Google credential
      final firebase.OAuthCredential credential = firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final firebase.UserCredential result = await _auth.signInWithCredential(credential);

      // 3. Establish Supabase session (CRITICAL for RLS)
      if (result.user != null && googleAuth.idToken != null) {
        try {
          await supabase.Supabase.instance.client.auth.signInWithIdToken(
            provider: supabase.OAuthProvider.google,
            idToken: googleAuth.idToken!,
            accessToken: googleAuth.accessToken,
          ).timeout(const Duration(seconds: 15));
          debugPrint('[AuthService] Supabase session established.');
        } catch (e) {
          debugPrint('[AuthService] Supabase sign-in failed (non-fatal): $e');
        }

        // 4. Fire-and-Forget Background Syncs (NON-CRITICAL for initial UI)
        // Kicking these off without 'await' to optimize login speed.
        _backgroundProfileSync(result.user!);
      }

      return result;
    } on firebase.FirebaseAuthException catch (e) {
      debugPrint('[AuthService] Firebase Auth Error: [${e.code}] ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[AuthService] Unexpected sign-in error: $e');
      rethrow;
    }
  }

  /// Private helper for non-blocking profile synchronization.
  void _backgroundProfileSync(firebase.User user) {
    debugPrint('[AuthService] Initiating background profile sync...');
    
    // Firestore Profile Init
    FirestoreService().initializeUserProfile(user).then((_) {
      debugPrint('[AuthService] Firestore profile initialized.');
    }).catchError((e) {
      debugPrint('[AuthService] Firestore profile init background error: $e');
    });

    // Supabase Profile Sync
    SupabaseService().syncUserProfile(
      firebaseUid: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
    ).then((_) {
      debugPrint('[AuthService] Supabase profile synced.');
    }).catchError((e) {
      debugPrint('[AuthService] Supabase profile sync background error: $e');
    });
  }

  /// Signs out from both Firebase and Supabase.
  Future<void> signOut() async {
    // Sign out Supabase first (requires an active session)
    try {
      await supabase.Supabase.instance.client.auth.signOut();
    } catch (e) {
      debugPrint('[AuthService] Supabase sign-out error (non-fatal): $e');
    }
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
