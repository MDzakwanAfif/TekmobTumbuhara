import 'package:flutter/material.dart';
import 'package:flutter_application_1/halamanutama.dart'; // Pastikan path ini benar
// import 'package:google_sign_in/google_sign_in.dart'; // Uncomment jika sudah menambahkan paketnya

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  // Untuk simulasi Google Sign-In
  // GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']); // Uncomment jika menggunakan google_sign_in

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Stack(
        children: [
          // ====== Header Hitam Melengkung ======
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 180,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 50,
                    left: 20,
                    child: GestureDetector(
                      // Menggunakan GestureDetector agar bisa diklik
                      onTap: () {
                        // Navigasi ke HomePage ketika Batalkan diklik
                        // replace: true agar pengguna tidak bisa kembali ke halaman login dengan tombol back
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder:
                                (context) => const HomePage(
                                  isLoggedIn: false,
                                ), // isLogged = false
                          ),
                        );
                      },
                      child: const Text(
                        'Batalkan',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    right: 20,
                    child: GestureDetector(
                      // Menggunakan GestureDetector agar bisa diklik
                      onTap: () {
                        // Aksi untuk tombol "Masuk"
                        // Dalam kasus ini, kita bisa arahkan ke homepage juga
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder:
                                (context) => const HomePage(
                                  isLoggedIn: true,
                                ), // isLogged = true
                          ),
                        );
                      },
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ====== Panel Putih Tidak Full Width ======
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 100),
              width: size.width * 0.88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 30,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Image.asset('assets/logo.png', width: 120, height: 120),
                    const SizedBox(height: 30),

                    // Judul
                    const Text(
                      'Tanam Uang',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600, // semi-bold
                      ),
                    ),
                    const Text(
                      'Kecil Dicatat, Besar Terjaga',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Deskripsi
                    const Text(
                      'Setelah masuk, Anda dapat mencadangkan\n'
                      'data Anda secara real time!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tombol Google
                    ElevatedButton.icon(
                      onPressed: () async {
                        // --- Simulasi Google Sign-In ---
                        // Dalam implementasi nyata, Anda akan melakukan hal seperti ini:
                        // try {
                        //   final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
                        //   if (googleUser != null) {
                        //     print('User signed in: ${googleUser.displayName}');
                        //     // Lanjutkan ke HomePage setelah login sukses
                        //     Navigator.of(context).pushReplacement(
                        //       MaterialPageRoute(
                        //         builder: (context) => const HomePage(isLoggedIn: true),
                        //       ),
                        //     );
                        //   } else {
                        //     print('Google Sign-In cancelled or failed.');
                        //   }
                        // } catch (error) {
                        //   print('Error during Google Sign-In: $error');
                        //   // Tampilkan pesan error ke pengguna
                        // }

                        // Karena kita tidak mengintegrasikan backend sungguhan,
                        // kita langsung navigasi ke HomePage sebagai simulasi login sukses.
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder:
                                (context) => const HomePage(isLoggedIn: true),
                          ),
                        );
                      },
                      icon: Image.asset('assets/google_logo.png', height: 20),
                      label: const Text(
                        'Masuk Dengan Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEAEAEA),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        elevation: 0,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Disclaimer
                    const Text(
                      'Dengan masuk, Anda menyetujui Perjanjian Penggunaan\n'
                      'dan Kebijakan Privasi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w200, // extra light
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Syarat & Kebijakan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          // Menggunakan GestureDetector agar bisa diklik
                          onTap: () {
                            // Aksi untuk Syarat Penggunaan
                            // Misalnya, buka URL atau tampilkan dialog
                            print('Syarat Penggunaan clicked');
                          },
                          child: const Text(
                            'Syarat Penggunaan',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500, // medium
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          // Menggunakan GestureDetector agar bisa diklik
                          onTap: () {
                            // Aksi untuk Kebijakan Privasi
                            print('Kebijakan Privasi clicked');
                          },
                          child: const Text(
                            'Kebijakan Privasi',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
