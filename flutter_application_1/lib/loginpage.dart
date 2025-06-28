import 'package:flutter/material.dart';
import 'package:flutter_application_1/halamanutama.dart'; // Sesuaikan nama project kamu
import 'package:flutter_application_1/backend/auth_service.dart'; // Import AuthService

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double headerHeight = size.height * 0.22 < 180 ? 180 : size.height * 0.22;
    final double panelTopOverlap = headerHeight - (size.height * 0.1);
    final double logoSize = size.width * 0.45;
    final double verticalPadding = size.height * 0.03;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ====== Header Hitam Melengkung ======
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: headerHeight,
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
                    top: size.height * 0.06,
                    left: 20,
                    child: GestureDetector(
                      onTap: () {
                        debugPrint('Batalkan clicked');
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const HomePage(isLoggedIn: false),
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
                    top: size.height * 0.06,
                    right: 20,
                    child: GestureDetector(
                      onTap: () {
                        debugPrint('Masuk clicked');
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const HomePage(isLoggedIn: true),
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

          // ====== Panel Putih (Konten Utama) ======
          Positioned.fill(
            top: panelTopOverlap,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                width: size.width * 0.88,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha((255 * 0.3).round()),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: verticalPadding,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/logo.png',
                        width: logoSize,
                        height: logoSize,
                      ),
                      SizedBox(height: size.height * 0.03),
                      Text(
                        'TumbuHara',
                        style: TextStyle(
                          fontSize: size.width * 0.08,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Kecil Dicatat, Besar Terjaga',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.05,
                          fontWeight: FontWeight.normal,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: size.height * 0.025),
                      Text(
                        'Setelah masuk, Anda dapat mencadangkan data Anda secara real time!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.035,
                          fontWeight: FontWeight.normal,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),

                      // Tombol Login Google
                      ElevatedButton.icon(
                        onPressed: () async {
                          final userCredential = await AuthService().signInWithGoogle();
                          if (userCredential != null) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const HomePage(isLoggedIn: true),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Login dengan Google dibatalkan atau gagal."),
                              ),
                            );
                          }
                        },
                        icon: Image.asset(
                          'assets/google_logo.png',
                          height: size.width * 0.05,
                        ),
                        label: Text(
                          'Masuk Dengan Google',
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAEAEA),
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.018,
                            horizontal: size.width * 0.06,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          elevation: 0,
                          minimumSize: Size(
                            size.width * 0.7,
                            size.height * 0.06,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.03),
                      Text(
                        'Dengan masuk, Anda menyetujui Perjanjian Penggunaan dan Kebijakan Privasi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.03,
                          fontWeight: FontWeight.w200,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: size.height * 0.005),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              debugPrint('Syarat Penggunaan clicked');
                            },
                            child: Text(
                              'Syarat Penggunaan',
                              style: TextStyle(
                                fontSize: size.width * 0.025,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.025),
                          GestureDetector(
                            onTap: () {
                              debugPrint('Kebijakan Privasi clicked');
                            },
                            child: Text(
                              'Kebijakan Privasi',
                              style: TextStyle(
                                fontSize: size.width * 0.025,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
