import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../logic/models/model_mobil.dart';
import '../logic/models/model_transaksi.dart';
import '../logic/services/service_transaksi.dart';
import '../logic/services/service_auth.dart';
import '../logic/services/service_notifikasi.dart';
import '../logic/services/service_konversi_mata_uang.dart';
import '../styles/styles.dart';
import 'halaman_pilih_metode_pembayaran.dart';

class HalamanTransaksi extends StatefulWidget {
  final ModelMobil mobil;
  const HalamanTransaksi({super.key, required this.mobil});

  @override
  State<HalamanTransaksi> createState() => _HalamanTransaksiState();
}

class _HalamanTransaksiState extends State<HalamanTransaksi> with SingleTickerProviderStateMixin {
  String? _metodePembayaran;
  bool _sedangMemproses = false;
  Map<String, double>? _kursIDR;
  String _mataUangTerpilih = 'IDR'; // Default mata uang
  String _opsiPengiriman = 'Ambil di Tempat'; // Default: Ambil di Tempat

  // Timer untuk update waktu real-time
  Timer? _timer;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  // Daftar mata uang yang tersedia
  final List<String> _mataUangTersedia = ['IDR', 'USD', 'JPY', 'MYR'];
  
  // Biaya pengiriman dalam IDR
  final double _biayaPengiriman = 2000000;

