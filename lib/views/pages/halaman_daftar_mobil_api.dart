import 'package:flutter/material.dart';
import '../../models/services/service_mobil_api.dart';
import '../../models/model_mobil.dart';
import 'halaman_beli_mobil.dart'; // Ganti ke halaman beli mobil

/// Halaman untuk menampilkan daftar mobil dari API
class HalamanDaftarMobilAPI extends StatefulWidget {
  const HalamanDaftarMobilAPI({super.key});

  @override
  State<HalamanDaftarMobilAPI> createState() => _HalamanDaftarMobilAPIState();
}

class _HalamanDaftarMobilAPIState extends State<HalamanDaftarMobilAPI> {
  List<ModelMobil> _daftarMobil = [];
  bool _loading = true;
  String _error = '';
  String _sourceAPI = 'Mock API'; // RapidAPI, Free Car API, atau Mock API

  @override
  void initState() {
    super.initState();
    _loadMobilDariAPI();
  }

  Future<void> _loadMobilDariAPI() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      // Fetch dari NHTSA API (Real API - Gratis!) - Multi Sport Brands
      // Function fetchFromNHTSA sudah otomatis ambil dari 5 brand sport
      final mobils = await ServiceMobilAPI.fetchFromNHTSA();
      
      setState(() {
        _daftarMobil = mobils;
        _loading = false;
        _sourceAPI = 'NHTSA API - Sport Cars (Porsche, BMW, JDM Legends, Audi, Chevrolet)';
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data: $e';
        _loading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadMobilDariAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Daftar Mobil dari API'),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _loading
          ? _buildLoadingWidget()
          : _error.isNotEmpty
              ? _buildErrorWidget()
              : _buildDaftarMobil(),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2193b0)),
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat data dari API...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2193b0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaftarMobil() {
    return Column(
      children: [
        // Info sumber API
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2193b0).withOpacity(0.1),
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.cloud_done,
                color: Color(0xFF2193b0),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Sumber: $_sourceAPI',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2193b0),
                ),
              ),
              const Spacer(),
              Text(
                '${_daftarMobil.length} mobil',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        
        // List mobil
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: const Color(0xFF2193b0),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _daftarMobil.length,
              itemBuilder: (context, index) {
                final mobil = _daftarMobil[index];
                return _buildMobilCard(mobil);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobilCard(ModelMobil mobil) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HalamanBeliMobil(mobil: mobil),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Gambar
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.directions_car,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mobil.nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mobil.harga,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2193b0),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(Icons.calendar_today, mobil.tahun),
                        const SizedBox(width: 8),
                        _buildInfoChip(Icons.local_gas_station, mobil.bahanBakar),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
