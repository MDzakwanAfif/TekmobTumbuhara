import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/halamanutama.dart';
import 'package:flutter_application_1/rekappage.dart';
import 'package:flutter_application_1/hutangpage.dart';
import 'package:flutter_application_1/loginpage.dart';
import 'package:flutter_application_1/backend/auth_service.dart';
import 'package:flutter_application_1/backend/database_service.dart';
import 'package:flutter_application_1/theme_provider.dart';

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
  late bool _isLoggedIn;
  late String _userName = "Pengguna Aktif";
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _isLoggedIn = user != null;
    if (_isLoggedIn) {
      _userName = user?.displayName ?? "Pengguna Aktif";
    }
  }

  Future<void> _handleDeleteAllData() async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Semua Data?'),
          content: const Text(
            'Apakah Anda benar-benar yakin ingin menghapus SEMUA data transaksi dan hutang Anda? Aksi ini tidak dapat dibatalkan.',
            style: TextStyle(height: 1.5),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true && mounted) {
      try {
        await _dbService.deleteAllUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua data Anda telah berhasil dihapus.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleLoginButton() {
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService().signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeProvider.mainColor,
        elevation: 0,
        title: const Text('Pengaturan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        shape: const ContinuousRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const CircleAvatar(radius: 24, child: Icon(Icons.person)),
            title: Text(_isLoggedIn ? _userName : 'Masuk'),
            subtitle: Text(_isLoggedIn ? 'Anda sudah login' : 'Masuk, lebih seru!'),
            trailing: ElevatedButton(
              onPressed: () => _isLoggedIn ? _handleLogout() : _handleLoginButton(),
              style: ElevatedButton.styleFrom(backgroundColor: themeProvider.mainColor, foregroundColor: Colors.white),
              child: Text(_isLoggedIn ? 'Logout' : 'Masuk'),
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.thumb_up, color: themeProvider.mainColor),
            title: const Text("Rekomendasikan ke teman"),
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
                selected: themeProvider.currentTheme == AppTheme.orange,
                selectedColor: Colors.orange[100],
                onSelected: (_) => themeProvider.setTheme(AppTheme.orange),
              ),
              ChoiceChip(
                label: const Text('Biru'),
                selected: themeProvider.currentTheme == AppTheme.blue,
                selectedColor: Colors.blue[100],
                onSelected: (_) => themeProvider.setTheme(AppTheme.blue),
              ),
              ChoiceChip(
                label: const Text('Hijau'),
                selected: themeProvider.currentTheme == AppTheme.green,
                selectedColor: Colors.green[100],
                onSelected: (_) => themeProvider.setTheme(AppTheme.green),
              ),
            ],
          ),
          const Divider(height: 40),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("Hapus Semua Data", style: TextStyle(color: Colors.red)),
            subtitle: const Text("Menghapus semua riwayat transaksi dan hutang"),
            onTap: _isLoggedIn ? _handleDeleteAllData : null,
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
        selectedItemColor: themeProvider.mainColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == widget.initialTabIndex) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) {
                switch (index) {
                  case 0: return HomePage(isLoggedIn: widget.isLoggedIn, initialTabIndex: 0);
                  case 1: return RekapPage(isLoggedIn: widget.isLoggedIn, initialTabIndex: 1);
                  case 2: return HutangPage(isLoggedIn: widget.isLoggedIn, initialTabIndex: 2);
                  case 3: return SettingsPage(isLoggedIn: widget.isLoggedIn, initialTabIndex: 3);
                  default: return HomePage(isLoggedIn: widget.isLoggedIn, initialTabIndex: 0);
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