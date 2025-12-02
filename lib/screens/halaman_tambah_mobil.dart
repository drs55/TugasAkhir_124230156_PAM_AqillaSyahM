import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../logic/models/model_mobil.dart';
import '../logic/services/service_mobil.dart';
import 'package:intl/intl.dart';

// ============================================================================
// 🖥️ SCREEN/UI - StatefulWidget untuk tampilan halaman tambah mobil
// ============================================================================
class HalamanTambahMobil extends StatefulWidget {
  const HalamanTambahMobil({super.key});

  @override
  State<HalamanTambahMobil> createState() => _HalamanTambahMobilState();
}

// ============================================================================
// ?? CONTROLLER/LOGIC - State management dan business logic
// ============================================================================
class _HalamanTambahMobilState extends State<HalamanTambahMobil> {
  // --- Form Controllers ---
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _tahunController = TextEditingController();
  final _deskripsiController = TextEditingController();

  // --- State Variables ---
  String _bahanBakarTerpilih = 'Bensin';
  String _transmisiTerpilih = 'Manual';
  XFile? _gambarTerpilih; // Menyimpan gambar yang dipilih
  Uint8List? _bytesGambar; // Menyimpan bytes gambar untuk preview
  final ImagePicker _picker = ImagePicker();
  
  // --- Location data ---
  double? _latitude;
  double? _longitude;
  String? _alamat;
  bool _sedangMengambilLokasi = false;
  bool _sedangRefine = false;
  double? _akurasiMeter; // menyimpan akurasi terakhir

