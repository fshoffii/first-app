# Analisis Lengkap Modul 04 - Future & REST API Dasar

## 1. Tujuan modul ini
Modul 04 dibuat untuk memahami konsep dasar Flutter dalam menangani data asynchronous serta komunikasi dengan API REST. Fokus utamanya adalah:

- menggunakan `Future` dan `FutureBuilder`
- mengambil data dari API menggunakan `http`
- menampilkan data ke UI dengan stateful widget
- melakukan navigasi antar layar
- membedakan mode simulasi dan mode data nyata

Tujuan akhirnya adalah agar aplikasi dapat menampilkan daftar pengumuman, filter berdasarkan kategori, dan membuka detail pengumuman saat item ditekan.

---

## 2. Struktur modul yang seharusnya dibuat
Modul ini terdiri dari beberapa komponen utama:

- model: `Announcement`
- service: `AnnouncementApi`
- screen: `AnnouncementListScreen`
- screen: `AnnouncementDetailScreen`
- widget: `AnnouncementCard`
- app entry: `Modul04App`

Hubungannya adalah:

1. `Modul04App` memanggil `AnnouncementListScreen`
2. `AnnouncementListScreen` memanggil `AnnouncementApi.ambilPengumuman()`
3. API mengembalikan `List<Announcement>`
4. widget `AnnouncementCard` menampilkan setiap item
5. saat item diklik, aplikasi berpindah ke `AnnouncementDetailScreen`

---

## 3. File per file: analisis mendalam

### 3.1 `lib/modul_04/models/announcement.dart`
Ini adalah file model paling penting.

Model `Announcement` harus berisi properti utama seperti:

- `id`
- `title`
- `content`
- `author`
- `category`
- `date`
- `readCount`

Model ini berfungsi sebagai template data yang dipakai di seluruh layar. Tanpa model yang benar, semua komponen lain tidak punya tipe data yang jelas.

#### Kenapa file ini awalnya error?
Awalnya file tersebut hanya berisi factory constructor:

```dart
factory Announcement.fromJson(Map<String, dynamic> json) {
  return Announcement(...);
}
```

Tetapi `Announcement` itu sendiri belum didefinisikan sebagai `class`. Artinya, Dart tidak tahu bahwa `Announcement` adalah tipe data yang valid. Akibatnya:

- `Announcement` tidak dikenali sebagai type
- `List<Announcement>` error
- `AnnouncementDetailScreen` tidak bisa menerima parameter `Announcement`
- `AnnouncementApi` tidak bisa mengembalikan `Future<List<Announcement>>`

#### Solusi yang benar
Model harus dibuat seperti ini:

```dart
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.category,
    required this.date,
    required this.readCount,
  });

  final int id;
  final String title;
  final String content;
  final String author;
  final String category;
  final String date;
  final int readCount;

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(...);
  }
}
```

Dengan struktur seperti itu, seluruh kode lain bisa dipakai dengan aman.

---

### 3.2 `lib/modul_04/services/announcement_api.dart`
File ini berfungsi sebagai penghubung aplikasi ke sumber data. Di sini terdapat dua mode:

#### a. Mode simulasi
Saat `modeSimulasi == true`, aplikasi tidak mengambil data dari internet. Data dibuat secara lokal dan diberi jeda 1 detik.

Tujuannya:
- mempermudah testing UI
- tidak perlu koneksi internet
- memahami konsep asynchronous tanpa dependency eksternal

#### b. Mode nyata
Saat `modeSimulasi == false`, aplikasi melakukan HTTP GET ke endpoint JSONPlaceholder:

```dart
https://jsonplaceholder.typicode.com/posts?_limit=10
```

Data JSON yang diterima kemudian dipetakan menjadi objek `Announcement`.

#### Logika penting di file ini
- timeout via `.timeout(Duration(seconds: 10))`
- menangani `TimeoutException`
- menangani `http.ClientException`
- menangani status code bukan 200
- menangani JSON yang tidak valid

