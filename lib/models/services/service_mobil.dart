import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model_mobil.dart';

/// Service untuk mengelola data mobil dengan penyimpanan lokal
/// Menggunakan SharedPreferences agar data tidak hilang saat restart
class ServiceMobil {
  static const String _keyDaftarMobil = 'daftar_mobil';
  static List<ModelMobil>? _cachedDaftarMobil;

  // Get semua mobil dari SharedPreferences
  static Future<List<ModelMobil>> getDaftarMobil() async {
    if (_cachedDaftarMobil != null) {
      return _cachedDaftarMobil!;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_keyDaftarMobil);

    if (jsonString == null || jsonString.isEmpty) {
      // Data default Fortuner dan Pajero dengan lokasi
      _cachedDaftarMobil = [
        ModelMobil(
          id: '1',
          nama: 'Toyota Fortuner VRZ',
          harga: 'Rp 620.000.000',
          tahun: '2023',
          bahanBakar: 'Diesel',
          transmisi: 'Automatic',
          gambar: 'assets/gambar/vrz.jpeg',
          deskripsi: 'SUV tangguh dan mewah, cocok untuk keluarga dan perjalanan jauh. Mesin diesel 2.4L turbo, interior leather premium.',
          latitude: -6.2088,    // Jakarta (Monas)
          longitude: 106.8456,
          alamat: 'Jl. Sudirman, Jakarta Pusat, DKI Jakarta',
        ),
        ModelMobil(
          id: '2',
          nama: 'Mitsubishi Pajero Sport Dakar',
          harga: 'Rp 585.000.000',
          tahun: '2023',
          bahanBakar: 'Diesel',
          transmisi: 'Automatic',
          gambar: 'assets/gambar/pjr.jpeg',
          deskripsi: 'SUV 4x4 dengan performa off-road terbaik. Dilengkapi fitur Super Select 4WD II, ideal untuk petualangan.',
          latitude: -6.9175,    // Bandung (Gedung Sate)
          longitude: 107.6191,
          alamat: 'Jl. Diponegoro, Bandung, Jawa Barat',
        ),
      ];
      await _simpanKeStorage(_cachedDaftarMobil!);
      return _cachedDaftarMobil!;
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedDaftarMobil = jsonList.map((json) => ModelMobil.fromMap(json)).toList();
      return _cachedDaftarMobil!;
    } catch (e) {
      _cachedDaftarMobil = [];
      return _cachedDaftarMobil!;
    }
  }

  // Simpan ke SharedPreferences
  static Future<void> _simpanKeStorage(List<ModelMobil> daftarMobil) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        daftarMobil.map((mobil) => mobil.toMap()).toList();
    final String jsonString = json.encode(jsonList);
    await prefs.setString(_keyDaftarMobil, jsonString);
  }

  // Tambah mobil baru
  static Future<void> tambahMobil(ModelMobil mobil) async {
    final daftarMobil = await getDaftarMobil();
    daftarMobil.add(mobil);
    _cachedDaftarMobil = daftarMobil;
    await _simpanKeStorage(daftarMobil);
  }

  // Hapus mobil berdasarkan ID
  static Future<void> hapusMobil(String id) async {
    final daftarMobil = await getDaftarMobil();
    daftarMobil.removeWhere((mobil) => mobil.id == id);
    _cachedDaftarMobil = daftarMobil;
    await _simpanKeStorage(daftarMobil);
  }

  // Update mobil
  static Future<void> updateMobil(ModelMobil mobilBaru) async {
    final daftarMobil = await getDaftarMobil();
    final index = daftarMobil.indexWhere((m) => m.id == mobilBaru.id);
    if (index != -1) {
      daftarMobil[index] = mobilBaru;
      _cachedDaftarMobil = daftarMobil;
      await _simpanKeStorage(daftarMobil);
    }
  }

  // Cari mobil berdasarkan ID
  static Future<ModelMobil?> getMobilById(String id) async {
    final daftarMobil = await getDaftarMobil();
    try {
      return daftarMobil.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  // Generate ID baru
  static Future<String> generateId() async {
    final daftarMobil = await getDaftarMobil();
    if (daftarMobil.isEmpty) {
      return '1';
    }
    final ids = daftarMobil.map((m) => int.tryParse(m.id) ?? 0).toList();
    final maxId = ids.reduce((a, b) => a > b ? a : b);
    return (maxId + 1).toString();
  }

  // Clear cache (untuk refresh data)
  static void clearCache() {
    _cachedDaftarMobil = null;
  }

  // Clear semua data (untuk reset)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDaftarMobil);
    _cachedDaftarMobil = null;
  }
}
