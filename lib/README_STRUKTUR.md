# 📁 Struktur Folder Lib - HexoCar App

Proyek ini telah direstrukturisasi untuk memisahkan **Style**, **Logic**, dan **Screen** ke dalam folder-folder terpisah agar lebih terorganisir dan mudah dimaintain.

## 📂 Struktur Folder

```
lib/
├── main.dart                    # Entry point aplikasi
│
├── styles/                      # 🎨 FOLDER STYLE
│   ├── app_colors.dart         # Konstanta warna aplikasi
│   ├── app_text_styles.dart    # Konstanta text style
│   ├── app_theme.dart          # Tema aplikasi
│   ├── app_constants.dart      # Konstanta umum (spacing, radius, dll)
│   └── styles.dart             # Export semua file style
│
├── logic/                       # 🧠 FOLDER LOGIC
│   ├── controllers/            # State management & controller
│   │   ├── auth_controller.dart
│   │   ├── mobil_controller.dart
│   │   ├── transaksi_controller.dart
│   │   └── controllers.dart    # Export semua controller
│   │
│   ├── services/               # Business logic & API services
│   │   ├── service_auth.dart
│   │   ├── service_mobil.dart
│   │   ├── service_mobil_api.dart
│   │   ├── service_transaksi.dart
│   │   ├── service_notifikasi.dart
│   │   ├── service_konversi_mata_uang.dart
│   │   └── service_waktu.dart
│   │
│   ├── models/                 # Data models
│   │   ├── model_user.dart
│   │   ├── model_mobil.dart
│   │   ├── model_transaksi.dart
│   │   ├── hive_service.dart
│   │   └── data_profil.dart
│   │
│   └── logic.dart              # Export semua file logic
│
└── screens/                     # 📱 FOLDER SCREEN/UI
    ├── halaman_splash.dart
    ├── halaman_login.dart
    ├── halaman_register.dart
    ├── halaman_beranda.dart
    ├── halaman_profil.dart
    ├── halaman_tambah_mobil.dart
    ├── halaman_beli_mobil.dart
    ├── halaman_riwayat_transaksi.dart
    ├── halaman_daftar_mobil_api.dart
    └── screens.dart            # Export semua file screen
```

## 🎯 Penjelasan Folder

### 1. 🎨 **styles/** - Folder Style
Berisi semua file yang berhubungan dengan **tampilan visual** aplikasi:
- **app_colors.dart**: Mendefinisikan warna-warna yang digunakan di aplikasi (primary, secondary, gradient, dll)
- **app_text_styles.dart**: Mendefinisikan style text (headline, body, button, dll)
- **app_theme.dart**: Konfigurasi tema aplikasi Material Design
- **app_constants.dart**: Konstanta umum seperti spacing, border radius, icon size, dll
- **styles.dart**: File export untuk import semua style sekaligus

**Cara pakai:**
```dart
import 'package:your_app/styles/styles.dart';

// Gunakan konstanta warna
Container(color: AppColors.primary)

// Gunakan text style
Text('Hello', style: AppTextStyles.headline1)

// Gunakan konstanta spacing
SizedBox(height: AppConstants.spacingMedium)
```

### 2. 🧠 **logic/** - Folder Logic
Berisi semua file yang berhubungan dengan **business logic**:

#### **controllers/**
State management dan controller untuk mengelola state aplikasi
- Contoh: AuthController, MobilController, TransaksiController

#### **services/**
Business logic dan integrasi dengan API/database
- service_auth: Autentikasi user
- service_mobil: CRUD mobil lokal
- service_mobil_api: Fetch mobil dari API external
- service_transaksi: Manajemen transaksi
- service_notifikasi: Local notifications
- service_konversi_mata_uang: Konversi mata uang
- service_waktu: Waktu dan timezone

#### **models/**
Data models dan struktur data
- model_user: Model data user
- model_mobil: Model data mobil
- model_transaksi: Model data transaksi
- hive_service: Service untuk Hive database

**Cara pakai:**
```dart
import 'package:your_app/logic/logic.dart';

// Gunakan service
final user = await ServiceAuth.login(...);

// Gunakan model
ModelMobil mobil = ModelMobil(...);
```

### 3. 📱 **screens/** - Folder Screen/UI
Berisi semua file **halaman/tampilan** aplikasi:
- halaman_splash: Splash screen
- halaman_login: Halaman login
- halaman_register: Halaman registrasi
- halaman_beranda: Halaman utama/home
- halaman_profil: Halaman profil user
- halaman_tambah_mobil: Halaman tambah mobil baru
- halaman_beli_mobil: Halaman detail & pembelian mobil
- halaman_riwayat_transaksi: Halaman riwayat transaksi
- halaman_daftar_mobil_api: Halaman daftar mobil dari API

**Cara pakai:**
```dart
import 'package:your_app/screens/screens.dart';

// Navigate ke screen
Navigator.push(context, MaterialPageRoute(
  builder: (context) => HalamanBeranda(),
));
```

## 📦 File Export

Setiap folder utama memiliki file export (styles.dart, logic.dart, screens.dart) untuk memudahkan import:

```dart
// Daripada import satu-satu:
import 'package:your_app/styles/app_colors.dart';
import 'package:your_app/styles/app_text_styles.dart';
import 'package:your_app/styles/app_theme.dart';

// Cukup import file export:
import 'package:your_app/styles/styles.dart';
```

## ✅ Keuntungan Struktur Baru

1. **Separation of Concerns**: Style, Logic, dan UI terpisah dengan jelas
2. **Mudah Dimaintain**: Lebih mudah mencari dan mengubah kode
3. **Reusable**: Komponen dapat digunakan ulang dengan mudah
4. **Scalable**: Mudah untuk menambah fitur baru
5. **Clean Code**: Kode lebih terorganisir dan mudah dibaca
6. **Team Collaboration**: Developer bisa fokus di folder masing-masing

## 🚀 Cara Menjalankan

```bash
# Get dependencies
flutter pub get

# Run aplikasi
flutter run
```

## 📝 Catatan Penting

- Semua import path sudah diupdate ke struktur baru
- Folder lama (controllers/, models/, views/) sudah dihapus
- Tidak ada breaking changes, aplikasi tetap berfungsi sama seperti sebelumnya
- File-file sudah disesuaikan dengan struktur baru

---

**Happy Coding! 🎉**
