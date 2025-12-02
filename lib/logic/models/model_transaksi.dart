import 'package:hive/hive.dart';

part 'model_transaksi.g.dart';

/// Model untuk riwayat transaksi pembelian mobil
@HiveType(typeId: 1)
class ModelTransaksi extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String idMobil;
  
  @HiveField(2)
  final String namaMobil;
  
  @HiveField(3)
  final String hargaMobil;
  
  @HiveField(4)
  final String namaPembeli;
  
  @HiveField(5)
  final String emailPembeli;
  
  @HiveField(6)
  final String nomorTelepon;
  
  @HiveField(7)
  final String metodePembayaran;
  
  @HiveField(8)
  final String? mataUang; // IDR, USD, JPY, MYR
  
  @HiveField(9)
  final String? jumlahPembayaran; // Jumlah yang dibayar dalam mata uang terpilih
  
  @HiveField(10)
  final DateTime tanggalTransaksi;
  
  @HiveField(11)
  final String status; // Pending, Completed, Cancelled
  
  @HiveField(12)
  final String? catatan;
  
  @HiveField(13)
  final String? opsiPengiriman; // Ambil di Tempat, Kirim ke Rumah
  
  @HiveField(14)
  final String? biayaPengiriman; // Biaya pengiriman jika ada

  ModelTransaksi({
    required this.id,
    required this.idMobil,
    required this.namaMobil,
    required this.hargaMobil,
    required this.namaPembeli,
    required this.emailPembeli,
    required this.nomorTelepon,
    required this.metodePembayaran,
    this.mataUang,
    this.jumlahPembayaran,
    required this.tanggalTransaksi,
    this.status = 'Completed',
    this.catatan,
    this.opsiPengiriman,
    this.biayaPengiriman,
  });

  // Convert to Map untuk export/sharing
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idMobil': idMobil,
      'namaMobil': namaMobil,
      'hargaMobil': hargaMobil,
      'namaPembeli': namaPembeli,
      'emailPembeli': emailPembeli,
      'nomorTelepon': nomorTelepon,
      'metodePembayaran': metodePembayaran,
      'mataUang': mataUang,
      'jumlahPembayaran': jumlahPembayaran,
      'tanggalTransaksi': tanggalTransaksi.toIso8601String(),
      'status': status,
      'catatan': catatan,
      'opsiPengiriman': opsiPengiriman,
      'biayaPengiriman': biayaPengiriman,
    };
  }

  // Create dari Map
  factory ModelTransaksi.fromMap(Map<String, dynamic> map) {
    return ModelTransaksi(
      id: map['id'] ?? '',
      idMobil: map['idMobil'] ?? '',
      namaMobil: map['namaMobil'] ?? '',
      hargaMobil: map['hargaMobil'] ?? '',
      namaPembeli: map['namaPembeli'] ?? '',
      emailPembeli: map['emailPembeli'] ?? '',
      nomorTelepon: map['nomorTelepon'] ?? '',
      metodePembayaran: map['metodePembayaran'] ?? '',
      mataUang: map['mataUang'],
      jumlahPembayaran: map['jumlahPembayaran'],
      tanggalTransaksi: DateTime.parse(map['tanggalTransaksi']),
      status: map['status'] ?? 'Completed',
      catatan: map['catatan'],
      opsiPengiriman: map['opsiPengiriman'],
      biayaPengiriman: map['biayaPengiriman'],
    );
  }
}
