import '../models/model_transaksi.dart';
import '../models/hive_service.dart';

/// Service untuk mengelola transaksi dengan Hive Database
class ServiceTransaksi {
  
  /// Simpan transaksi baru
  static Future<void> simpanTransaksi(ModelTransaksi transaksi) async {
    await HiveService.saveTransaksi(transaksi);
  }
  
  /// Get semua riwayat transaksi (sorted terbaru dulu)
  static List<ModelTransaksi> getRiwayatTransaksi() {
    return HiveService.getAllTransaksi();
  }
  
  /// Get riwayat transaksi by email pembeli
  static List<ModelTransaksi> getRiwayatByEmail(String email) {
    return HiveService.getTransaksiByEmail(email);
  }
  
  /// Get transaksi by ID
  static ModelTransaksi? getTransaksiById(String id) {
    return HiveService.getTransaksiById(id);
  }
  
  /// Hapus transaksi
  static Future<void> hapusTransaksi(String id) async {
    await HiveService.deleteTransaksi(id);
  }
  
  /// Clear semua riwayat transaksi
  static Future<void> clearAllTransaksi() async {
    await HiveService.clearAllTransaksi();
  }
  
  /// Get jumlah total transaksi
  static int getTotalTransaksi() {
    return HiveService.getTransaksiCount();
  }
  
  /// Generate ID transaksi baru
  static String generateIdTransaksi() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'TRX-$timestamp';
  }
  
  /// Get total pendapatan dari semua transaksi
  static double getTotalPendapatan() {
    final transaksiList = getRiwayatTransaksi();
    double total = 0;
    
    for (var transaksi in transaksiList) {
      if (transaksi.status == 'Completed') {
        // Parse harga (remove "Rp" and dots)
        String hargaStr = transaksi.hargaMobil
            .replaceAll('Rp', '')
            .replaceAll('.', '')
            .trim();
        double harga = double.tryParse(hargaStr) ?? 0;
        total += harga;
      }
    }
    
    return total;
  }
  
  /// Get transaksi dalam rentang tanggal
  static List<ModelTransaksi> getTransaksiBetweenDates(DateTime start, DateTime end) {
    final allTransaksi = getRiwayatTransaksi();
    return allTransaksi.where((t) {
      return t.tanggalTransaksi.isAfter(start) && 
             t.tanggalTransaksi.isBefore(end);
    }).toList();
  }
  
  /// Get transaksi hari ini
  static List<ModelTransaksi> getTransaksiHariIni() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return getTransaksiBetweenDates(startOfDay, endOfDay);
  }
  
  /// Get transaksi bulan ini
  static List<ModelTransaksi> getTransaksiBulanIni() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return getTransaksiBetweenDates(startOfMonth, endOfMonth);
  }
}
