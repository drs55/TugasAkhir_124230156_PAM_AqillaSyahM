import 'package:hive/hive.dart';

part 'model_user.g.dart';

/// Model data user untuk sistem autentikasi dengan dukungan salt.
@HiveType(typeId: 2)
class ModelUser {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String nama;
  
  @HiveField(2)
  final String username; // Username untuk login (unik)
  
  /// Menyimpan hash password (bisa legacy SHA-256 atau salted hash baru)
  @HiveField(3)
  final String password;
  
  /// Salt untuk skema hash baru (null jika masih legacy)
  @HiveField(4)
  final String? salt;
  
  @HiveField(5)
  final String? noTelepon;
  
  @HiveField(6)
  final String? alamat;
  
  @HiveField(7)
  final DateTime tanggalDaftar;
  
  /// Foto profil dalam format base64 string
  @HiveField(8)
  final String? fotoProfil;

  ModelUser({
    required this.id,
    required this.nama,
    required this.username,
    required this.password,
    this.salt,
    this.noTelepon,
    this.alamat,
    required this.tanggalDaftar,
    this.fotoProfil,
  });

  bool get isLegacy => salt == null || salt!.isEmpty;

  // Convert to Map untuk penyimpanan
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'username': username,
      'password': password,
      'salt': salt, // bisa null
      'noTelepon': noTelepon,
      'alamat': alamat,
      'tanggalDaftar': tanggalDaftar.toIso8601String(),
      'fotoProfil': fotoProfil,
    };
  }

  // Create dari Map (akomodasi field salt yang opsional)
  factory ModelUser.fromMap(Map<String, dynamic> map) {
    return ModelUser(
      id: map['id'] ?? '',
      nama: map['nama'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      salt: map['salt'],
      noTelepon: map['noTelepon'],
      alamat: map['alamat'],
      fotoProfil: map['fotoProfil'],
      tanggalDaftar: DateTime.parse(map['tanggalDaftar']),
    );
  }
}
