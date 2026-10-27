import 'package:flutter/material.dart';
import 'package:my_first_app/modul_06/widgets/kartu_sesi.dart';
import 'package:my_first_app/modul_06/models/sesi_pengguna.dart';
import 'package:my_first_app/modul_06/services/auth_api.dart';
import 'package:my_first_app/modul_06/services/sesi_memori.dart';
import 'package:my_first_app/modul_06/widgets/fields_kata_sandi.dart';

// TODO: import widget pendukung berikut dari file tempat Anda mendefinisikannya
// (FieldKataSandi, KartuSesi, _KotakPesan, _KotakInfoDemo, _KotakPeringatanMemori).
// Catatan: widget berawalan "_" bersifat private per-file, jadi harus berada
// di file ini atau diganti namanya tanpa "_" bila dipisah ke file lain.

enum StatusAuth { memeriksa, keluar, memproses, masuk, gagal }

class LoginScreen extends StatefulWidget {
  final AuthApi api;
  final SesiMemori sesiMemori;
  final DateTime Function() jam;

  const LoginScreen({
    super.key,
    required this.api,
    required this.sesiMemori,
    this.jam = DateTime.now,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _sandi = TextEditingController();

  StatusAuth _status = StatusAuth.memeriksa;
  String? _pesanGagal;
  SesiPengguna? _sesi;
  bool _sedangKeluar = false;

  @override
  void initState() {
    super.initState();
    _pulihkanSesi();
  }

  @override
  void dispose() {
    // Controller juga menyimpan isi kolom. Kalau tidak dibuang di sini,
    // isinya bertahan selama objeknya hidup.
    _email.dispose();
    _sandi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modul 06 – Login & Session Dasar'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SafeArea(child: _bangunIsi()),
    );
  }

  // Satu-satunya tempat yang memutuskan layar mana yang tampil.
  Widget _bangunIsi() {
    switch (_status) {
      case StatusAuth.memeriksa:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memeriksa sesi tersimpan...'),
            ],
          ),
        );
      case StatusAuth.masuk:
        final SesiPengguna? sesi = _sesi;
        if (sesi == null) {
          // Tidak seharusnya terjadi; kembali ke form lebih baik
          // daripada menampilkan layar kosong.
          return _bangunForm();
        }
        return _bangunBeranda(sesi);
      case StatusAuth.keluar:
      case StatusAuth.memproses:
      case StatusAuth.gagal:
        return _bangunForm();
    }
  }

  Widget _bangunForm() {
    final bool sibuk = _status == StatusAuth.memproses;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        const SizedBox(height: 8),
        const Text(
          'Masuk ke Portal Akademik',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        // Pesan kegagalan tampil di sini — dan TIDAK tampil pada
        // keadaan keluar, karena keluar bukan kesalahan.
        if (_pesanGagal != null) ...<Widget>[
          _KotakPesan(pesan: _pesanGagal!),
          const SizedBox(height: 16),
        ],

        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _email,
                enabled: !sibuk,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.email],
                validator: _validasiEmail,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),
              FieldKataSandi(
                controller: _sandi,
                enabled: !sibuk,
                validator: (String? nilai) {
                  if (nilai == null || nilai.isEmpty) {
                    return 'Kata sandi wajib diisi.';
                  }
                  if (nilai.length < 8) {
                    return 'Kata sandi minimal 8 karakter.';
                  }
                  return null;
                },
                // Jika tipe onSubmitted di FieldKataSandi adalah
                // ValueChanged<String>, ganti menjadi: (_) => _kirim()
                onSubmitted: _kirim,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            // Dua lapis penjaga sekaligus: penjaga di dalam _kirim
            // dan tombol yang mati saat proses berjalan.
            onPressed: sibuk ? null : _kirim,
            icon: sibuk
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login_rounded),
            label: Text(sibuk ? 'Memproses…' : 'Masuk'),
          ),
        ),
        const SizedBox(height: 12),
        _KotakInfoDemo(
          onIsiOtomatis: sibuk
              ? null
              : () => setState(() {
                  _email.text = AuthApi.emailDemo;
                  _sandi.text = AuthApi.sandiDemo;
                }),
        ),
      ],
    );
  }

  // Validasi sengaja sederhana: tujuannya menunjukkan bahwa validasi
  // klien adalah penyaring kenyamanan, bukan pengaman.
  static String? _validasiEmail(String? nilai) {
    final String teks = (nilai ?? '').trim();
    if (teks.isEmpty) return 'Email wajib diisi.';
    if (!teks.contains('@') || !teks.contains('.')) {
      return 'Format email belum benar.';
    }
    return null;
  }

  Widget _bangunBeranda(SesiPengguna sesi) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        const Text(
          'Beranda',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        KartuSesi(
          sesi: sesi,
          sekarang: widget.jam(),
          onKeluar: _keluar,
          sedangKeluar: _sedangKeluar,
        ),
        const SizedBox(height: 20),
        // Pengingat: sesi ini hanya ada di memori proses. Tutup aplikasi
        // dari daftar aplikasi terakhir, lalu buka lagi — sesi akan hilang.
        const _KotakPeringatanMemori(),
      ],
    );
  }

  Future<void> _pulihkanSesi() async {
    try {
      final SesiPengguna? tersimpan = widget.sesiMemori.baca();
      if (!mounted) return;

      if (tersimpan == null) {
        setState(() => _status = StatusAuth.keluar);
        return;
      }

      if (tersimpan.sudahKedaluwarsa(widget.jam())) {
        await widget.sesiMemori.hapus();
        if (!mounted) return;
        setState(() {
          _status = StatusAuth.gagal;
          _pesanGagal = 'Sesi sebelumnya sudah berakhir. Silakan masuk lagi.';
        });
        return;
      }

      setState(() {
        _sesi = tersimpan;
        _status = StatusAuth.masuk;
      });
    } catch (e) {
      // Tanpa ini, kegagalan baca/hapus membuat layar macet selamanya
      // pada "Memeriksa sesi tersimpan...".
      debugPrint('Gagal memulihkan sesi: $e');
      if (!mounted) return;
      setState(() => _status = StatusAuth.keluar);
    }
  }

  Future<void> _kirim() async {
    if (_status == StatusAuth.memproses) return; // Cegah kirim ganda.
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _status = StatusAuth.memproses;
      _pesanGagal = null;
    });

    try {
      final SesiPengguna hasil = await widget.api.masuk(
        // Validator memakai trim(), maka nilai yang dikirim juga harus
        // di-trim agar konsisten. Sandi TIDAK di-trim.
        email: _email.text.trim(),
        sandi: _sandi.text,
      );
      await widget.sesiMemori.simpan(hasil);
      if (!mounted) return;
      setState(() {
        _sesi = hasil;
        _status = StatusAuth.masuk;
        _sandi.clear();
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _status = StatusAuth.gagal;
        _pesanGagal = e.pesan;
      });
    } catch (e) {
      // Kesalahan tak terduga TIDAK dibocorkan ke layar.
      debugPrint('Login gagal tak terduga: $e');
      if (!mounted) return;
      setState(() {
        _status = StatusAuth.gagal;
        _pesanGagal = 'Terjadi kesalahan tak terduga. Coba lagi.';
      });
    }
  }

  Future<void> _keluar() async {
    if (_sedangKeluar) return; // Cegah ketukan ganda.
    setState(() => _sedangKeluar = true);

    try {
      await widget.sesiMemori.hapus();
    } catch (e) {
      // Jika hapus gagal, tetap di Beranda dan buka kembali tombolnya
      // supaya pengguna bisa mencoba lagi, bukan terkunci.
      debugPrint('Gagal menghapus sesi: $e');
      if (!mounted) return;
      setState(() => _sedangKeluar = false);
      return;
    }

    if (!mounted) return;
    setState(() {
      _sesi = null;
      _status = StatusAuth.keluar; // Bukan StatusAuth.gagal.
      _pesanGagal = null;
      _sedangKeluar = false;
      _email.clear();
      _sandi.clear();
    });
  }
}

