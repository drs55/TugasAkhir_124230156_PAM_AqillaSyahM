import 'package:flutter/material.dart';
import '../models/model_mobil.dart';
import '../services/service_mobil.dart';

class MobilController extends ChangeNotifier {
  List<ModelMobil> _daftarMobil = [];
  List<ModelMobil> _filteredMobil = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ModelMobil> get daftarMobil => _filteredMobil.isEmpty && _searchQuery.isEmpty ? _daftarMobil : _filteredMobil;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Load all mobil from database
  Future<void> loadMobil() async {
    _setLoading(true);
    _setError(null);
    
    try {
      _daftarMobil = await ServiceMobil.getDaftarMobil();
      _filteredMobil = [];
      _searchQuery = '';
      _setLoading(false);
    } catch (e) {
      _setError('Gagal memuat data mobil: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Add new mobil
  Future<bool> tambahMobil(ModelMobil mobil) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await ServiceMobil.tambahMobil(mobil);
      await loadMobil();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal menambah mobil: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Update existing mobil
  Future<bool> updateMobil(ModelMobil mobil) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await ServiceMobil.updateMobil(mobil);
      await loadMobil();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal mengupdate mobil: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Delete mobil
  Future<bool> hapusMobil(String id) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await ServiceMobil.hapusMobil(id);
      await loadMobil();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal menghapus mobil: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Get mobil by ID
  ModelMobil? getMobilById(String id) {
    try {
      return _daftarMobil.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search mobil
  void searchMobil(String query) {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _filteredMobil = [];
    } else {
      _filteredMobil = _daftarMobil.where((mobil) {
        final namaMobil = mobil.nama.toLowerCase();
        final searchLower = query.toLowerCase();
        
        return namaMobil.contains(searchLower);
      }).toList();
    }
    
    notifyListeners();
  }

  // Filter by nama (since merek doesn't exist in ModelMobil)
  void filterByNama(String nama) {
    if (nama.isEmpty || nama == 'Semua') {
      _filteredMobil = [];
    } else {
      _filteredMobil = _daftarMobil.where((mobil) => mobil.nama.contains(nama)).toList();
    }
    notifyListeners();
  }

  // Get unique nama list
  List<String> getNamaList() {
    final namaSet = _daftarMobil.map((m) => m.nama).toSet();
    return namaSet.toList()..sort();
  }

  // Clear search and filter
  void clearSearch() {
    _searchQuery = '';
    _filteredMobil = [];
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _setError(null);
  }
}
