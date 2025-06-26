import 'package:flutter/material.dart';
import 'package:flutter_application_1/halamanutama.dart'; // Ensure this path is correct

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Define responsive values
    // Adjust header height based on screen height, or set a minimum
    final double headerHeight =
        size.height * 0.22 < 180
            ? 180
            : size.height * 0.22; // Min 180, grows with height
    final double panelTopOverlap =
        headerHeight -
        (size.height * 0.1); // Adjust overlap for better aesthetics
    final double logoSize = size.width * 0.45; // Logo scales with screen width
    final double verticalPadding =
        size.height * 0.03; // Responsive vertical padding

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
              height: headerHeight, // Use responsive header height
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
                    top: size.height * 0.06, // Responsive top padding
                    left: 20,
                    child: GestureDetector(
                      onTap: () {
                        debugPrint('Batalkan clicked');
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder:
                                (context) => const HomePage(isLoggedIn: false),
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
                    top: size.height * 0.06, // Responsive top padding
                    right: 20,
                    child: GestureDetector(
                      onTap: () {
                        debugPrint('Masuk clicked');
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder:
                                (context) => const HomePage(isLoggedIn: true),
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
          // Use Positioned.fill to give clear height boundaries, then Align
          Positioned.fill(
            top: panelTopOverlap, // Adjusted overlap for better responsiveness
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
                    vertical: verticalPadding, // Responsive vertical padding
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/logo.png',
                        width: logoSize, // Responsive logo size
                        height: logoSize, // Responsive logo size
                      ),
                      SizedBox(
                        height: size.height * 0.03,
                      ), // Responsive spacing

                      Text(
                        'TumbuHara',
                        style: TextStyle(
                          fontSize: size.width * 0.08, // Responsive font size
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Kecil Dicatat, Besar Terjaga',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.05, // Responsive font size
                          fontWeight: FontWeight.normal,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.025,
                      ), // Responsive spacing
                      // Deskripsi
                      Text(
                        'Setelah masuk, Anda dapat mencadangkan\ndata Anda secara real time!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.035, // Responsive font size
                          fontWeight: FontWeight.normal,
                          color: Colors.black87,
                        ),
                      ),

                      SizedBox(
                        height: size.height * 0.02,
                      ), // Responsive spacing
                      // Tombol Google
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder:
                                  (context) => const HomePage(isLoggedIn: true),
                            ),
                          );
                        },
                        icon: Image.asset(
                          'assets/google_logo.png',
                          height: size.width * 0.05,
                        ), // Responsive icon size
                        label: Text(
                          'Masuk Dengan Google',
                          style: TextStyle(
                            fontSize: size.width * 0.04, // Responsive font size
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAEAEA),
                          padding: EdgeInsets.symmetric(
                            vertical:
                                size.height *
                                0.018, // Responsive vertical padding
                            horizontal:
                                size.width *
                                0.06, // Responsive horizontal padding
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          elevation: 0,
                          minimumSize: Size(
                            size.width * 0.7,
                            size.height * 0.06, // Responsive button height
                          ),
                        ),
                      ),

                      SizedBox(
                        height: size.height * 0.03,
                      ), // Responsive spacing
                      // Disclaimer
                      Text(
                        'Dengan masuk, Anda menyetujui Perjanjian Penggunaan\ndan Kebijakan Privasi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.03, // Responsive font size
                          fontWeight: FontWeight.w200,
                          color: Colors.black54,
                        ),
                      ),

                      SizedBox(
                        height: size.height * 0.005,
                      ), // Responsive spacing
                      // Syarat & Kebijakan
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
                                fontSize:
                                    size.width * 0.025, // Responsive font size
                                fontWeight: FontWeight.w500,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.025,
                          ), // Responsive spacing
                          GestureDetector(
                            onTap: () {
                              debugPrint('Kebijakan Privasi clicked');
                            },
                            child: Text(
                              'Kebijakan Privasi',
                              style: TextStyle(
                                fontSize:
                                    size.width * 0.025, // Responsive font size
                                fontWeight: FontWeight.w500,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ), // Responsive padding at bottom
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
