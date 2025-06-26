import 'package:flutter/material.dart';
import 'package:flutter_application_1/loginpage.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(
      const Duration(seconds: 3),
    ); // Simulasi loading selama 3 detik

    // Setelah proses loading selesai, navigasi ke halaman berikutnya
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 250, height: 250),
            const SizedBox(height: 30),
            // Opsional: Anda bisa menambahkan teks lain seperti 'Memuat...' di bawah 'Catat Uang'
            // const Text(
            //   'Memuat...',
            //   style: TextStyle(
            //     fontSize: 16,
            //     color: Colors.black54,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
