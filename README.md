# BOASH Academic

Portal akademik mahasiswa Universitas BOASH dengan tema navy dan kuning sesuai logo kampus.

## Menjalankan aplikasi

```sh
flutter pub get
flutter run
```

## Fitur

- Login mahasiswa menggunakan NPM dan verifikasi SHA-1; kedua kolom kredensial dikosongkan secara default.
- Tombol login dapat menyalin NPM ke kolom password bila akun memang memakai password yang sama.
- Tab **Daftar** berisi daftar layanan akademik; password tetap dimasukkan saat login.
- Beranda dengan profil, ringkasan nilai/SKS, akses layanan, serta informasi kampus.
- Halaman KHS/DHS, KRS, presensi, keuangan, bimbingan, sertifikat, informasi, dan berita.
- Pengajuan dan penghapusan KRS.
- Tarik-untuk-muat-ulang dan tampilan error saat layanan API tidak tersedia.

Endpoint MockAPI dan parsing respons berada di `lib/api_service.dart`. Data profil dan nilai ditampilkan dari respons server; aplikasi tidak mengisi data demo mahasiswa lain saat hasil pencarian kosong.

## Validasi

```sh
flutter analyze
flutter test
```
