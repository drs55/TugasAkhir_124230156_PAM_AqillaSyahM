import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../logic/models/model_mobil.dart';
import '../logic/services/service_transaksi.dart';
import '../logic/services/service_notifikasi.dart';
import 'halaman_transaksi.dart';

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
class _HalamanBeliMobilState extends State<HalamanBeliMobil> {
  // --- Form Controllers ---
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();

  // --- State Variables ---
  
  // --- Lifecycle Methods ---
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    super.dispose();
  }



  // --- CONTROLLER METHOD: Proses Pembelian dengan Validasi Form ---
  void _prosesPembelian() {
    if (_formKey.currentState!.validate()) {
      // Navigasi ke halaman transaksi baru
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HalamanTransaksi(mobil: widget.mobil),
        ),
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
}
