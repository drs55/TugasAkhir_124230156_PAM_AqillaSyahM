import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'halaman_profil.dart';
import 'halaman_beli_mobil.dart';
import 'halaman_tambah_mobil.dart';
import '../logic/models/model_mobil.dart';
import '../logic/models/model_user.dart';
import '../logic/services/service_mobil.dart';
import '../logic/services/service_mobil_api.dart';
import '../logic/services/service_auth.dart';

// ============================================================================
// 🖥️ SCREEN/UI - Halaman Beranda (Home)
// ============================================================================
class HalamanBeranda extends StatefulWidget {
  const HalamanBeranda({super.key});

  @override
  State<HalamanBeranda> createState() => _HalamanBerandaState();
}

// ============================================================================
// 🎮 CONTROLLER/LOGIC - State management untuk Beranda
// ============================================================================
class _HalamanBerandaState extends State<HalamanBeranda> {
  // --- Form Controllers ---
  final TextEditingController _pencarianController = TextEditingController();
  
  // --- State Variables ---
  String _bahanBakarTerpilih = 'Semua';
  String _transmisiTerpilih = 'Semua';
  bool _tampilkanFilter = false;
  List<ModelMobil> _daftarMobil = [];
  bool _isLoading = true;
  ModelUser? _currentUser;
  
  // Penanda mobil asal API (JDM)
  final Set<String> _idApi = {};

  // --- Data untuk Filter ---
  final List<String> _pilihanBahanBakar = [
    'Semua',
    'Bensin',
    'Diesel',
    'Hybrid',
    'Elektrik'
  ];

  final List<String> _pilihanTransmisi = [
    'Semua',
    'Manual',
    'Automatic',
    'CVT',
  ];