#### Kenapa file ini penting?
Karena `AnnouncementApi` adalah sumber data utama untuk layar list. Jika pengambilan data gagal, `FutureBuilder` akan menerima `snapshot.hasError` dan menampilkan pesan error. Itu adalah pola resmi Flutter untuk menangani state async.

---

### 3.3 `lib/modul_04/screens/announcement_list_screen.dart`
Ini adalah layar utama untuk daftar pengumuman. Layar ini harus menggabungkan beberapa hal:

- Future untuk memuat data
- `setState()` untuk update state
- filter kategori
- navigasi ke detail
- `RefreshIndicator` untuk reload
- `FutureBuilder` untuk menangani loading/error

#### Struktur state yang benar
State harus punya data seperti:

```dart
late final AnnouncementApi _api;
late Future<List<Announcement>> _futurePengumuman;
String _kategoriTerpilih = 'Semua';
```

Setiap variabel ini memiliki peran:

- `_api` → objek API untuk mengambil data
- `_futurePengumuman` → hasil data yang akan ditampilkan
- `_kategoriTerpilih` → kategori aktif yang dipilih

#### Fungsi `_muatUlang()`
Fungsi ini berfungsi untuk mengambil data ulang saat user menarik layar ke bawah.

Pola yang benar:

```dart
Future<void> _muatUlang() async {
  final futureBaru = _api.ambilPengumuman();
  setState(() {
    _futurePengumuman = futureBaru;
  });

  try {
    await futureBaru;
  } catch (_) {
    // tetap aman karena FutureBuilder menangani error
  }
}
```

#### Fungsi `_pilihKategori()`
Digunakan untuk memilih filter kategori. Saat kategori berubah, `setState()` dipanggil agar UI di-render ulang.

#### Fungsi `_filterPengumuman()`
Digunakan untuk menampilkan item sesuai kategori aktif. Jika kategori adalah `Semua`, semua data muncul. Jika tidak, hanya item dengan kategori yang sama yang ditampilkan.

#### Kenapa file ini semula error?
Ada beberapa masalah:

1. variabel state tidak dideklarasikan
2. `build()` tidak ada
3. method sering dibuat double / tertanam di dalam method lain
4. import yang dibutuhkan tidak lengkap
5. `Announcement` belum didefinisikan benar

Jadi tidak hanya satu error, tetapi rangkaian error yang saling memengaruhi.

---

### 3.4 `lib/modul_04/screens/announcement_detail_screen.dart`
Detail screen bertugas menampilkan satu item pengumuman secara lengkap.

Seharusnya tampilan mencakup:

- kategori
- judul
- penulis
- tanggal
- jumlah baca
- isi konten

Ini penting agar user mendapatkan informasi lengkap dari pengumuman yang dipilih.

#### Prinsipnya
Detail screen tidak perlu `StatefulWidget` karena data tetap dan tidak berubah saat tampilan dibangun. `StatelessWidget` sudah cukup.

```dart
class AnnouncementDetailScreen extends StatelessWidget {
  const AnnouncementDetailScreen({
    super.key,
    required this.announcement,
  });

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    return Scaffold(...);
  }
}
```

---

### 3.5 `lib/modul_04/widgets/announcement_card.dart`
Widget ini berfungsi sebagai card item untuk daftar pengumuman.

Itu dibuat agar UI list tidak terlalu panjang dan lebih rapi. Card biasanya menampilkan:

- kategori
- nama judul
- preview isi
- tanggal
- author
- jumlah dibaca

Dengan komponen ini, tampilan daftar menjadi lebih profesional dan mudah dibaca.

#### Kenapa widget ini penting?
Karena widget list tanpa card akan terlihat terlalu sederhana. Card membantu membedakan satu pengumuman dengan pengumuman lainnya dan membuat user experience lebih baik.

---

### 3.6 `lib/modul_04/modul_04_app.dart`
File ini adalah entry point modul. Ia mengatur tema aplikasi dan menampilkan `AnnouncementListScreen` sebagai halaman utama.

#### Poin penting
- `MaterialApp` untuk mengaktifkan struktur app Flutter
- `ThemeData` untuk style
- `home` dipasang ke `AnnouncementListScreen`
- `AnnouncementApi(modeSimulasi: kModeSimulasi)` untuk menentukan sumber data

