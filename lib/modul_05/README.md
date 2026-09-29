sharedPreferences untuk menyimpan data ke dalam bentuk String JSON
perulangan yang digunakan untuk daftar objek ke satu String JSON
//Menyimpan: objek → peta → teks
for (value in baris) {
    task.fromJson(value)
}

perulangan dengan menggunakan array 
// Membaca: teks → daftar peta → daftar objek
List(Task) ListTask = [];
for(int i=0; i < baris.length; i++) {
    Task a = Task.fromJson(baris[i]);
    ListTask.add(a);
}
return ListTask;

Ketika menyimpan data ke dalam SharedPreferences, Anda dapat mengonversi daftar objek menjadi String JSON menggunakan perulangan. 
Setiap objek diubah menjadi peta (map) dan kemudian dikonversi menjadi String JSON sebelum disimpan.
Pada proses lain data di ubah melalui JsonEncode untuk menyimpannya ke SharedPreferences.
Ketika membaca data dari SharedPreferences, Anda dapat mengonversi String JSON kembali menjadi daftar objek.
Ketika menggunakan datetime, pastikan untuk mengonversi objek DateTime menjadi format yang dapat disimpan dalam JSON, 
seperti menggunakan metode toIso8601String() saat menyimpan dan DateTime.parse() saat membaca kembali. 
Ini akan memastikan bahwa data tanggal dan waktu tetap akurat saat disimpan dan diambil dari SharedPreferences.
Karena nanti ada banyak tipe dari datetime, pastikan untuk menyesuaikan format penyimpanan dan pembacaan sesuai dengan kebutuhan aplikasi.