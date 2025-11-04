import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/model_mobil.dart';
import '../../models/model_transaksi.dart';
import '../../models/services/service_transaksi.dart';
import '../../models/services/service_konversi_mata_uang.dart';
import '../../models/services/service_notifikasi.dart';

// ============================================================================
// 🖥️ SCREEN/UI - Halaman Detail & Beli Mobil
// ============================================================================
class HalamanBeliMobil extends StatefulWidget {
  final ModelMobil mobil;

  const HalamanBeliMobil({super.key, required this.mobil});

  @override
  State<HalamanBeliMobil> createState() => _HalamanBeliMobilState();
}

// ============================================================================
// 🎮 CONTROLLER/LOGIC - State management untuk Beli Mobil
// ============================================================================
class _HalamanBeliMobilState extends State<HalamanBeliMobil> with SingleTickerProviderStateMixin {
  // --- Form Controllers ---
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();

  // --- State Variables ---
  String _mataUangTerpilih = 'IDR';
  Map<String, double>? _rates; // rates where key e.g. 'USD' gives amount of that currency per 1 IDR (from exchangerate.host when base=IDR)
  bool _ratesLoading = true;
  String? _ratesError;
  
  // Timer untuk update waktu real-time
  Timer? _timer;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  
  // --- Lifecycle Methods ---
  @override
  void initState() {
    super.initState();
    // Setup animation controller
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

    // Load live exchange rates (async)
    _loadRates();
  }

