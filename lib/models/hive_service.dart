import 'package:hive_flutter/hive_flutter.dart';
import 'model_transaksi.dart';

/// Service untuk mengelola Hive Database (Transaksi & User)
class HiveService {
  static const String _transaksiBox = 'transaksi_box';
  static const String _userBox = 'user_box';
  
  /// Initialize Hive database
  static Future<void> init() async {
    // Initialize Hive untuk Flutter
    await Hive.initFlutter();
    
    // Register adapter untuk ModelTransaksi
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ModelTransaksiAdapter());
    }
    
    // Buka box untuk transaksi
    await Hive.openBox<ModelTransaksi>(_transaksiBox);
    
    // Buka box untuk user (untuk data login tambahan jika perlu)
    await Hive.openBox(_userBox);
  }
  
  // ============ TRANSAKSI METHODS ============
  
  /// Get box transaksi
  static Box<ModelTransaksi> getTransaksiBox() {
    return Hive.box<ModelTransaksi>(_transaksiBox);
  }
  
  /// Simpan transaksi ke database
  static Future<void> saveTransaksi(ModelTransaksi transaksi) async {
    final box = getTransaksiBox();
    await box.put(transaksi.id, transaksi);
  }
  
  /// Get semua transaksi dari database (sorted by date desc)
  static List<ModelTransaksi> getAllTransaksi() {
    final box = getTransaksiBox();
    final list = box.values.toList();
    list.sort((a, b) => b.tanggalTransaksi.compareTo(a.tanggalTransaksi));
    return list;
  }
  
  /// Get transaksi by ID
  static ModelTransaksi? getTransaksiById(String id) {
    final box = getTransaksiBox();
    return box.get(id);
  }
  
  /// Get transaksi by user email
  static List<ModelTransaksi> getTransaksiByEmail(String email) {
    final box = getTransaksiBox();
    return box.values.where((t) => t.emailPembeli == email).toList()
      ..sort((a, b) => b.tanggalTransaksi.compareTo(a.tanggalTransaksi));
  }
  
  /// Delete transaksi by ID
  static Future<void> deleteTransaksi(String id) async {
    final box = getTransaksiBox();
    await box.delete(id);
  }
  
  /// Clear all transaksi
  static Future<void> clearAllTransaksi() async {
    final box = getTransaksiBox();
    await box.clear();
  }
  
  /// Get jumlah transaksi
  static int getTransaksiCount() {
    final box = getTransaksiBox();
    return box.length;
  }
  
  // ============ USER/LOGIN METHODS ============
  
  /// Get box user
  static Box getUserBox() {
    return Hive.box(_userBox);
  }
  
  /// Simpan data login terakhir
  static Future<void> saveLastLogin(String username, DateTime time) async {
    final box = getUserBox();
    await box.put('last_login_user', username);
    await box.put('last_login_time', time.toIso8601String());
  }
  
  /// Get username login terakhir
  static String? getLastLoginUser() {
    final box = getUserBox();
    return box.get('last_login_user');
  }
  
  /// Get waktu login terakhir
  static DateTime? getLastLoginTime() {
    final box = getUserBox();
    final timeStr = box.get('last_login_time');
    if (timeStr != null) {
      return DateTime.parse(timeStr);
    }
    return null;
  }
  
  /// Clear login data
  static Future<void> clearLoginData() async {
    final box = getUserBox();
    await box.delete('last_login_user');
    await box.delete('last_login_time');
  }
  
  /// Clear all data (untuk testing)
  static Future<void> clearAll() async {
    await clearAllTransaksi();
    await clearLoginData();
  }
}