  @override
  void initState() {
    super.initState();
    _loadKurs();
    
    // Setup animation controller untuk konversi waktu
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    
    // Start animation pertama kali
    _animationController!.forward();
    
    // Start timer untuk update waktu setiap detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Trigger animation setiap update
          _animationController?.forward(from: 0.0);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _loadKurs() async {
    try {
      final kurs = await ServiceKonversiMataUang.fetchKursIDR();
      setState(() {
        _kursIDR = kurs;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  // Method untuk format angka dengan pemisah ribuan
  String _formatAngka(double angka, String simbolMataUang) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    final angkaFormatted = formatter.format(angka.round());
    return '$simbolMataUang$angkaFormatted';
  }

  // Method untuk format kurs dengan pemisah ribuan
  String _formatKurs(double kurs) {
    // Untuk kurs yang sangat kecil (USD, MYR), tampilkan dengan desimal
    if (kurs < 0.01) {
      return kurs.toStringAsFixed(6);
    }
    // Untuk kurs yang besar, gunakan pemisah ribuan
    final formatter = NumberFormat('#,##0.00', 'id_ID');
    return formatter.format(kurs);
  }

  // Method untuk menghitung total harga (harga mobil + biaya pengiriman jika ada)
  double _hitungTotalHargaIDR() {
    final hargaMobil = double.parse(widget.mobil.harga.replaceAll(RegExp(r'[^\d]'), ''));
    if (_opsiPengiriman == 'Kirim ke Rumah') {
      return hargaMobil + _biayaPengiriman;
    }
    return hargaMobil;
  }

  // Method untuk konversi total harga ke mata uang terpilih
  String _konversiTotalHarga(String mataUang) {
    final totalIDR = _hitungTotalHargaIDR();
    
    if (mataUang == 'IDR') {
      return _formatAngka(totalIDR, 'Rp ');
    }

    if (_kursIDR == null) {
      return _formatAngka(totalIDR, 'Rp ');
    }

    switch (mataUang) {
      case 'USD':
        final kursUSD = _kursIDR!['USD'];
        if (kursUSD != null) {
          final hargaUSD = totalIDR * kursUSD;
          return _formatAngka(hargaUSD, '\$');
        }
        break;
      case 'JPY':
        final kursJPY = _kursIDR!['JPY'];
        if (kursJPY != null) {
          final hargaJPY = totalIDR * kursJPY;
          return _formatAngka(hargaJPY, '¥');
        }
        break;
      case 'MYR':
        final kursMYR = _kursIDR!['MYR'];
        if (kursMYR != null) {
          final hargaMYR = totalIDR * kursMYR;
          return _formatAngka(hargaMYR, 'RM ');
        }
        break;
    }
    
    return _formatAngka(totalIDR, 'Rp ');
  }

  // Method untuk mengkonversi harga ke mata uang yang dipilih
  String _konversiHarga(String hargaIDR, String mataUang) {
    try {
      // Ekstrak angka dari string harga (misal: "Rp 150.000.000" -> 150000000)
      final hargaNumerik = double.parse(hargaIDR.replaceAll(RegExp(r'[^\d]'), ''));

      if (mataUang == 'IDR') {
        return _formatAngka(hargaNumerik, 'Rp ');
      }

      if (_kursIDR == null) {
        return hargaIDR;
      }

      // Konversi menggunakan API: 1 IDR = X mata uang lain
      // Jadi: harga_dalam_mata_uang = harga_IDR * kurs
      switch (mataUang) {
        case 'USD':
          final kursUSD = _kursIDR!['USD'];
          if (kursUSD != null) {
            final hargaUSD = hargaNumerik * kursUSD;
            return _formatAngka(hargaUSD, '\$');
          }
          break;
        case 'JPY':
          final kursJPY = _kursIDR!['JPY'];
          if (kursJPY != null) {
            final hargaJPY = hargaNumerik * kursJPY;
            return _formatAngka(hargaJPY, '¥');
          }
          break;
        case 'MYR':
          final kursMYR = _kursIDR!['MYR'];
          if (kursMYR != null) {
            final hargaMYR = hargaNumerik * kursMYR;
            return _formatAngka(hargaMYR, 'RM ');
          }
          break;
      }
    } catch (e) {
      // Jika konversi gagal, kembalikan harga asli
    }

    return hargaIDR;
  }

  // Method untuk format waktu ke string HH:MM:SS
  String _formatWaktu(DateTime waktu) {
    return '${waktu.hour.toString().padLeft(2, '0')}:${waktu.minute.toString().padLeft(2, '0')}:${waktu.second.toString().padLeft(2, '0')}';
  }

  // Konversi zona timezone ke label user-friendly
  String _getLabelZona(String zona) {
    switch (zona) {
      case 'WIB':
        return 'WIB';
      case 'WITA':
        return 'WITA';
      case 'WIT':
        return 'WIT';
      case 'London':
        return 'London';
      default:
        return zona;
    }
  }

  // Get offset jam berdasarkan zona (dari WIB = UTC+7)
  int _getOffsetFromWIB(String zona) {
    switch (zona) {
      case 'WIB':
        return 0;  // WIB = UTC+7, offset dari WIB = 0
      case 'WITA':
        return 1;  // WITA = UTC+8, offset dari WIB = +1
      case 'WIT':
        return 2;  // WIT = UTC+9, offset dari WIB = +2
      case 'London':
        return -7; // London = UTC+0, offset dari WIB = -7
      default:
        return 0;
    }
  }

  // Widget untuk menampilkan waktu di header (dengan background putih transparan)
  Widget _buildWaktuHeader(String zona) {
    // Gunakan waktu lokal + offset
    final now = DateTime.now();
    final offset = _getOffsetFromWIB(zona);
    final waktuZona = now.add(Duration(hours: offset));

    final waktuWidget = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            _getLabelZona(zona),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatWaktu(waktuZona),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
    
    // Jika animasi sudah diinisialisasi, gunakan FadeTransition
    if (_fadeAnimation != null) {
      return FadeTransition(
        opacity: _fadeAnimation!,
        child: waktuWidget,
      );
    }
    
    // Fallback jika belum diinisialisasi
    return waktuWidget;
  }

  Future<void> _pilihMetodePembayaran() async {
    final metode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const HalamanPilihMetodePembayaran(),
      ),
    );

    if (metode != null) {
      setState(() {
        _metodePembayaran = metode;
      });
    }
  }

  Future<void> _konfirmasiPembelian() async {
    if (_metodePembayaran == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih metode pembayaran terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _sedangMemproses = true;
    });

    try {
      // Dapatkan data user saat ini
      final currentUser = await ServiceAuth.getCurrentUser();
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User tidak ditemukan. Silakan login kembali.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Buat transaksi baru
      final transaksi = ModelTransaksi(
        id: ServiceTransaksi.generateIdTransaksi(),
        idMobil: widget.mobil.id,
        namaMobil: widget.mobil.nama,
        hargaMobil: widget.mobil.harga,
        namaPembeli: currentUser.nama,
        emailPembeli: currentUser.username, // Menggunakan username sebagai email
        nomorTelepon: currentUser.noTelepon ?? '',
        metodePembayaran: _metodePembayaran!,
        mataUang: _mataUangTerpilih,
        jumlahPembayaran: _konversiTotalHarga(_mataUangTerpilih),
        tanggalTransaksi: DateTime.now(),
        status: 'Berhasil',
        opsiPengiriman: _opsiPengiriman,
        biayaPengiriman: _opsiPengiriman == 'Kirim ke Rumah' 
            ? _konversiHarga('Rp ${_biayaPengiriman.toStringAsFixed(0)}', _mataUangTerpilih)
            : null,
      );

      // Simpan transaksi
      await ServiceTransaksi.simpanTransaksi(transaksi);

      // Kirim notifikasi
      await ServiceNotifikasi.tampilkanNotifikasiPembelian(
        namaMobil: widget.mobil.nama,
        harga: widget.mobil.harga,
      );

      // Tampilkan dialog sukses
      _tampilkanDialogSukses();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _sedangMemproses = false;
      });
    }
  }

  void _tampilkanDialogSukses() async {
    // Ambil data user untuk ditampilkan di struk
    final currentUser = await ServiceAuth.getCurrentUser();
    
    final tanggalSekarang = DateTime.now();
    final formatTanggal = '${tanggalSekarang.day}/${tanggalSekarang.month}/${tanggalSekarang.year}';
    final formatJam = '${tanggalSekarang.hour.toString().padLeft(2, '0')}:${tanggalSekarang.minute.toString().padLeft(2, '0')}';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Ambil tinggi layar
            final maxHeight = MediaQuery.of(context).size.height * 0.9;
            
            return Container(
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: maxHeight,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFF5F5F5)],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header dengan gradient (tetap di atas, tidak ikut scroll)
                  Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pembelian Berhasil!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Transaksi Anda telah diproses',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Body - Detail Struk (scrollable)
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Divider dengan style
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'DETAIL TRANSAKSI',
                                style: TextStyle(
                                  fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Info Mobil
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2193b0).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF2193b0).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2193b0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.directions_car,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mobil',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.mobil.nama,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2193b0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Detail Pembayaran
                    _buildStrukRow('Tanggal', formatTanggal, Icons.calendar_today),
                    _buildStrukRow('Waktu', formatJam, Icons.access_time),
                    
                    const SizedBox(height: 12),
                    Divider(color: Colors.grey[300], thickness: 1),
                    const SizedBox(height: 12),
                    
                    // Detail Pembeli
                    if (currentUser != null) ...[
                      Row(
                        children: [
                          Icon(Icons.person, size: 20, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'DATA PEMBELI',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildStrukRow('Nama', currentUser.nama, Icons.account_circle),
                      _buildStrukRow('Username', currentUser.username, Icons.alternate_email),
                      if (currentUser.noTelepon != null && currentUser.noTelepon!.isNotEmpty)
                        _buildStrukRow('Telepon', currentUser.noTelepon!, Icons.phone),
                      
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey[300], thickness: 1),
                      const SizedBox(height: 12),
                    ],
                    
                    // Detail Transaksi
                    Row(
                      children: [
                        Icon(Icons.receipt_long, size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'DETAIL PEMBAYARAN',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStrukRow('Harga Mobil', _konversiHarga(widget.mobil.harga, _mataUangTerpilih), Icons.directions_car),
                    if (_opsiPengiriman == 'Kirim ke Rumah')
                      _buildStrukRow('Jasa Kirim', _konversiHarga('Rp ${_biayaPengiriman.toStringAsFixed(0)}', _mataUangTerpilih), Icons.local_shipping),
                    _buildStrukRow('Opsi Pengiriman', _opsiPengiriman, Icons.delivery_dining),
                    
                    const SizedBox(height: 12),
                    Divider(color: Colors.grey[300], thickness: 1),
                    const SizedBox(height: 12),
                    
                    // Info Transaksi
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'INFO TRANSAKSI',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStrukRow('Metode Pembayaran', _metodePembayaran!, Icons.payment),
                    _buildStrukRow('Mata Uang', _mataUangTerpilih, Icons.currency_exchange),
                    _buildStrukRow('Status', 'Berhasil', Icons.check_circle, valueColor: Colors.green),
                    
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey[300], thickness: 1),
                    const SizedBox(height: 16),
                    
                    // Total dengan highlight
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2193b0).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'TOTAL PEMBAYARAN',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _konversiTotalHarga(_mataUangTerpilih),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Tutup dialog
                          Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
                          Navigator.of(context).pop(); // Kembali ke halaman beranda
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2193b0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Kembali ke Beranda',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
          },
        ),
      ),
    );
  }
  
  Widget _buildStrukRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
              textAlign: TextAlign.right,
              maxLines: 3,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Pembelian'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_cart, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ringkasan Pembelian',
                          style: AppTextStyles.headline5.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Konversi Waktu Real-time
                  Row(
                    children: [
                      Expanded(child: _buildWaktuHeader('WIB')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildWaktuHeader('WITA')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildWaktuHeader('WIT')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildWaktuHeader('London')),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Detail Mobil
            _buildDetailMobil(),

            const SizedBox(height: 24),

            // Metode Pembayaran
            _buildMetodePembayaran(),

            const SizedBox(height: 24),

            // Pemilihan Mata Uang
            _buildPemilihanMataUang(),

            const SizedBox(height: 24),

            // Opsi Pengiriman
            _buildOpsiPengiriman(),

            const SizedBox(height: 24),

            // Ringkasan Harga
            _buildRingkasanHarga(),

            const SizedBox(height: 32),

            // Tombol Konfirmasi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sedangMemproses ? null : _konfirmasiPembelian,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _metodePembayaran != null ? AppColors.primary : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _sedangMemproses
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Konfirmasi Pembelian',
                        style: AppTextStyles.button,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailMobil() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.directions_car, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Detail Mobil', style: AppTextStyles.headline6),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Nama Mobil', widget.mobil.nama),
            _buildInfoRow('Tahun', widget.mobil.tahun.toString()),
            _buildInfoRow('Bahan Bakar', widget.mobil.bahanBakar),
            _buildInfoRow('Transmisi', widget.mobil.transmisi),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Harga Mobil',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.mobil.harga,
                    style: AppTextStyles.price.copyWith(fontSize: 22),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetodePembayaran() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.payment, color: Colors.green.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Metode Pembayaran', style: AppTextStyles.headline6),
              ],
            ),
            const Divider(height: 24),
            if (_metodePembayaran == null)
              InkWell(
                onTap: _pilihMetodePembayaran,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: Colors.grey.shade500, size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pilih Metode Pembayaran',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap untuk memilih metode',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 18),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade50,
                      Colors.green.shade100.withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.green.shade300, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_getMetodeIcon(_metodePembayaran!), color: Colors.green.shade700, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Metode Terpilih',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _metodePembayaran!,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _pilihMetodePembayaran,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Ubah'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpsiPengiriman() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.local_shipping_outlined, color: Colors.black87, size: 22),
                const SizedBox(width: 12),
                Text('Metode Pengiriman', style: AppTextStyles.headline6),
              ],
            ),
            const SizedBox(height: 16),
            
            // Opsi 1: Ambil di Tempat
            InkWell(
              onTap: () {
                setState(() {
                  _opsiPengiriman = 'Ambil di Tempat';
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _opsiPengiriman == 'Ambil di Tempat' 
                        ? Colors.green.shade400 
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: _opsiPengiriman == 'Ambil di Tempat'
                      ? Colors.green.shade50
                      : Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(
                      _opsiPengiriman == 'Ambil di Tempat'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: _opsiPengiriman == 'Ambil di Tempat'
                          ? Colors.green.shade700
                          : Colors.grey.shade400,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ambil di Tempat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _opsiPengiriman == 'Ambil di Tempat'
                                  ? Colors.black87
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gratis - Ambil mobil langsung di lokasi',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'GRATIS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Opsi 2: Kirim ke Rumah
            InkWell(
              onTap: () {
                setState(() {
                  _opsiPengiriman = 'Kirim ke Rumah';
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _opsiPengiriman == 'Kirim ke Rumah' 
                        ? Colors.green.shade400 
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: _opsiPengiriman == 'Kirim ke Rumah'
                      ? Colors.green.shade50
                      : Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(
                      _opsiPengiriman == 'Kirim ke Rumah'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: _opsiPengiriman == 'Kirim ke Rumah'
                          ? Colors.green.shade700
                          : Colors.grey.shade400,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kirim ke Rumah',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _opsiPengiriman == 'Kirim ke Rumah'
                                  ? Colors.black87
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Mobil dikirim ke alamat Anda',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '+Rp 2.000.000',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPemilihanMataUang() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.currency_exchange, color: Colors.blue.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Mata Uang', style: AppTextStyles.headline6),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pilih Mata Uang Pembayaran',
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue.shade300, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade100,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButton<String>(
                    value: _mataUangTerpilih,
                    underline: const SizedBox(),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                    items: _mataUangTersedia.map((mataUang) {
                      return DropdownMenuItem<String>(
                        value: mataUang,
                        child: Text(
                          mataUang,
                          style: TextStyle(
                            color: mataUang == _mataUangTerpilih ? Colors.blue.shade700 : Colors.grey.shade700,
                            fontWeight: mataUang == _mataUangTerpilih ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _mataUangTerpilih = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            if (_kursIDR != null && _mataUangTerpilih != 'IDR') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kurs: 1 IDR = ${_formatKurs(_kursIDR![_mataUangTerpilih] ?? 0)} $_mataUangTerpilih',
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRingkasanHarga() {
    final hargaDalamMataUang = _konversiHarga(widget.mobil.harga, _mataUangTerpilih);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.receipt_long, color: Colors.orange.shade700, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text('Ringkasan Pembayaran', style: AppTextStyles.headline6),
                ],
              ),
              const Divider(height: 24),
              _buildHargaRow('Harga Mobil ($_mataUangTerpilih)', hargaDalamMataUang),
              
              // Tampilkan biaya pengiriman jika opsi Kirim ke Rumah
              if (_opsiPengiriman == 'Kirim ke Rumah') ...[
                const SizedBox(height: 12),
                _buildHargaRow(
                  'Biaya Pengiriman ($_mataUangTerpilih)', 
                  _konversiHarga('Rp ${_biayaPengiriman.toStringAsFixed(0)}', _mataUangTerpilih),
                ),
              ],
              
              if (_kursIDR != null && _mataUangTerpilih != 'IDR') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, color: Colors.orange.shade700, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Kurs: 1 IDR = ${_formatKurs(_kursIDR![_mataUangTerpilih] ?? 0)} $_mataUangTerpilih',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.05),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Total ($_mataUangTerpilih)',
                        style: AppTextStyles.headline6.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _konversiTotalHarga(_mataUangTerpilih),
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMetodeIcon(String metode) {
    // Bank Transfer
    if (['BRI', 'BCA', 'BNI', 'Mandiri'].contains(metode)) {
      return Icons.account_balance;
    }
    // E-Wallet
    return Icons.account_balance_wallet;
  }

  // Helper method untuk menampilkan info row (label: value)
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade600)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  // Helper method untuk menampilkan baris harga
  Widget _buildHargaRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: isTotal ? AppTextStyles.headline6 : AppTextStyles.bodyLarge),
        Text(value, style: isTotal ? AppTextStyles.price : AppTextStyles.bodyLarge),
      ],
    );
  }
}
