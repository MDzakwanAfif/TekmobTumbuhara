import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/halamanutama.dart';
import 'package:flutter_application_1/rekappage.dart';
import 'package:flutter_application_1/hutangpage.dart';
import 'package:flutter_application_1/loginpage.dart';
import 'package:flutter_application_1/backend/auth_service.dart';

enum AppTheme { orange, blue, green }

class SettingsPage extends StatefulWidget {
  final bool isLoggedIn;
  final int initialTabIndex;

  const SettingsPage({
    super.key,
    this.isLoggedIn = false,
    this.initialTabIndex = 3,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  AppTheme _currentTheme = AppTheme.orange;
  late bool _isLoggedIn;
  late String _userName = "Pengguna Aktif";

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _isLoggedIn = user != null;
    if (_isLoggedIn) {
      _userName = user?.displayName ?? "Pengguna Aktif";
    }
  }

  Color get mainColor {
    switch (_currentTheme) {
      case AppTheme.orange:
        return Colors.orange;
      case AppTheme.blue:
        return Colors.blue;
      case AppTheme.green:
        return Colors.green;
    }
  }

  void _handleLoginButton() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService().signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        title: const Text(
          'Pengaturan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const CircleAvatar(radius: 24, child: Icon(Icons.person)),
            title: Text(_isLoggedIn ? _userName : 'Masuk'),
            subtitle: Text(
              _isLoggedIn ? 'Anda sudah login' : 'Masuk, lebih seru!',
            ),
            trailing: ElevatedButton(
              onPressed: () {
                if (_isLoggedIn) {
                  _handleLogout();
                } else {
                  _handleLoginButton();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                foregroundColor: Colors.white,
              ),
              child: Text(_isLoggedIn ? 'Logout' : 'Masuk'),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.thumb_up, color: Colors.orange),
            title: const Text("Rekomendasikan ke teman"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.star_rate, color: Colors.orange),
            title: const Text("Nilai Aplikasi"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.block, color: Colors.orange),
            title: const Text("Blokir Iklan"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const SizedBox(height: 20),
          const Text("Pilih Tema Warna:"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ChoiceChip(
                label: const Text('Orange'),
                selected: _currentTheme == AppTheme.orange,
                selectedColor: Colors.orange[100],
                onSelected: (_) => setState(() => _currentTheme = AppTheme.orange),
              ),
              ChoiceChip(
                label: const Text('Biru'),
                selected: _currentTheme == AppTheme.blue,
                selectedColor: Colors.blue[100],
                onSelected: (_) => setState(() => _currentTheme = AppTheme.blue),
              ),
              ChoiceChip(
                label: const Text('Hijau'),
                selected: _currentTheme == AppTheme.green,
                selectedColor: Colors.green[100],
                onSelected: (_) => setState(() => _currentTheme = AppTheme.green),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.paid), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Rekap'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Hutang'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
        currentIndex: widget.initialTabIndex,
        selectedItemColor: mainColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == widget.initialTabIndex) return;

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) {
                switch (index) {
                  case 0:
                    return HomePage(initialTabIndex: 0);
                  case 1:
                    return RekapPage(initialTabIndex: 1);
                  case 2:
                    return HutangPage(initialTabIndex: 2);
                  default:
                    return SettingsPage(initialTabIndex: 3);
                }
              },
            ),
          );
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
      ),
    );
  }
}
