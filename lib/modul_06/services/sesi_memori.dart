import 'package:my_first_app/modul_06/models/sesi_pengguna.dart';

class SesiMemori {
  // Saat aplikasi pertama kali dinyalakan, variabel _sesi bernilai null (belum ada yang login).

  SesiPengguna? _sesi;
  int jumlahPenulisan = 0; // Dipakai pengujian

  // Aplikasi memanggil adaSesi untuk mengecek status:
  // Jika false: Aplikasi mengarahkan pengguna ke Halaman Login.
  // Jika true: Aplikasi langsung membukakan Halaman Utama / Dashboard.
  // Ketika pengguna berada di Halaman Utama atau Halaman Profil, aplikasi memanggil baca().
  // Fungsi ini mengembalikan objek _sesi sehingga nama, foto, atau informasi pengguna dapat ditampilkan pada widget UI.
  SesiPengguna? baca() => _sesi;
  bool get adaSesi => _sesi != null;

  
  Future<void> simpan(SesiPengguna sesi) async {
    _sesi = sesi;
    jumlahPenulisan++;
  }

  // Pengguna menekan tombol Logout.
  // Aplikasi memanggil await hapus():
  // Nilai _sesi diubah kembali menjadi null.
  // Pengguna secara otomatis diarahkan kembali ke Halaman Login.
  Future<void> hapus() async {
    _sesi = null;
  }
}
