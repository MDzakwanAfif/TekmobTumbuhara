// settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/halamanutama.dart'; // Untuk navigasi BottomNavBar
import 'package:flutter_application_1/loginpage.dart'; // <--- Import LoginPage

class SettingsPage extends StatefulWidget {
  final int initialTabIndex;
  final bool
  isLoggedIn; // <--- Tambahkan properti ini untuk mengecek status login

  const SettingsPage({
    super.key,
    this.initialTabIndex = 3,
    this.isLoggedIn = false, // <--- Beri nilai default
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _showDecimalNumbers =
      false; // State untuk Switch "Tampilkan Angka Desimal"
  int _selectedIndex = 3; // Index untuk Bottom Navigation Bar

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
    // Di sini Anda bisa memuat preferensi pengguna dari shared_preferences jika ada
    // Misalnya: _showDecimalNumbers = await SharedPreferences.getBool('showDecimal') ?? false;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Logika navigasi ke halaman lain
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          switch (index) {
            case 0:
              return HomePage(
                initialTabIndex: 0,
                isLoggedIn: widget.isLoggedIn,
              ); // Teruskan status login
            case 1:
              // return const RekapPage(initialTabIndex: 1); // Akan dibuat nanti
              return HomePage(
                initialTabIndex: 1,
                isLoggedIn: widget.isLoggedIn,
              ); // Placeholder
            case 2:
              // return const HutangPage(initialTabIndex: 2); // Akan dibuat nanti
              return HomePage(
                initialTabIndex: 2,
                isLoggedIn: widget.isLoggedIn,
              ); // Placeholder
            case 3:
              return SettingsPage(
                initialTabIndex: 3,
                isLoggedIn: widget.isLoggedIn,
              ); // Pengaturan (halaman ini sendiri)
            default:
              return HomePage(
                initialTabIndex: 0,
                isLoggedIn: widget.isLoggedIn,
              );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Warna background keseluruhan
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFFF9800), // Warna orange
        elevation: 0, // Tanpa shadow
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              children: [
                // Opsi "Tampilkan Angka Desimal"
                ListTile(
                  title: const Text(
                    'Tampilkan Angka Desimal',
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: Switch(
                    value: _showDecimalNumbers,
                    onChanged: (bool value) {
                      setState(() {
                        _showDecimalNumbers = value;
                        // Di sini Anda akan menyimpan preferensi ini ke shared_preferences
                        // Contoh: SharedPreferences.setBool('showDecimal', value);
                      });
                    },
                    activeColor: const Color(
                      0xFFFF9800,
                    ), // Warna switch saat aktif
                  ),
                  onTap: () {
                    // Tap di list tile juga bisa toggle switch
                    setState(() {
                      _showDecimalNumbers = !_showDecimalNumbers;
                      // Simpan preferensi juga
                    });
                  },
                ),
                const Divider(), // Garis pemisah
                // Opsi "Hapus Semua Data"
                ListTile(
                  title: const Text(
                    'Hapus Semua Data',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ), // Biasanya merah untuk aksi destruktif
                  ),
                  onTap: () {
                    // Logika untuk konfirmasi dan menghapus semua data
                    _showClearDataConfirmationDialog();
                  },
                ),
                const Divider(),
                // Opsi "Pengingat"
                ListTile(
                  title: const Text(
                    'Pengingat',
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    // Logika navigasi ke halaman pengaturan pengingat
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Halaman Pengingat akan datang!'),
                      ),
                    );
                  },
                ),
                const Divider(),
                // Opsi "Login" (atau "Logout" jika sudah login)
                ListTile(
                  title: Text(
                    widget.isLoggedIn
                        ? 'Logout'
                        : 'Login', // Teks berubah berdasarkan status login
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          widget.isLoggedIn
                              ? Colors.red
                              : Colors.blue, // Warna berubah
                    ),
                  ),
                  onTap: () {
                    if (widget.isLoggedIn) {
                      // Logika Logout
                      _showLogoutConfirmationDialog();
                    } else {
                      // Logika Login (kembali ke LoginPage)
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                        (Route<dynamic> route) =>
                            false, // Menghapus semua rute di bawahnya
                      );
                    }
                  },
                ),
                const Divider(),
              ],
            ),
          ),
          // Bottom Navigation Bar
          BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.paid),
                label: 'Transaksi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Rekap',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet),
                label: 'Hutang',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Pengaturan',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFFFF9800),
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  // Dialog konfirmasi untuk Hapus Semua Data
  void _showClearDataConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Semua Data?'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus semua data transaksi? Tindakan ini tidak bisa dibatalkan.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                // Logika untuk benar-benar menghapus data
                // Ini akan melibatkan menghapus data dari model, shared_preferences, atau database
                print('Semua data dihapus!'); // Placeholder
                Navigator.of(context).pop(); // Tutup dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua data telah dihapus.')),
                );
                // Mungkin perlu navigasi kembali ke homepage atau refresh data di homepage
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Dialog konfirmasi untuk Logout
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout?'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                // Logika logout sebenarnya (misalnya signOut dari GoogleSignIn)
                // GoogleSignIn().signOut(); // Contoh jika menggunakan google_sign_in
                print('User logged out!');
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) =>
                      false, // Menghapus semua rute di bawahnya
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
