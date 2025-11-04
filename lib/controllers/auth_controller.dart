import 'package:flutter/material.dart';
import '../models/services/service_auth.dart';
import '../models/model_user.dart';

class AuthController extends ChangeNotifier {
  ModelUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  ModelUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setUser(ModelUser? user) {
    _currentUser = user;
    notifyListeners();
  }

  // Login functionality
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await ServiceAuth.login(username: username, password: password);
      if (result['success'] == true) {
        _setUser(result['user'] as ModelUser?);
        _setLoading(false);
        return true;
      } else {
        _setError(result['message'] as String?);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan saat login: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Register functionality
  Future<bool> register(String nama, String username, String password, String konfirmasiPassword, {String? noTelepon, String? alamat}) async {
    _setLoading(true);
    _setError(null);
    
    if (password != konfirmasiPassword) {
      _setError('Password dan konfirmasi password tidak sama');
      _setLoading(false);
      return false;
    }

    try {
      final result = await ServiceAuth.register(
        nama: nama,
        username: username,
        password: password,
        noTelepon: noTelepon,
        alamat: alamat,
      );
      
      if (result['success'] == true) {
        _setUser(result['user'] as ModelUser?);
        _setLoading(false);
        return true;
      } else {
        _setError(result['message'] as String?);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan saat registrasi: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Logout functionality
  Future<void> logout() async {
    _setLoading(true);
    await ServiceAuth.logout();
    _setUser(null);
    _setError(null);
    _setLoading(false);
  }

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    final user = await ServiceAuth.getCurrentUser();
    _setUser(user);
    _setLoading(false);
  }

  // Clear error message
  void clearError() {
    _setError(null);
  }
}