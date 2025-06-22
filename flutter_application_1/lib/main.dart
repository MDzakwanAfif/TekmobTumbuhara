import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'loginpage.dart';
import 'halamanutama.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi data lokal untuk 'id' (Bahasa Indonesia)
  await initializeDateFormatting('id', null);

  runApp(const TanamUangApp());
}

class TanamUangApp extends StatelessWidget {
  const TanamUangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tanam Uang',
      home: const LoginPage(),

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('id', '')],
      // <--- AKHIR DARI BAGIAN LOKALISASI --->
    );
  }
}
