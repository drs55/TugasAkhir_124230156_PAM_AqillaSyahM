/// Kelas untuk menyimpan data profil pengguna
/// 
/// Gunakan kelas ini untuk menyimpan dan mengelola informasi profil
class DataProfil {
  final String namaLengkap;
  final String nim;
  final String programStudi;
  final String email;
  final String nomorTelepon;
  final String fotoProfil;

  const DataProfil({
    required this.namaLengkap,
    required this.nim,
    required this.programStudi,
    required this.email,
    required this.nomorTelepon,
    this.fotoProfil = 'assets/gambar/1.jpg',
  });

  // Data profil default/contoh
  static const DataProfil contoh = DataProfil(
    namaLengkap: 'Nama Lengkap Anda',
    nim: '1234567890',
    programStudi: 'Teknik Informatika',
    email: 'email@example.com',
    nomorTelepon: '+62 812-3456-7890',
  );

  // Method untuk mengubah data profil
  DataProfil copyWith({
    String? namaLengkap,
    String? nim,
    String? programStudi,
    String? email,
    String? nomorTelepon,
    String? fotoProfil,
  }) {
    return DataProfil(
      namaLengkap: namaLengkap ?? this.namaLengkap,
      nim: nim ?? this.nim,
      programStudi: programStudi ?? this.programStudi,
      email: email ?? this.email,
      nomorTelepon: nomorTelepon ?? this.nomorTelepon,
      fotoProfil: fotoProfil ?? this.fotoProfil,
    );
  }

  // Method untuk konversi ke Map (untuk penyimpanan data)
  Map<String, dynamic> toMap() {
    return {
      'namaLengkap': namaLengkap,
      'nim': nim,
      'programStudi': programStudi,
      'email': email,
      'nomorTelepon': nomorTelepon,
      'fotoProfil': fotoProfil,
    };
  }

  // Method untuk membuat DataProfil dari Map
  factory DataProfil.fromMap(Map<String, dynamic> map) {
    return DataProfil(
      namaLengkap: map['namaLengkap'] ?? '',
      nim: map['nim'] ?? '',
      programStudi: map['programStudi'] ?? '',
      email: map['email'] ?? '',
      nomorTelepon: map['nomorTelepon'] ?? '',
      fotoProfil: map['fotoProfil'] ?? 'assets/gambar/foto_profil.png',
    );
  }
}
