import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'loadingpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi data lokal untuk 'id' (Bahasa Indonesia)
  await initializeDateFormatting('id', null);
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

 
  runApp(const TanamUangApp());
}

class TanamUangApp extends StatelessWidget {
  const TanamUangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tanam Uang',
      home: LoadingPage(),

      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en', ''), Locale('id', '')],
      // <--- AKHIR DARI BAGIAN LOKALISASI --->
    );
  }
}
