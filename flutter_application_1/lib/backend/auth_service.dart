import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Login dengan Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();


      // Mulai proses login Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("Login dibatalkan oleh pengguna.");
        return null;
      }

      // Ambil token autentikasi dari akun Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Buat kredensial untuk Firebase dari token Google
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Login ke Firebase menggunakan kredensial Google
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // DEBUG: tampilkan info user
      final user = userCredential.user;
      print("Login berhasil sebagai: ${user?.displayName} (${user?.email})");

      return userCredential;
    } catch (e) {
      print("Error saat login dengan Google: $e");
      return null;
    }
  }

  /// Logout dari Firebase dan Google
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      print("Logout berhasil.");
    } catch (e) {
      print("Gagal logout: $e");
    }
  }
}