class _KotakPesan extends StatelessWidget {
  final String pesan;

  const _KotakPesan({required this.pesan});

  @override
  Widget build(BuildContext context) {
    final ColorScheme warna = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warna.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.error_outline_rounded, color: warna.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(pesan, style: TextStyle(color: warna.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}

// Menambahkan class FieldKataSandi, KartuSesi, _KotakPesan, _KotakInfoDemo, _KotakPeringatanMemori.
class _KotakInfoDemo extends StatelessWidget {
  final VoidCallback? onIsiOtomatis;

  const _KotakInfoDemo({required this.onIsiOtomatis});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Akun demo', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text('Email: ${AuthApi.emailDemo}'),
            Text('Kata sandi: ${AuthApi.sandiDemo}'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onIsiOtomatis,
              child: const Text('Isi otomatis'),
            ),
          ],
        ),
      ),
    );
  }
}
class _KotakPeringatanMemori extends StatelessWidget {
  const _KotakPeringatanMemori();
 
  @override
  Widget build(BuildContext context) {
    final ColorScheme warna = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warna.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Sesi ini hanya ada di memori proses. Tutup aplikasi dari daftar '
        'aplikasi terakhir, lalu buka lagi — sesi akan hilang. '
        'Itu hasil yang diharapkan.',
        style: TextStyle(color: warna.onSecondaryContainer),
      ),
    );
  }
}