  // --- Lifecycle Methods ---
  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUser();
  }
  
  // --- CONTROLLER METHOD: Load Current User ---
  Future<void> _loadUser() async {
    final user = await ServiceAuth.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  // --- CONTROLLER METHOD: Load Mobil dari Database & API ---
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    _idApi.clear();
    final lokal = await ServiceMobil.getDaftarMobil();
    
    // Fetch dari NHTSA API - Sport Cars (Hardcoded 15 mobil)
    final apiData = await ServiceMobilAPI.fetchFromNHTSA();

    // Gabung & dedup id (jika bentrok modifikasi id API)
    final Map<String, ModelMobil> map = { for (final m in lokal) m.id: m };
    for (final original in apiData) {
      String newId = original.id;
      ModelMobil entry = original;
        try {
      if (map.containsKey(newId)) {
        newId = 'api_${newId}_${map.length}';
        entry = ModelMobil(
          id: newId,
          nama: original.nama,
          harga: original.harga,
          tahun: original.tahun,
          bahanBakar: original.bahanBakar,
          transmisi: original.transmisi,
          gambar: original.gambar,
          deskripsi: original.deskripsi,
          latitude: original.latitude,
          longitude: original.longitude,
          alamat: original.alamat,
        );
      }
        } catch (_) {
          // defensive: if map is not a normal Map (unexpected), fall back to direct assignment
        }
      map[newId] = entry;
      _idApi.add(newId);
    }

    setState(() {
      _daftarMobil = map.values.toList();
      _isLoading = false;
    });
  }

  List<ModelMobil> get _mobilTerfilter {
    final keyword = _pencarianController.text.trim().toLowerCase();
    return _daftarMobil.where((mobil) {
      final namaLower = (mobil.nama).toLowerCase();
      final bool matchNama = keyword.isEmpty ? true : (namaLower.contains(keyword));
      final bool matchBahan = _bahanBakarTerpilih == 'Semua' || mobil.bahanBakar == _bahanBakarTerpilih;
      final bool matchTrans = _transmisiTerpilih == 'Semua' || mobil.transmisi == _transmisiTerpilih;
      return matchNama && matchBahan && matchTrans;
    }).toList();
  }

  // --- CONTROLLER METHOD: Reset Filter ---
  void _resetFilter() {
    setState(() {
      _bahanBakarTerpilih = 'Semua';
      _transmisiTerpilih = 'Semua';
      _pencarianController.clear();
    });
  }

  @override
  void dispose() {
    _pencarianController.dispose();
    super.dispose();
  }

  // ============================================================================
  // 🖥️ SCREEN/UI - Widget Build Method (Tampilan)
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan logo profil
            _buildHeader(),

            // Search Bar
            _buildSearchBar(),

            // Filter Section
            if (_tampilkanFilter) _buildFilterSection(),

            // Tombol Filter & Reset
            _buildFilterButtons(),

            // Divider
            const Divider(height: 1),

            // List Mobil
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2193b0),
                      ),
                    )
                  : _mobilTerfilter.isEmpty
                      ? _buildEmptyState()
                      : _buildDaftarMobil(),
            ),
          ],
        ),
      ),
      // Tombol Posting Mobil
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HalamanTambahMobil(),
            ),
          );
          
          // Refresh list jika ada mobil baru ditambahkan
          if (result == true) {
            await _loadData();
          }
        },
        backgroundColor: const Color(0xFF2193b0),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Posting Mobil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Helper untuk cek apakah gambar adalah asset atau base64
  bool _isAssetImage(String gambar) {
    return gambar.startsWith('assets/');
  }

  // Helper untuk decode base64 dengan error handling
  Uint8List _decodeBase64(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      // Jika gagal decode, return empty bytes
      return Uint8List(0);
    }
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
  // Spasi samping seragam untuk kiri (logo+teks) dan kanan (avatar profil)
  final double sideSpacing = screenWidth < 360
    ? 10
    : screenWidth < 480
      ? 14
      : 18; // disesuaikan agar konsisten kiri-kanan
  // Header semakin pendek: hilangkan padding vertikal
  final double verticalPadding = 0;
    // Ukuran logo dan font tersinkron
  final double logoSize = screenWidth < 360
    ? 60
    : screenWidth < 480
      ? 75
      : screenWidth < 600
        ? 90
        : 105; // sedikit lebih kecil agar header rendah
  final double titleFontSize = screenWidth < 360
    ? 18
    : screenWidth < 480
      ? 20
      : 22;
  final double subtitleFontSize = screenWidth < 360 ? 10 : 11;
    // Spasi antar elemen
  final double gapBetweenLogoAndText = screenWidth < 360 ? 6 : 4;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sideSpacing,
        vertical: verticalPadding,
      ),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.only(top: 2), 
            child: Semantics(
              label: 'Logo HexoCar',
              child: SizedBox(
                width: logoSize,
                height: logoSize,
                child: Image.asset(
                  'assets/logo/1.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.directions_car,
                      color: Colors.white,
                      size: logoSize * 0.8,
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: gapBetweenLogoAndText),
          // Text area
          Expanded(
            child: Padding(
                    padding: const EdgeInsets.only(top: 6), // geser teks turun sedikit
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'HEXOCAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Temukan mobil impian Anda',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: subtitleFontSize,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Avatar profil digeser sedikit ke kiri untuk mendekatkan ke teks
          Transform.translate(
            offset: const Offset(-19, 0), // geser kiri 6px
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HalamanProfil(),
                  ),
                ).then((_) {
                  // Refresh data saat kembali dari profil
                  _loadData();
                  _loadUser(); // Refresh foto profil
                });
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildAvatarProfil(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAvatarProfil() {
    final fotoProfil = _currentUser?.fotoProfil;
    final hasPhoto = fotoProfil != null && fotoProfil.isNotEmpty;
    
    return CircleAvatar(
      radius: 22,
      backgroundImage: hasPhoto
          ? MemoryImage(base64Decode(fotoProfil))
          : null,
      backgroundColor: Colors.grey[300],
      child: hasPhoto
          ? null
          : Icon(
              Icons.person,
              size: 24,
              color: Colors.grey[600],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _pencarianController,
          onChanged: (value) {
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: 'Cari mobil...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
            suffixIcon: _pencarianController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _pencarianController.clear();
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Toggle Sumber Data
          // (Mode gabungan default, tidak perlu toggle)
          // Tombol Filter
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _tampilkanFilter = !_tampilkanFilter;
                });
              },
              icon: Icon(
                _tampilkanFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
                size: 20,
              ),
              label: Text(_tampilkanFilter ? 'Sembunyikan Filter' : 'Tampilkan Filter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2193b0),
                side: const BorderSide(color: Color(0xFF2193b0)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Tombol Reset
          OutlinedButton.icon(
            onPressed: _resetFilter,
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[400]!),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          // Filter Bahan Bakar
          const Text(
            'Bahan Bakar',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2193b0),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _pilihanBahanBakar.map((bahanBakar) {
              final terpilih = _bahanBakarTerpilih == bahanBakar;
              return FilterChip(
                label: Text(bahanBakar),
                selected: terpilih,
                onSelected: (selected) {
                  setState(() {
                    _bahanBakarTerpilih = bahanBakar;
                  });
                },
                selectedColor: const Color(0xFF2193b0).withOpacity(0.2),
                checkmarkColor: const Color(0xFF2193b0),
                labelStyle: TextStyle(
                  color: terpilih ? const Color(0xFF2193b0) : Colors.grey[700],
                  fontWeight: terpilih ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: terpilih ? const Color(0xFF2193b0) : Colors.grey[300]!,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Filter Transmisi
          const Text(
            'Transmisi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2193b0),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _pilihanTransmisi.map((transmisi) {
              final terpilih = _transmisiTerpilih == transmisi;
              return FilterChip(
                label: Text(transmisi),
                selected: terpilih,
                onSelected: (selected) {
                  setState(() {
                    _transmisiTerpilih = transmisi;
                  });
                },
                selectedColor: const Color(0xFF6dd5ed).withOpacity(0.2),
                checkmarkColor: const Color(0xFF2193b0),
                labelStyle: TextStyle(
                  color: terpilih ? const Color(0xFF2193b0) : Colors.grey[700],
                  fontWeight: terpilih ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: terpilih ? const Color(0xFF2193b0) : Colors.grey[300]!,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDaftarMobil() {
    if (_mobilTerfilter.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada mobil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap tombol + untuk menambah mobil',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mobilTerfilter.length,
      itemBuilder: (context, index) {
        final mobil = _mobilTerfilter[index];
        return _buildKartuMobil(mobil);
      },
    );
  }

  Widget _buildKartuMobil(ModelMobil mobil) {
    final bool fromApi = _idApi.contains(mobil.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Mobil
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                // Placeholder image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: mobil.gambar.startsWith('http://') || mobil.gambar.startsWith('https://')
                      ? Image.network(
                          mobil.gambar,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: double.infinity,
                              height: 200,
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
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(
                                  Icons.directions_car,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        )
                      : _isAssetImage(mobil.gambar)
                          ? Image.asset(
                              mobil.gambar,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                      Icons.directions_car,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            )
                          : () {
                              try {
                                final bytes = _decodeBase64(mobil.gambar);
                                if (bytes.isEmpty) {
                                  return Container(
                                    width: double.infinity,
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(
                                        Icons.directions_car,
                                        size: 80,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }
                                return Image.memory(
                                  bytes,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(
                                          Icons.directions_car,
                                          size: 80,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } catch (e) {
                                return Container(
                                  width: double.infinity,
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                      Icons.directions_car,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }
                            }(),
                ),
                // Badge Tahun
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2193b0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      mobil.tahun,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                if (fromApi)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6dd5ed), Color(0xFF2193b0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'API',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Informasi Mobil
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mobil.nama,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mobil.harga,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2193b0),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.local_gas_station,
                      mobil.bahanBakar,
                      const Color(0xFFFF6B6B),
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.settings,
                      mobil.transmisi,
                      const Color(0xFF4ECDC4),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HalamanBeliMobil(mobil: mobil),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2193b0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text(
                      'Beli Sekarang',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada mobil ditemukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter atau kata kunci pencarian',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _resetFilter,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2193b0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Reset Filter'),
          ),
        ],
      ),
    );
  }
}
