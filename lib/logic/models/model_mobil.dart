/// Model data mobil untuk aplikasi HexoCar
class ModelMobil {
  final String id;
  final String nama;
  final String harga;
  final String tahun;
  final String bahanBakar;
  final String transmisi;
  final String gambar;
  final String? deskripsi;
  final String? penjual;
  final String? nomorTelepon;
  final double? latitude;    // Koordinat lokasi penjual
  final double? longitude;   // Koordinat lokasi penjual
  final String? alamat;      // Alamat lengkap penjual

  ModelMobil({
    required this.id,
    required this.nama,
    required this.harga,
    required this.tahun,
    required this.bahanBakar,
    required this.transmisi,
    required this.gambar,
    this.deskripsi,
    this.penjual,
    this.nomorTelepon,
    this.latitude,
    this.longitude,
    this.alamat,
  });

  // Convert to Map untuk penyimpanan
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'tahun': tahun,
      'bahanBakar': bahanBakar,
      'transmisi': transmisi,
      'gambar': gambar,
      'deskripsi': deskripsi,
      'penjual': penjual,
      'nomorTelepon': nomorTelepon,
      'latitude': latitude,
      'longitude': longitude,
      'alamat': alamat,
    };
  }

  // Create dari Map
  factory ModelMobil.fromMap(Map<String, dynamic> map) {
    return ModelMobil(
      id: map['id'] ?? '',
      nama: map['nama'] ?? '',
      harga: map['harga'] ?? '',
      tahun: map['tahun'] ?? '',
      bahanBakar: map['bahanBakar'] ?? '',
      transmisi: map['transmisi'] ?? '',
      gambar: map['gambar'] ?? '',
      deskripsi: map['deskripsi'],
      penjual: map['penjual'],
      nomorTelepon: map['nomorTelepon'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      alamat: map['alamat'],
    );
  }
}