Konstanta:

```dart
const bool kModeSimulasi = bool.fromEnvironment('SIMULASI');
```

Artinya, bila aplikasi dijalankan dengan flag `SIMULASI=true`, sistem akan pakai data simulasi, bukan HTTP request asli.

---

## 4. Root cause paling utama
Dari semua analisis, akar masalah sebenarnya adalah:

1. model `Announcement` tidak dibuat lengkap
2. state pada list screen tidak dideklarasikan dengan benar
3. method copy-paste tertanam secara berulang di dalam method yang sama
4. file detail screen kosong
5. import antar file tidak terhubung dengan benar

Semua masalah itu membuat aplikasi tidak bisa compile dengan benar. Ini adalah jenis kesalahan yang sering muncul saat belajar Flutter karena file dibuat bertahap, lalu beberapa bagian tidak final atau terlalu cepat disalin.

---

## 5. Kenapa Dart memberi error seperti itu?
Dart akan memunculkan error karena compiler tidak menemukan definisi yang valid. Misalnya:

- `Announcement isn't a type`
- `The name 'Announcement' isn't a type`
- `undefined_method`
- `non_type_as_type_argument`

Semua itu muncul karena compiler melihat `Announcement` sebagai sesuatu yang tidak ada atau tidak valid sebagai tipe.

Jadi inti permasalahannya bukan hanya “salah satu file error”, tapi kumpulan file yang tidak konsisten satu sama lain.

---

## 6. Prinsip Flutter yang dipakai dalam modul ini
Modul 04 sangat cocok untuk memahami prinsip berikut:

### a. Stateful widget untuk data yang berubah
Saat data diambil dari API, state harus dipantau. Ini adalah alasan utama kenapa `StatefulWidget` dipakai karena data bisa berubah saat loading, sukses, atau error.

### b. FutureBuilder untuk async UI
FutureBuilder adalah widget yang tepat untuk menangani `Future` dan state berikut:

- waiting
- done
- error

### c. API sebagai layer terpisah
`AnnouncementApi` dipisah dari UI agar:

- clean architecture
- lebih mudah testing
- lebih mudah dipelihara

### d. `setState()` untuk re-render
Saat data baru dimuat, UI harus dirender ulang agar user melihat perubahan.

---

## 7. Hasil akhir yang diharapkan dari modul ini
Setelah perbaikan, modul ini harus bisa:

- menampilkan daftar pengumuman
- menampilkan loading saat data sedang diambil
- menampilkan pesan error jika gagal memuat
- filter pengumuman berdasarkan kategori
- refresh saat user menarik layar ke bawah
- membuka halaman detail saat item ditekan

Ini adalah implementasi dasar yang sangat umum dalam aplikasi Flutter modern.

---

## 8. Kesimpulan
Modul 04 sebenarnya bukan hanya soal API. Modul ini mengajarkan pola dasar dalam membangun aplikasi Flutter yang benar, yaitu:

- model data harus lengkap
- state harus terdefinisi jelas
- Future harus dikelola dengan benar
- UI harus dibangun dengan struktur yang valid
- error bisa terjadi akibat satu kesalahan kecil yang berdampak ke banyak file

Jadi, kegagalan utama dalam modul ini bukan semata-mata karena API, melainkan karena struktur data dan state dari aplikasi belum benar. Setelah semua komponen diperbaiki dan terhubung secara konsisten, modul bekerja dengan baik.

---

## 9. Catatan penting untuk pembelajaran
Saat belajar Flutter, penting untuk ingat bahwa:

- file model harus lengkap sebelum file UI dibuat
- semua data state harus dideklarasikan sebelum dipakai
- `build()` wajib ada pada widget yang ditampilkan
- `FutureBuilder` harus menerima `Future` yang valid
- contoh hasil copy-paste sebaiknya selalu diperiksa ulang, karena sering menimbulkan bug yang tidak kelihatan dari luar

Dengan memahami pola-pola ini, proses debugging akan jauh lebih efisien dan hasil akhir lebih rapi.
