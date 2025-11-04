# 🚗 HexoCar - Aplikasi Jual Mobil Modern

<div align="center">

**Aplikasi Jual Mobil dengan Tampilan Modern dan User-Friendly**

</div>

---

## 📋 Deskripsi

**HexoCar** adalah aplikasi jual mobil yang dikembangkan sebagai Tugas Akhir Mata Kuliah Pemrograman Aplikasi Mobile. Aplikasi ini memiliki halaman profil yang lengkap dengan desain modern, simple, dan mudah digunakan.

## ✨ Fitur

### 🎯 Halaman Profil Lengkap

- **Foto Profil** dengan shadow effect yang menarik
- **Informasi Pribadi** yang terstruktur:
  - 👤 Nama Lengkap
  - 🎓 NIM
  - 🏫 Program Studi
  - ✉️ Email
  - 📱 Nomor Telepon
  
### 📝 Menu Interaktif

- **Saran dan Kesan** - Form khusus untuk memberikan feedback mata kuliah mobile
- **Pengaturan** - Pengaturan aplikasi (Coming Soon)
- **Bantuan** - Panduan penggunaan aplikasi (Coming Soon)
- **Tentang Aplikasi** - Informasi lengkap tentang HexoCar

### 🔐 Keamanan

- **Tombol Logout** dengan konfirmasi dialog
- Proteksi keluar tidak sengaja

## 🎨 Desain

### Skema Warna

```
Primary   : #2193b0 (Ocean Blue)
Secondary : #6dd5ed (Sky Blue)
Accent    : #FF6B6B (Coral Red)
Background: #F5F5F5 (Light Gray)
```

### Design System

- ✅ Material Design 3
- ✅ Gradient modern
- ✅ Shadow & elevation
- ✅ Rounded corners
- ✅ Smooth animations
- ✅ Responsive layout

## 📁 Struktur Proyek

```
bismmilah_ta/
├── lib/
│   ├── main.dart                    # Entry point aplikasi
│   ├── halaman/
│   │   └── halaman_profil.dart     # Halaman profil pengguna
│   └── model/
│       └── data_profil.dart        # Model data profil
├── assets/
│   └── gambar/
│       ├── foto_profil.png         # Foto profil (user)
│       └── README.md               # Panduan foto
├── test/
│   └── widget_test.dart            # Unit test
├── pubspec.yaml                     # Dependencies
├── PETUNJUK_PENGGUNAAN.md          # Panduan lengkap
├── CARA_EDIT_PROFIL.md             # Tutorial edit profil
└── README.md                        # File ini
```

## 🚀 Instalasi

### Prerequisites

Pastikan Anda sudah menginstall:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.9.2 atau lebih baru)
- [Dart SDK](https://dart.dev/get-dart)
- IDE (VS Code / Android Studio)
- Emulator atau device fisik

### Langkah Instalasi

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Tambahkan Foto Profil** (Opsional)
   - Letakkan foto di `assets/gambar/foto_profil.png`
   - Format: PNG, ukuran 500x500px

3. **Edit Data Profil Anda**
   - Buka `lib/halaman/halaman_profil.dart`
   - Cari method `_buildKartuInformasi`
   - Ganti data sesuai informasi Anda
   - Lihat [CARA_EDIT_PROFIL.md](CARA_EDIT_PROFIL.md) untuk detail

4. **Jalankan Aplikasi**
   ```bash
   flutter run
   ```
   
   Atau tekan **F5** di VS Code

## 📖 Dokumentasi

| Dokumen | Deskripsi |
|---------|-----------|
| [PETUNJUK_PENGGUNAAN.md](PETUNJUK_PENGGUNAAN.md) | Panduan lengkap penggunaan aplikasi |
| [CARA_EDIT_PROFIL.md](CARA_EDIT_PROFIL.md) | Tutorial edit data profil |
| [assets/gambar/README.md](assets/gambar/README.md) | Panduan tambah foto profil |

## 📱 Cara Menggunakan

### Edit Data Profil

1. Buka file `lib/halaman/halaman_profil.dart`
2. Cari bagian `_buildKartuInformasi`
3. Edit nilai pada setiap item:
   ```dart
   _buildItemInformasi(
     Icons.person_outline,
     'Nama Lengkap',
     'Nama Anda',  // Ganti di sini
     const Color(0xFF2193b0),
   ),
   ```

### Mengisi Saran dan Kesan

1. Jalankan aplikasi
2. Tap menu **"Saran dan Kesan"**
3. Isi form kesan dan saran Anda
4. Tap tombol **"Kirim"**

## 🛠️ Teknologi

- **Framework**: Flutter 3.9.2
- **Language**: Dart
- **UI Library**: Material Design 3
- **State Management**: StatelessWidget
- **Architecture**: Clean & Simple

## 🎯 Fitur Mendatang

- [ ] Edit profil inline
- [ ] Dark mode
- [ ] Ganti foto dari kamera/galeri
- [ ] Simpan data lokal
- [ ] Animasi transisi
- [ ] Multi bahasa (ID/EN)
- [ ] Halaman utama jual beli mobil

## 🐛 Troubleshooting

### Foto Profil Tidak Muncul
```bash
flutter clean
flutter pub get
flutter run
```

### Error saat Build
```bash
flutter doctor
flutter clean
flutter pub get
```

## 👨‍💻 Author

**Tugas Akhir Pemrograman Aplikasi Mobile**
- Mata Kuliah: Pemrograman Aplikasi Mobile
- Semester: 5
- Tahun: 2025

---

<div align="center">

**© 2025 HexoCar - All Rights Reserved**

Dibuat dengan ❤️ menggunakan Flutter

</div>