  // --- CONTROLLER METHOD: Load Exchange Rates ---
  Future<void> _loadRates() async {
    setState(() {
      _ratesLoading = true;
      _ratesError = null;
    });

    try {
      final fetched = await ServiceKonversiMataUang.fetchKursIDR();
      if (mounted) {
        setState(() {
          _rates = fetched; // rates: amount of foreign currency per 1 IDR
          _ratesLoading = false;
        });
      }
    } catch (e) {
      final st = StackTrace.current;
      if (mounted) {
        setState(() {
          _ratesError = '$e\n$st';
          _ratesLoading = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _animationController?.dispose();
    _namaController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengambil harga dalam angka (hapus Rp dan titik)
  double _getHargaNumerik() {
    String hargaString = widget.mobil.harga
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .trim();
    return double.tryParse(hargaString) ?? 0;
  }

  // Konversi mata uang menggunakan API
  String _konversiMataUang(String kode) {
    double hargaIDR = _getHargaNumerik();
    double hasil;
    String simbol;
    
    // Untuk IDR, langsung return
    if (kode == 'IDR') {
      final intVal = hargaIDR.round();
      final s = intVal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
      return 'Rp $s';
    }
    
    // Gunakan rates dari API
    if (_rates?.containsKey(kode) ?? false) {
      final rate = _rates![kode]!; // rate = jumlah mata uang asing per 1 IDR
      hasil = hargaIDR * rate;
    } else {
      // Jika API belum tersedia, tampilkan "Loading..."
      if (_ratesLoading) {
        return 'Loading...';
      }
      // Jika error, tampilkan pesan error
      if (_ratesError != null) {
        return 'Error';
      }
      // Fallback jika tidak ada data
      return 'N/A';
    }

    switch (kode) {
      case 'JPY':
        simbol = '¥';
        break;
      case 'USD':
        simbol = '\$';
        break;
      case 'MYR':
        simbol = 'RM';
        break;
      default:
        simbol = 'Rp';
    }

    // Format dengan 2 decimals untuk mata uang asing
    final s = hasil.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    return '$simbol $s';
  }

  // Format waktu ke string HH:MM:SS
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

  Widget _buildWaktu(String zona) {
    // Gunakan waktu lokal + offset
    final now = DateTime.now();
    final offset = _getOffsetFromWIB(zona);
    final waktuZona = now.add(Duration(hours: offset));

    final waktuWidget = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2193b0).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            _getLabelZona(zona),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2193b0),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatWaktu(waktuZona),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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

  // --- CONTROLLER METHOD: Proses Pembelian dengan Validasi Form ---
  void _prosesPembelian() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            backgroundColor: const Color(0xFFF4F7F9),
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Title + Icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.shopping_cart, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Konfirmasi Pembelian',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .3,
                              color: Color(0xFF1D2B33),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Info blok
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2ECF2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DialogInfoRow(label: 'Mobil', value: widget.mobil.nama),
                          _DialogInfoRow(label: 'Harga', value: widget.mobil.harga),
                          const SizedBox(height: 10),
                          const Divider(height: 24),
                          _DialogInfoRow(label: 'Pembeli', value: _namaController.text),
                          if (_teleponController.text.trim().isNotEmpty)
                            _DialogInfoRow(label: 'Telepon', value: _teleponController.text),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Warning / note
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.info_outline, size: 18, color: Color(0xFF2193b0)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pastikan data sudah benar sebelum melanjutkan. Transaksi tidak dapat dibatalkan setelah dikonfirmasi.',
                            style: TextStyle(fontSize: 12.5, color: Color(0xFF445963), height: 1.25),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Tombol aksi
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF546E7A),
                              side: const BorderSide(color: Color(0xFFB0C4CF)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              // Simpan transaksi ke Hive
                              final transaksi = ModelTransaksi(
                                id: ServiceTransaksi.generateIdTransaksi(),
                                idMobil: widget.mobil.id,
                                namaMobil: widget.mobil.nama,
                                hargaMobil: widget.mobil.harga,
                                namaPembeli: _namaController.text,
                                emailPembeli: '', // Bisa diambil dari session login
                                nomorTelepon: _teleponController.text,
                                metodePembayaran: 'Transfer Bank', // Default
                                mataUang: _mataUangTerpilih,
                                jumlahPembayaran: _konversiMataUang(_mataUangTerpilih),
                                tanggalTransaksi: DateTime.now(),
                                status: 'Completed',
                                catatan: _alamatController.text.isNotEmpty 
                                    ? 'Alamat: ${_alamatController.text}' 
                                    : null,
                              );
                              
                              await ServiceTransaksi.simpanTransaksi(transaksi);
                              
                              // Hitung total transaksi user
                              final allTransaksi = ServiceTransaksi.getRiwayatTransaksi();
                              final jumlahTransaksi = allTransaksi.length;
                              
                              Navigator.pop(context); // close dialog
                              Navigator.pop(context); // back
                              
                              // Cek apakah kelipatan 2
                              if (jumlahTransaksi % 2 == 0) {
                                // Notifikasi special untuk kelipatan 2 (Local Notification)
                                await ServiceNotifikasi.tampilkanNotifikasiPencapaian(
                                  jumlahMobil: jumlahTransaksi,
                                  namaMobil: widget.mobil.nama,
                                );
                              } else {
                                // Notifikasi pembelian biasa (Local Notification)
                                await ServiceNotifikasi.tampilkanNotifikasiPembelian(
                                  namaMobil: widget.mobil.nama,
                                  harga: widget.mobil.harga,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFF2193b0),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Konfirmasi',
                              style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: .3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  // ============================================================================
  // 🖥️ SCREEN/UI - Widget Build Method (Tampilan)
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Form Pembelian Mobil'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          // Tombol Test Notifikasi
          IconButton(
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Test Notifikasi',
            onPressed: () async {
              // Simulasi notifikasi kelipatan 2
              final jumlahTransaksi = ServiceTransaksi.getRiwayatTransaksi().length;
              await ServiceNotifikasi.tampilkanNotifikasiTest(
                jumlahTransaksi: jumlahTransaksi,
                isKelipatan2: jumlahTransaksi % 2 == 0,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Detail Mobil
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Mobil
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.mobil.gambar.startsWith('http://') || widget.mobil.gambar.startsWith('https://')
                        ? Image.network(
                            widget.mobil.gambar,
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: double.infinity,
                                height: 150,
                                color: Colors.grey[300],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 150,
                                color: Colors.grey[300],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.directions_car, size: 50, color: Colors.grey[600]),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Gambar tidak tersedia',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : widget.mobil.gambar.startsWith('assets/')
                            ? Image.asset(
                                widget.mobil.gambar,
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,
                              )
                            : Image.memory(
                                base64Decode(widget.mobil.gambar),
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.mobil.nama,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(widget.mobil.tahun),
                      const SizedBox(width: 16),
                      Icon(Icons.local_gas_station, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(widget.mobil.bahanBakar),
                      const SizedBox(width: 16),
                      Icon(Icons.settings, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(widget.mobil.transmisi),
                    ],
                  ),
                  // Tambahkan Deskripsi jika ada
                  if (widget.mobil.deskripsi != null && widget.mobil.deskripsi!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.mobil.deskripsi!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Konversi Mata Uang
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💱 Konversi Mata Uang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Status / hint about rates
                  if (_ratesLoading)
                    Row(
                      children: const [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Memuat kurs terkini...'),
                      ],
                    )
                  else if (_ratesError != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 18),
                            const SizedBox(width: 8),
                            const Flexible(child: Text('Offline: menggunakan fallback kurs lokal')), 
                          ],
                        ),
                        TextButton(
                          onPressed: _loadRates,
                          child: const Text('Retry'),
                        ),
                      ],
                    )
                  else
                    const Text('Kurs terkini terpasang'),

                  const SizedBox(height: 8),
                  _buildKonversiItem('Rupiah (IDR)', _konversiMataUang('IDR'), 'IDR'),
                  _buildKonversiItem('Yen Jepang (JPY)', _konversiMataUang('JPY'), 'JPY'),
                  _buildKonversiItem('Dolar AS (USD)', _konversiMataUang('USD'), 'USD'),
                  _buildKonversiItem('Ringgit (MYR)', _konversiMataUang('MYR'), 'MYR'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // Konversi Waktu
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🕐 Waktu Transaksi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildWaktu('WIB')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildWaktu('WITA')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildWaktu('WIT')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildWaktu('London')),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Lokasi Penjual
            if (widget.mobil.latitude != null && widget.mobil.longitude != null)
              _buildLokasiPenjual(),

            const SizedBox(height: 16),

            // Form Data Pembeli
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📋 Data Pembeli',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _teleponController,
                      decoration: InputDecoration(
                        labelText: 'No. Telepon',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor telepon harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _alamatController,
                      decoration: InputDecoration(
                        labelText: 'Alamat Lengkap',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat harus diisi';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Beli
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _prosesPembelian,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2193b0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Proses Pembelian',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLokasiPenjual() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📍 Lokasi Penjual',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Map Placeholder dengan koordinat
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue[50]!,
                  Colors.blue[100]!,
                ],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 48,
                        color: Colors.red[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.mobil.nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lat: ${widget.mobil.latitude?.toStringAsFixed(4)}, Lng: ${widget.mobil.longitude?.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Alamat
          if (widget.mobil.alamat != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.mobil.alamat!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Tombol Buka di Google Maps
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _bukaGoogleMaps,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.directions, color: Colors.white),
              label: const Text(
                'Buka di Google Maps',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CONTROLLER METHOD: Buka Google Maps dengan Koordinat ---
  Future<void> _bukaGoogleMaps() async {
    final lat = widget.mobil.latitude;
    final lng = widget.mobil.longitude;
    
    if (lat == null || lng == null) return;
    
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka Google Maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildKonversiItem(String nama, String nilai, String kode) {
    bool isSelected = _mataUangTerpilih == kode;
    return InkWell(
      onTap: () {
        setState(() {
          _mataUangTerpilih = kode;
        });
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2193b0).withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? const Color(0xFF2193b0) : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nama,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? const Color(0xFF2193b0) : Colors.black87,
            ),
          ),
          Text(
            nilai,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFF2193b0) : Colors.black87,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// Baris informasi label : value untuk dialog konfirmasi
class _DialogInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _DialogInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF35505D),
              ),
            ),
          ),
          const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1D2B33),
                  height: 1.25,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
