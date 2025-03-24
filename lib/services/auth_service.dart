import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "906491462662-tlb834jjlnn3beter7oapo8d0j1hbvch.apps.googleusercontent.com",
  );

  // Sign Up with Email & Password and Send Verification Email
  Future<User?> signUp(String email, String password) async {
    try {
      // Check if email is already registered
      var methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        // Check if the email is already verified
        try {
          UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          User? user = userCredential.user;
          
          if (user != null && user.emailVerified) {
            await signOut();
            return null;
          } else if (user != null) {
            // Email exists but not verified - send new verification email
            await user.sendEmailVerification();
            await signOut();
            return null;
          }
        } catch (e) {
          // If sign in fails, it means the email exists but password is wrong
          return null;
        }
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await user.sendEmailVerification(); // Send verification email
        await signOut(); // Sign out immediately after registration
      }
      return user;
    } on FirebaseAuthException catch (e) {
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    await user?.reload(); // Refresh user data
    return user?.emailVerified ?? false;
  }

  // Login with Email & Password (Only if email is verified)
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      // Attempt to sign in directly
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Refresh user data to get latest verification status
        await user.reload();
        user = _auth.currentUser;

        if (user?.emailVerified == true) {
          return {
            'success': true,
            'user': user,
            'message': 'Successfully logged in'
          };
        } else {
          // Send verification email again if needed
          await user?.sendEmailVerification();
          await signOut(); // Sign out unverified user
          return {
            'success': false,
            'message': 'Please verify your email before logging in. A new verification email has been sent.',
            'needsVerification': true
          };
        }
      }
      return {
        'success': false,
        'message': 'Failed to sign in'
      };
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred during sign in.';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else if (e.code == 'user-disabled') {
        message = 'This user account has been disabled.';
      }
      return {
        'success': false,
        'message': message,
        'error': e.code
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'error': e.toString()
      };
    }
  }

  // Google Sign-In
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {
          'success': false,
          'message': 'Google sign in was cancelled'
        };
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        return {
          'success': true,
          'user': user,
          'message': 'Successfully signed in with Google'
        };
      }
      return {
        'success': false,
        'message': 'Failed to sign in with Google'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred during Google sign in',
        'error': e.toString()
      };
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print("Sign Out Error: $e");
    }
  }

  // Reset Password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent. Please check your inbox.'
      };
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to send password reset email.';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      }
      return {
        'success': false,
        'message': message,
        'error': e.code
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'error': e.toString()
      };
    }
  }
}
