import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/services/service_mobil.dart';
import '../../models/model_mobil.dart';
import '../../models/services/service_auth.dart';
import '../../models/model_user.dart';
import 'halaman_login.dart';
import 'halaman_riwayat_transaksi.dart';

// ============================================================================
// 🖥️ SCREEN/UI - Halaman Profil User
// ============================================================================
class HalamanProfil extends StatefulWidget {
  const HalamanProfil({super.key});

  @override
  State<HalamanProfil> createState() => _HalamanProfilState();
}

// ============================================================================
// 🎮 CONTROLLER/LOGIC - State management untuk Profil
// ============================================================================
class _HalamanProfilState extends State<HalamanProfil> {
  // --- State Variables ---
  List<ModelMobil> _daftarMobilSaya = [];
  bool _sedangMemuat = true;
  ModelUser? _currentUser;

  // --- Lifecycle Methods ---
  @override
  void initState() {
    super.initState();
    _muatDataUser();
    _muatMobilSaya();
  }

  // --- CONTROLLER METHOD: Load User Data ---
  Future<void> _muatDataUser() async {
    final user = await ServiceAuth.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  // --- CONTROLLER METHOD: Load List Mobil User ---
  Future<void> _muatMobilSaya() async {
    setState(() => _sedangMemuat = true);
    final semua = await ServiceMobil.getDaftarMobil();
    // Filter hanya mobil dengan gambar base64 (yang diposting user, bukan default)
    final mobilUser = semua.where((m) => !m.gambar.startsWith('assets/')).toList();
    setState(() {
      _daftarMobilSaya = mobilUser;
      _sedangMemuat = false;
    });
  }

  // --- CONTROLLER METHOD: Hapus Mobil dengan Konfirmasi ---
  Future<void> _hapusMobil(ModelMobil mobil) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Mobil'),
        content: Text('Yakin ingin menghapus ${mobil.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      await ServiceMobil.hapusMobil(mobil.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${mobil.nama} berhasil dihapus'),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
      _muatMobilSaya(); // Refresh list
    }
  }

  // ============================================================================
  // 🖥️ SCREEN/UI - Widget Build Method (Tampilan)
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // AppBar dengan gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2193b0),
                    Color(0xFF6dd5ed),
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                centerTitle: true,
                title: const Text(
                  'Profil Saya',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2193b0),
                        Color(0xFF6dd5ed),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Konten Profil
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Foto Profil
                _buildFotoProfil(),
                
                const SizedBox(height: 30),
                
                // Informasi Pribadi
                _buildKartuInformasi(context),
                
                const SizedBox(height: 16),
                
                // Mobil Saya (yang diposting user)
                _buildMobilSaya(),
                
                const SizedBox(height: 16),
                
                // Menu Saran dan Kesan
                _buildMenuSaranKesan(context),
                
                const SizedBox(height: 16),
                
                // Menu Riwayat Transaksi
                _buildMenuRiwayatTransaksi(context),
                
                const SizedBox(height: 16),
                
                // Tombol Tentang Developer
                _buildTombolDeveloper(context),
                
                const SizedBox(height: 16),
                
                // Tombol Logout
                _buildTombolKeluar(context),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFotoProfil() {
    final fotoProfil = _currentUser?.fotoProfil;
    final hasPhoto = fotoProfil != null && fotoProfil.isNotEmpty;
    
    return GestureDetector(
      onTap: _pilihFotoProfil,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 55,
                backgroundImage: hasPhoto
                    ? MemoryImage(base64Decode(fotoProfil))
                    : null,
                backgroundColor: Colors.grey[300],
                child: hasPhoto
                    ? null
                    : Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey[600],
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2193b0),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // --- CONTROLLER METHOD: Pilih Foto Profil ---
  Future<void> _pilihFotoProfil() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 512,
        maxHeight: 512,
      );
      
      if (image != null && _currentUser != null) {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        
        final success = await ServiceAuth.updateFotoProfil(
          userId: _currentUser!.id,
          fotoBase64: base64Image,
        );
        
        if (success) {
          await _muatDataUser(); // Refresh user data
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto profil berhasil diperbarui'),
                backgroundColor: Color(0xFF4CAF50),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- UI COMPONENT: Kartu Informasi User ---
  Widget _buildKartuInformasi(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildItemInformasi(
              Icons.person_outline,
              'Nama Lengkap',
              _currentUser?.nama ?? 'Loading...',
              const Color(0xFF2193b0),
            ),
            _buildGarisPemisah(),
            _buildItemInformasi(
              Icons.account_circle_outlined,
              'Username',
              _currentUser?.username ?? 'Loading...',
              const Color(0xFF6dd5ed),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENT: Item Informasi (sub-component) ---
  Widget _buildItemInformasi(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENT: List Mobil yang Diposting User ---
  Widget _buildMobilSaya() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.directions_car,
                  color: Colors.blue[700],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Mobil Saya',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (_sedangMemuat)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_sedangMemuat)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_daftarMobilSaya.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.car_rental, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada mobil yang diposting',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _daftarMobilSaya.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final mobil = _daftarMobilSaya[index];
                return _buildItemMobilSaya(mobil);
              },
            ),
        ],
      ),
    );
  }

  // --- UI COMPONENT: Item Card Mobil (sub-component) ---
  Widget _buildItemMobilSaya(ModelMobil mobil) {
    final imageBytes = _decodeBase64(mobil.gambar);
    
    return Row(
      children: [
        // Gambar mobil
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageBytes != null
              ? Image.memory(
                  imageBytes,
                  width: 80,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                )
              : Container(
                  width: 80,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
        ),
        const SizedBox(width: 12),
        
        // Info mobil
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mobil.nama,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                mobil.harga,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${mobil.tahun} • ${mobil.transmisi}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        // Tombol hapus
        IconButton(
          onPressed: () => _hapusMobil(mobil),
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          tooltip: 'Hapus mobil',
        ),
      ],
    );
  }

  // Helper untuk decode base64
  Uint8List? _decodeBase64(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      return null;
    }
  }

  // --- UI COMPONENT: Menu Saran & Kesan ---
  Widget _buildMenuSaranKesan(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildItemMenu(
              context,
              Icons.feedback_outlined,
              'Saran dan Kesan',
              'Berikan saran dan kesan Anda tentang mata kuliah mobile',
              const Color(0xFFFF6B6B),
              () {
                _tampilkanDialogSaranKesan(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENT: Menu Item (reusable) ---
  Widget _buildItemMenu(
    BuildContext context,
    IconData icon,
    String judul,
    String deskripsi,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deskripsi,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENT: Menu Riwayat Transaksi ---
  Widget _buildMenuRiwayatTransaksi(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildItemMenu(
              context,
              Icons.receipt_long,
              'Riwayat Transaksi',
              'Lihat riwayat pembelian mobil Anda',
              const Color(0xFF2193b0),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HalamanRiwayatTransaksi(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENT: Tombol Developer Info ---
  Widget _buildTombolDeveloper(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _tampilkanInfoDeveloper(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.code,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Tentang Developer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI COMPONENT: Tombol Logout ---
  Widget _buildTombolKeluar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B6B).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _tampilkanDialogKonfirmasiKeluar(context);
            },
            borderRadius: BorderRadius.circular(16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Keluar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI COMPONENT: Garis Pemisah ---
  Widget _buildGarisPemisah() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Colors.grey[200],
      ),
    );
  }

  // --- CONTROLLER METHOD: Dialog Konfirmasi Logout ---
  void _tampilkanDialogKonfirmasiKeluar(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Color(0xFFFF6B6B)),
              SizedBox(width: 12),
              Text('Konfirmasi Keluar'),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari aplikasi HexoCar?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  
                  // Logout menggunakan ServiceAuth
                  await ServiceAuth.logout();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Berhasil keluar dari aplikasi'),
                      backgroundColor: Color(0xFF4CAF50),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  
                  // Navigate ke halaman login dan hapus semua route sebelumnya
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HalamanLogin()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Keluar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- CONTROLLER METHOD: Bottom Sheet Developer Info ---
  void _tampilkanInfoDeveloper(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Header dengan icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF667eea),
                        Color(0xFF764ba2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_circle,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Informasi Developer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Info Developer
                _buildInfoItem(
                  icon: Icons.person,
                  label: 'Nama',
                  value: 'Aqilla Syah Mardian', // Ganti dengan nama kamu
                  color: const Color(0xFF2193b0),
                ),
                const SizedBox(height: 16),
                
                _buildInfoItem(
                  icon: Icons.badge,
                  label: 'NIM',
                  value: '124230156', // Ganti dengan NIM kamu
                  color: const Color(0xFF667eea),
                ),
                const SizedBox(height: 16),
                
                _buildInfoItem(
                  icon: Icons.school,
                  label: 'Jurusan',
                  value: 'Sistem Informasi', // Ganti dengan jurusan kamu
                  color: const Color(0xFF4ECDC4),
                ),
                const SizedBox(height: 16),
                
                _buildInfoItem(
                  icon: Icons.business,
                  label: 'Universitas',
                  value: 'UPN "Veteran" Yogyakarta', // Ganti dengan universitas kamu
                  color: const Color(0xFFFF6B6B),
                ),
                const SizedBox(height: 16),
                
                _buildInfoItem(
                  icon: Icons.calendar_today,
                  label: 'Tahun',
                  value: '2023', // Tahun pembuatan
                  color: const Color(0xFFf093fb),
                ),
                
                const SizedBox(height: 24),
                
                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Aplikasi HexoCar - Tugas Akhir\nPemrograman Aplikasi Mobile',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Tombol Tutup
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2193b0),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- UI COMPONENT: Info Item untuk Developer Section ---
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- CONTROLLER METHOD: Dialog Saran & Kesan ---
  void _tampilkanDialogSaranKesan(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.feedback, color: Color(0xFFFF6B6B)),
              SizedBox(width: 12),
              Text('Saran dan Kesan'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mata Kuliah Pemrograman Aplikasi Mobile',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2193b0),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kesan:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2193b0),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Mata kuliah Pemrograman Aplikasi Mobile sangat menarik dan memberikan banyak pengalaman praktis dalam mengembangkan aplikasi mobile. Materi yang diajarkan sangat relevan dengan kebutuhan industri saat ini, terutama dalam penggunaan Flutter framework. Saya merasa terbantu dengan banyaknya hands-on project yang membuat pemahaman saya tentang mobile development menjadi lebih mendalam.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Saran:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4CAF50),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Untuk ke depannya, akan lebih baik jika ada lebih banyak studi kasus real-world dan integrasi dengan API eksternal yang berbeda. Mungkin bisa ditambahkan juga materi tentang deployment aplikasi ke Google Play Store dan Apple App Store. Selain itu, diskusi tentang best practices dalam architecture pattern dan state management akan sangat membantu untuk meningkatkan kualitas kode yang kita buat.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Tutup',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