  // --- CONTROLLER METHOD: Refinement Akurasi GPS ---
  // Refinement: kumpulkan banyak sample untuk meningkatkan akurasi maksimal
  Future<void> _refineAkurasiLokasi() async {
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ambil lokasi dulu sebelum perbaiki akurasi')),
      );
      return;
    }
    setState(() => _sedangRefine = true);
    
    try {
      final samples = <Position>[];
      
      // Ambil 8 sample dengan jeda untuk stabilitas GPS
      for (int i = 0; i < 8; i++) {
        try {
          final p = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.bestForNavigation,
            timeLimit: const Duration(seconds: 10),
          );
          samples.add(p);
          await Future.delayed(const Duration(milliseconds: 600));
        } catch (e) {
          // Skip sample yang gagal
        }
      }

      if (samples.isEmpty) {
        throw Exception('Tidak dapat mengumpulkan sample lokasi');
      }

      // Sort berdasarkan akurasi terbaik
      samples.sort((a, b) => a.accuracy.compareTo(b.accuracy));
      
      // Ambil 5 sample terbaik (buang outlier)
      final bestSamples = samples.take(5).toList();
      
      // Hitung rata-rata weighted berdasarkan akurasi (semakin akurat, semakin besar bobotnya)
      double totalWeight = 0;
      double weightedLat = 0;
      double weightedLng = 0;
      
      for (var sample in bestSamples) {
        // Weight = 1 / akurasi (semakin kecil akurasi, semakin besar weight)
        final weight = 1 / (sample.accuracy + 1);
        weightedLat += sample.latitude * weight;
        weightedLng += sample.longitude * weight;
        totalWeight += weight;
      }
      
      final refinedLat = weightedLat / totalWeight;
      final refinedLng = weightedLng / totalWeight;
      final bestAccuracy = bestSamples.first.accuracy;
      
      setState(() {
        _latitude = refinedLat;
        _longitude = refinedLng;
        _akurasiMeter = bestAccuracy;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('? Akurasi ditingkatkan! Presisi: ${bestAccuracy.toStringAsFixed(1)} m'),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal refine: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _sedangRefine = false);
    }
  }

  // --- Data untuk Dropdown ---
  final List<String> _pilihanBahanBakar = [
    'Bensin',
    'Diesel',
    'Hybrid',
    'Elektrik'
  ];

  final List<String> _pilihanTransmisi = [
    'Manual',
    'Automatic',
    'CVT',
  ];

  // --- Lifecycle Methods ---
  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _tahunController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  // --- CONTROLLER METHOD: Format Harga ---
  // Formatter untuk harga dengan pemisah ribuan
  String _formatHarga(String value) {
    if (value.isEmpty) return value;
    
    // Hapus semua karakter selain angka
    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanValue.isEmpty) return '';
    
    // Parse ke int
    final number = int.tryParse(cleanValue);
    if (number == null) return '';
    
    // Format dengan titik pemisah ribuan
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(number).replaceAll(',', '.');
  }

  // --- CONTROLLER METHOD: Pilih Gambar ---
  // Method untuk memilih gambar dari laptop
  Future<void> _pilihGambar() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Kompres gambar untuk menghemat storage
      );

      if (image != null) {
        // Baca bytes gambar untuk preview
        final bytes = await image.readAsBytes();
        
        setState(() {
          _gambarTerpilih = image;
          _bytesGambar = bytes;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gambar berhasil dipilih!'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih gambar: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // --- CONTROLLER METHOD: Ambil Lokasi GPS ---
  // Method untuk mengambil lokasi saat ini dengan akurasi tinggi
  Future<void> _ambilLokasiSaatIni() async {
    setState(() {
      _sedangMengambilLokasi = true;
    });

    try {
      // Cek apakah service lokasi aktif
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi non-aktif. Aktifkan GPS / Location Services.');
      }

      // Cek permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak permanen. Mohon aktifkan di pengaturan.');
      }

      // Ambil beberapa sample untuk akurasi lebih baik
      List<Position> samples = [];
      
      // Ambil 3 sample dengan jeda
      for (int i = 0; i < 3; i++) {
        try {
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.bestForNavigation,
            timeLimit: const Duration(seconds: 10),
          );
          samples.add(pos);
          if (i < 2) await Future.delayed(const Duration(milliseconds: 800));
        } catch (e) {
          // Skip jika gagal, lanjut ke sample berikutnya
        }
      }

      if (samples.isEmpty) {
        throw Exception('Tidak dapat memperoleh lokasi. Pastikan GPS aktif.');
      }

      // Filter outlier (buang data yang terlalu jauh dari median)
      samples.sort((a, b) => a.accuracy.compareTo(b.accuracy));
      final bestSamples = samples.take(2).toList(); // Ambil 2 terbaik berdasarkan akurasi

      // Hitung rata-rata dari sample terbaik
      final avgLat = bestSamples.map((e) => e.latitude).reduce((a, b) => a + b) / bestSamples.length;
      final avgLng = bestSamples.map((e) => e.longitude).reduce((a, b) => a + b) / bestSamples.length;
      final bestAccuracy = bestSamples.first.accuracy;

      // Konversi koordinat ke alamat
      List<Placemark> placemarks = [];
      try {
        placemarks = await placemarkFromCoordinates(avgLat, avgLng);
      } catch (geoErr) {
        // Tidak fatal � kita tetap simpan koordinat meskipun alamat gagal.
      }

      String alamatLengkap = '';
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        if (place.street != null && place.street!.isNotEmpty) {
          alamatLengkap += '${place.street}, ';
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          alamatLengkap += '${place.subLocality}, ';
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          alamatLengkap += '${place.locality}, ';
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          alamatLengkap += place.administrativeArea!;
        }
      }

      setState(() {
        _latitude = avgLat;
        _longitude = avgLng;
        _alamat = alamatLengkap.isNotEmpty ? alamatLengkap : 'Alamat tidak tersedia';
        _akurasiMeter = bestAccuracy;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lokasi didapat! Akurasi: ${bestAccuracy.toStringAsFixed(1)} m'),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendapatkan lokasi: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _sedangMengambilLokasi = false;
      });
    }
  }

  // --- CONTROLLER METHOD: Dialog Input Lokasi Manual ---
  // Method untuk membuka dialog pilih lokasi manual
  Future<void> _pilihLokasiManual() async {
    final TextEditingController latController = TextEditingController(
      text: _latitude?.toString() ?? '',
    );
    final TextEditingController lngController = TextEditingController(
      text: _longitude?.toString() ?? '',
    );
    final TextEditingController alamatController = TextEditingController(
      text: _alamat ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Masukkan Lokasi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: latController,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  hintText: 'Contoh: -6.2088',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lngController,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  hintText: 'Contoh: 106.8456',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: alamatController,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  hintText: 'Masukkan alamat lengkap',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final lat = double.tryParse(latController.text);
              final lng = double.tryParse(lngController.text);
              
              if (lat != null && lng != null && alamatController.text.isNotEmpty) {
                setState(() {
                  _latitude = lat;
                  _longitude = lng;
                  _alamat = alamatController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lokasi berhasil diatur!'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mohon isi semua field dengan benar!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2193b0),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // --- CONTROLLER METHOD: Hapus Lokasi ---
  // Method untuk menghapus lokasi
  void _hapusLokasi() {
    setState(() {
      _latitude = null;
      _longitude = null;
      _alamat = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lokasi dihapus'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // --- CONTROLLER METHOD: Simpan Mobil ---
  // Validasi form dan simpan data mobil ke database
  Future<void> _simpanMobil() async {
    if (_formKey.currentState!.validate()) {
      // Validasi gambar
      if (_gambarTerpilih == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih gambar mobil terlebih dahulu!'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Konversi gambar ke base64 string
      String gambarBase64 = base64Encode(_bytesGambar!);
      
      final mobilBaru = ModelMobil(
        id: await ServiceMobil.generateId(),
        nama: _namaController.text,
        harga: 'Rp ${_hargaController.text}',
        tahun: _tahunController.text,
        bahanBakar: _bahanBakarTerpilih,
        transmisi: _transmisiTerpilih,
        gambar: gambarBase64, // Simpan gambar sebagai base64 string
        deskripsi: _deskripsiController.text.isEmpty
            ? null
            : _deskripsiController.text,
        latitude: _latitude,
        longitude: _longitude,
        alamat: _alamat,
      );

      await ServiceMobil.tambahMobil(mobilBaru);

      // Kembali ke halaman sebelumnya dengan hasil true
      if (mounted) {
        Navigator.pop(context, true);

        // Tampilkan snackbar sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mobil berhasil ditambahkan!'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // ============================================================================
  // ??? SCREEN/UI - Widget Build Method (Tampilan)
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Posting Mobil'),
        backgroundColor: const Color(0xFF2193b0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2193b0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2193b0).withOpacity(0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF2193b0),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Isi formulir di bawah untuk menambahkan mobil baru',
                      style: TextStyle(
                        color: Color(0xFF2193b0),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Upload Gambar
            const Text(
              'Foto Mobil *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pilihGambar,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _bytesGambar != null
                        ? const Color(0xFF4CAF50)
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: _bytesGambar != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          _bytesGambar!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap untuk pilih gambar',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'JPG, PNG, atau JPEG',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Nama Mobil
            const Text(
              'Nama Mobil *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _namaController,
              decoration: InputDecoration(
                hintText: 'Contoh: Toyota Avanza',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama mobil harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Harga
            const Text(
              'Harga *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _hargaController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) {
                    return newValue;
                  }
                  
                  final formattedValue = _formatHarga(newValue.text);
                  
                  return TextEditingValue(
                    text: formattedValue,
                    selection: TextSelection.collapsed(offset: formattedValue.length),
                  );
                }),
              ],
              decoration: InputDecoration(
                hintText: 'Contoh: 250.000.000',
                prefixText: 'Rp ',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harga harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Tahun
            const Text(
              'Tahun *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tahunController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Contoh: 2023',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tahun harus diisi';
                }
                final tahun = int.tryParse(value);
                if (tahun == null || tahun < 1900 || tahun > 2030) {
                  return 'Tahun tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Bahan Bakar
            const Text(
              'Bahan Bakar *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _bahanBakarTerpilih,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: _pilihanBahanBakar.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _bahanBakarTerpilih = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Transmisi
            const Text(
              'Transmisi *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _transmisiTerpilih,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: _pilihanTransmisi.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _transmisiTerpilih = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Deskripsi
            const Text(
              'Deskripsi (Opsional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _deskripsiController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Deskripsikan mobil Anda...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),

            // Lokasi (Opsional)
            const Text(
              '?? Lokasi Penjual (Opsional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            
            // Location picker widget
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_latitude != null && _longitude != null) ...[
                    // Display lokasi yang sudah dipilih
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, 
                                color: Colors.blue[700], 
                                size: 20
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Lokasi Terpilih',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: _hapusLokasi,
                                tooltip: 'Hapus lokasi',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _alamat ?? 'Alamat tidak tersedia',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lat: ${_latitude!.toStringAsFixed(4)}, Lng: ${_longitude!.toStringAsFixed(4)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_akurasiMeter != null) ...[
                            const SizedBox(height:4),
                            Text(
                              'Perkiraan akurasi: ${_akurasiMeter!.toStringAsFixed(1)} m',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          const SizedBox(height:8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _sedangRefine ? null : _refineAkurasiLokasi,
                              icon: _sedangRefine
                                  ? const SizedBox(
                                      width:16,height:16,
                                      child: CircularProgressIndicator(strokeWidth:2),
                                    )
                                  : const Icon(Icons.tune,size:18),
                              label: Text(_sedangRefine ? 'Memperbaiki...' : 'Perbaiki Akurasi'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue[700],
                                side: BorderSide(color: Colors.blue[300]!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Tombol pilih lokasi
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _sedangMengambilLokasi ? null : _ambilLokasiSaatIni,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.blue[700]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: _sedangMengambilLokasi
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(Icons.my_location, size: 18, color: Colors.blue[700]),
                          label: Text(
                            _sedangMengambilLokasi ? 'Mengambil...' : 'Lokasi Saya',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pilihLokasiManual,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.green[700]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: Icon(Icons.edit_location, size: 18, color: Colors.green[700]),
                          label: Text(
                            'Pilih Manual',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih lokasi penjual agar pembeli dapat menemukan Anda dengan mudah',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Tombol Simpan
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _simpanMobil,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2193b0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Posting Mobil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
