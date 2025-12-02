import 'dart:convert';
import 'dart:math';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../models/model_user.dart';

/// Service untuk mengelola autentikasi dan data user dengan Hive Database
class ServiceAuth {
  static const String _boxUsers = 'users_box';
  static const String _boxSession = 'session_box';
  static const String _keyCurrentUser = 'current_user_id';
  static const String _keySessionToken = 'session_token';
  static const String _keySessionExpiry = 'session_expiry';
  
  // Legacy SharedPreferences keys (untuk migration)
  static const String _legacyKeyUsers = 'daftar_users';
  static const String _migrationFlag = 'migrated_to_hive';

  // Pepper rahasia sederhana (jangan commit ke repo publik pada produksi)
  static const String _pepper = 'HEXOCAR#P3pp3r!2025';
  static const int _pbkdf2Iterations = 10000; // dapat dinaikkan untuk keamanan lebih
  static const int _sessionDays = 7; // durasi sesi login

  // Initialize Hive boxes
  static Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ModelUserAdapter());
    }
    await Hive.openBox<ModelUser>(_boxUsers);
    await Hive.openBox(_boxSession);
    
    // Auto-migrate data dari SharedPreferences ke Hive
    await _migrateFromSharedPreferences();
  }

  static Box<ModelUser> get _usersBox => Hive.box<ModelUser>(_boxUsers);
  static Box get _sessionBox => Hive.box(_boxSession);
  
  /// Migrate data user dari SharedPreferences ke Hive (sekali jalan)
  static Future<void> _migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cek apakah sudah pernah migrate
      final alreadyMigrated = prefs.getBool(_migrationFlag) ?? false;
      if (alreadyMigrated) return;
      
      // Ambil data user lama dari SharedPreferences
      final usersJson = prefs.getString(_legacyKeyUsers);
      if (usersJson != null && usersJson.isNotEmpty) {
        final List<dynamic> usersList = jsonDecode(usersJson);
        final users = usersList.map((e) => ModelUser.fromMap(e)).toList();
        
        // Pindahkan semua user ke Hive
        for (var user in users) {
          await _usersBox.put(user.id, user);
        }
        
        print('✅ Berhasil migrate ${users.length} user dari SharedPreferences ke Hive');
      }
      
      // Migrate session jika ada
      final currentUserId = prefs.getString(_keyCurrentUser);
      final sessionToken = prefs.getString(_keySessionToken);
      final sessionExpiry = prefs.getString(_keySessionExpiry);
      
      if (currentUserId != null) {
        await _sessionBox.put(_keyCurrentUser, currentUserId);
      }
      if (sessionToken != null) {
        await _sessionBox.put(_keySessionToken, sessionToken);
      }
      if (sessionExpiry != null) {
        await _sessionBox.put(_keySessionExpiry, sessionExpiry);
      }
      
      // Hapus data lama dari SharedPreferences
      await prefs.remove(_legacyKeyUsers);
      await prefs.remove(_keyCurrentUser);
      await prefs.remove(_keySessionToken);
      await prefs.remove(_keySessionExpiry);
      
      // Set flag bahwa migration sudah selesai
      await prefs.setBool(_migrationFlag, true);
      
      print('✅ Data lokal lama (SharedPreferences) berhasil dihapus');
    } catch (e) {
      print('⚠️ Error saat migrate: $e');
    }
  }
  
  /// Hapus semua data user di Hive (untuk testing/reset)
  static Future<void> clearAllData() async {
    await _usersBox.clear();
    await _sessionBox.clear();
    print('✅ Semua data user di Hive berhasil dihapus');
  }

  // ===== UTIL HASH BARU (PBKDF2-HMAC-SHA256 manual) =====
  static List<int> _hmacSha256(List<int> key, List<int> message) {
    final hmac = Hmac(sha256, key);
    return hmac.convert(message).bytes;
  }

  static String _pbkdf2(String password, String salt, {int iterations = _pbkdf2Iterations, int dkLen = 32}) {
    final passBytes = utf8.encode(password + _pepper);
    final saltBytes = utf8.encode(salt);
    // PBKDF2: DK = T1 || T2 || ... dimana Ti = F(password, salt, c, i)
    int hLen = 32; // SHA-256 output length
    int l = (dkLen / hLen).ceil();
    // (r) panjang block terakhir tidak diperlukan eksplisit di implementasi ini
    List<int> dk = [];
    for (int i = 1; i <= l; i++) {
      // U1 = PRF(P, S || INT(i))
      final block = <int>[]..addAll(saltBytes)..addAll(_int32BE(i));
      List<int> u = _hmacSha256(passBytes, block);
      List<int> t = List<int>.from(u);
      for (int j = 1; j < iterations; j++) {
        u = _hmacSha256(passBytes, u);
        for (int k = 0; k < t.length; k++) {
          t[k] ^= u[k];
        }
      }
      dk.addAll(t);
    }
    return base64Encode(dk.sublist(0, dkLen));
  }

  static List<int> _int32BE(int i) => [
        (i >> 24) & 0xff,
        (i >> 16) & 0xff,
        (i >> 8) & 0xff,
        i & 0xff,
      ];

  static String _generateSalt({int length = 16}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789./';
    final rnd = Random.secure();
    return List.generate(length, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  static String _hashPasswordNew(String password, String salt) {
    return _pbkdf2(password, salt);
  }

  // Legacy hash (tanpa salt) untuk kompatibilitas migrasi
  static String _hashPasswordLegacy(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Generate ID unik untuk user
  static String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
  static String _generateSessionToken() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(32, (_) => rnd.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static Future<void> _startSession(String userId) async {
    final token = _generateSessionToken();
    final expiry = DateTime.now().add(const Duration(days: _sessionDays));
    await _sessionBox.put(_keyCurrentUser, userId);
    await _sessionBox.put(_keySessionToken, token);
    await _sessionBox.put(_keySessionExpiry, expiry.toIso8601String());
  }

  static Future<bool> _isSessionValid() async {
    final expiryStr = _sessionBox.get(_keySessionExpiry);
    if (expiryStr == null) return false;
    final expiry = DateTime.tryParse(expiryStr);
    if (expiry == null) return false;
    if (DateTime.now().isAfter(expiry)) {
      await logout();
      return false;
    }
    return true;
  }

  // ===== REGISTER =====
  static Future<Map<String, dynamic>> register({
    required String nama,
    required String username,
    required String password,
    String? noTelepon,
    String? alamat,
  }) async {
    try {
      // Cek apakah username sudah ada
      final existingUser = _usersBox.values.firstWhere(
        (user) => user.username.toLowerCase() == username.toLowerCase(),
        orElse: () => ModelUser(
          id: '',
          nama: '',
          username: '',
          password: '',
          tanggalDaftar: DateTime.now(),
        ),
      );
      
      if (existingUser.id.isNotEmpty) {
        return {'success': false, 'message': 'Username sudah digunakan. Silakan pilih username lain.'};
      }

      final salt = _generateSalt();
      final hash = _hashPasswordNew(password, salt);
      final userBaru = ModelUser(
        id: _generateId(),
        nama: nama,
        username: username.toLowerCase(),
        password: hash,
        salt: salt,
        noTelepon: noTelepon,
        alamat: alamat,
        tanggalDaftar: DateTime.now(),
      );
      
      // Simpan ke Hive
      await _usersBox.put(userBaru.id, userBaru);
      await _startSession(userBaru.id);

      return {'success': true, 'message': 'Registrasi berhasil!', 'user': userBaru};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // ===== LOGIN =====
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      // Cari user berdasarkan username
      ModelUser? user;
      String? userId;
      
      for (var entry in _usersBox.toMap().entries) {
        if (entry.value.username.toLowerCase() == username.toLowerCase()) {
          user = entry.value;
          userId = entry.key;
          break;
        }
      }
      
      if (user == null) {
        return {'success': false, 'message': 'Username atau password salah.'};
      }

      bool valid;
      if (user.isLegacy) {
        // Cek dengan legacy hash
        valid = user.password == _hashPasswordLegacy(password);
        if (valid) {
          // Migrasi: buat salt + hash baru
          final newSalt = _generateSalt();
          final newHash = _hashPasswordNew(password, newSalt);
          user = ModelUser(
            id: user.id,
            nama: user.nama,
            username: user.username,
            password: newHash,
            salt: newSalt,
            noTelepon: user.noTelepon,
            alamat: user.alamat,
            tanggalDaftar: user.tanggalDaftar,
            fotoProfil: user.fotoProfil,
          );
          await _usersBox.put(userId, user);
        }
      } else {
        // Skema baru salted hash
        valid = user.password == _hashPasswordNew(password, user.salt!);
      }

      if (!valid) {
        return {'success': false, 'message': 'Username atau password salah.'};
      }

      await _startSession(user.id);
      return {'success': true, 'message': 'Login berhasil!', 'user': user};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // ===== LOGOUT =====
  static Future<void> logout() async {
    await _sessionBox.delete(_keyCurrentUser);
    await _sessionBox.delete(_keySessionToken);
    await _sessionBox.delete(_keySessionExpiry);
  }

  // ===== SESSION CHECK =====
  static Future<bool> isLoggedIn() async {
    try {
      if (!_sessionBox.containsKey(_keyCurrentUser)) return false;
      return await _isSessionValid();
    } catch (_) {
      return false;
    }
  }

  static Future<ModelUser?> getCurrentUser() async {
    try {
      if (!await isLoggedIn()) return null;
      final userId = _sessionBox.get(_keyCurrentUser);
      if (userId == null) return null;
      return _usersBox.get(userId);
    } catch (_) {
      return null;
    }
  }

  // ===== UPDATE PROFILE =====
  static Future<bool> updateProfile({
    required String userId,
    String? nama,
    String? noTelepon,
    String? alamat,
  }) async {
    try {
      final user = _usersBox.get(userId);
      if (user == null) return false;
      
      final updatedUser = ModelUser(
        id: user.id,
        nama: nama ?? user.nama,
        username: user.username,
        password: user.password,
        salt: user.salt,
        noTelepon: noTelepon ?? user.noTelepon,
        alamat: alamat ?? user.alamat,
        tanggalDaftar: user.tanggalDaftar,
        fotoProfil: user.fotoProfil,
      );
      
      await _usersBox.put(userId, updatedUser);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // ===== UPDATE FOTO PROFIL =====
  static Future<bool> updateFotoProfil({
    required String userId,
    required String fotoBase64,
  }) async {
    try {
      final user = _usersBox.get(userId);
      if (user == null) return false;
      
      final updatedUser = ModelUser(
        id: user.id,
        nama: user.nama,
        username: user.username,
        password: user.password,
        salt: user.salt,
        noTelepon: user.noTelepon,
        alamat: user.alamat,
        tanggalDaftar: user.tanggalDaftar,
        fotoProfil: fotoBase64,
      );
      
      await _usersBox.put(userId, updatedUser);
      return true;
    } catch (e) {
      return false;
    }
  }
}
