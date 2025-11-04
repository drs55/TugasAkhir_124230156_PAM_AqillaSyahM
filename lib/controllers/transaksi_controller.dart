import 'package:flutter/material.dart';
import '../models/model_transaksi.dart';
import '../models/services/service_transaksi.dart';

class TransaksiController extends ChangeNotifier {
  List<ModelTransaksi> _daftarTransaksi = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ModelTransaksi> get daftarTransaksi => _daftarTransaksi;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Load all transactions (since service doesn't have getTransaksiByUser)
  Future<void> loadAllTransaksi() async {
    _setLoading(true);
    _setError(null);
    
    try {
      _daftarTransaksi = ServiceTransaksi.getRiwayatTransaksi();
      _setLoading(false);
    } catch (e) {
      _setError('Gagal memuat riwayat transaksi: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Add new transaction
  Future<bool> tambahTransaksi(ModelTransaksi transaksi) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await ServiceTransaksi.simpanTransaksi(transaksi);
      // Reload all transactions
      await loadAllTransaksi();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal menyimpan transaksi: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Get transaction by ID
  ModelTransaksi? getTransaksiById(String id) {
    try {
      return _daftarTransaksi.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get total spent
  double getTotalSpent() {
    double total = 0;
    for (var transaksi in _daftarTransaksi) {
      // Remove non-numeric characters and parse
      final hargaStr = transaksi.hargaMobil.replaceAll(RegExp(r'[^0-9]'), '');
      final harga = double.tryParse(hargaStr) ?? 0;
      total += harga;
    }
    return total;
  }

  // Get transaction count
  int getTransaksiCount() {
    return _daftarTransaksi.length;
  }

  // Get recent transactions (last N)
  List<ModelTransaksi> getRecentTransaksi(int count) {
    if (_daftarTransaksi.length <= count) {
      return _daftarTransaksi;
    }
    return _daftarTransaksi.sublist(0, count);
  }

  // Delete transaction
  Future<bool> hapusTransaksi(String id) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await ServiceTransaksi.hapusTransaksi(id);
      await loadAllTransaksi();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal menghapus transaksi: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Clear error
  void clearError() {
    _setError(null);
  }
}
