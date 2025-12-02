import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../logic/models/model_transaksi.dart';
import '../logic/services/service_transaksi.dart';

class HalamanRiwayatTransaksi extends StatefulWidget {
  const HalamanRiwayatTransaksi({super.key});

  @override
  State<HalamanRiwayatTransaksi> createState() => _HalamanRiwayatTransaksiState();
}

class _HalamanRiwayatTransaksiState extends State<HalamanRiwayatTransaksi> {
  List<ModelTransaksi> _riwayatTransaksi = [];
  
  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }
  
  void _loadRiwayat() {
    setState(() {
      _riwayatTransaksi = ServiceTransaksi.getRiwayatTransaksi();
    });
  }
  
  String _formatTanggal(DateTime tanggal) {
    return DateFormat('dd MMM yyyy, HH:mm').format(tanggal);
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Berhasil':
      case 'Completed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Cancelled':
      case 'Dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
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
          if (_riwayatTransaksi.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Hapus Semua Transaksi',
              onPressed: () => _confirmClearAll(context),
            ),
        ],
      ),
      body: _riwayatTransaksi.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat transaksi',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Summary Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryItem(
                        icon: Icons.receipt,
                        label: 'Total Transaksi',
                        value: '${_riwayatTransaksi.length}',
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _SummaryItem(
                        icon: Icons.check_circle,
                        label: 'Selesai',
                        value: '${_riwayatTransaksi.where((t) => t.status == 'Berhasil' || t.status == 'Completed').length}',
                      ),
                    ],
                  ),
                ),
                
                // List Transaksi
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _riwayatTransaksi.length,
                    itemBuilder: (context, index) {
                      final transaksi = _riwayatTransaksi[index];
                      return Dismissible(
                        key: Key(transaksi.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete, color: Colors.white, size: 32),
                              SizedBox(height: 4),
                              Text(
                                'Hapus',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hapus Transaksi?'),
                              content: Text('Hapus transaksi "${transaksi.namaMobil}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          _deleteTransaksi(transaksi);
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              _showDetailTransaksi(context, transaksi);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          transaksi.namaMobil,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(transaksi.status).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          transaksi.status,
                                          style: TextStyle(
                                            color: _getStatusColor(transaksi.status),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    transaksi.hargaMobil,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2193b0),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        transaksi.namaPembeli,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatTanggal(transaksi.tanggalTransaksi),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (transaksi.mataUang != null && transaksi.mataUang != 'IDR') ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.currency_exchange, size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${transaksi.jumlahPembayaran} (${transaksi.mataUang})',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
  
  // Konfirmasi hapus semua transaksi
  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_sweep,
                  color: Colors.red,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Hapus Semua Riwayat?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Semua ${_riwayatTransaksi.length} transaksi akan dihapus permanen dan tidak dapat dikembalikan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await ServiceTransaksi.clearAllTransaksi();
                        Navigator.pop(context);
                        _loadRiwayat();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('Semua riwayat berhasil dihapus'),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Hapus Semua'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Hapus transaksi satuan
  Future<void> _deleteTransaksi(ModelTransaksi transaksi) async {
    await ServiceTransaksi.hapusTransaksi(transaksi.id);
    _loadRiwayat();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.delete, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Transaksi "${transaksi.namaMobil}" dihapus'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }
  
  void _showDetailTransaksi(BuildContext context, ModelTransaksi transaksi) {
    final formatTanggal = '${transaksi.tanggalTransaksi.day}/${transaksi.tanggalTransaksi.month}/${transaksi.tanggalTransaksi.year}';
    final formatJam = '${transaksi.tanggalTransaksi.hour.toString().padLeft(2, '0')}:${transaksi.tanggalTransaksi.minute.toString().padLeft(2, '0')}';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Detail Transaksi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ID Transaksi
                Text(
                  'ID: ${transaksi.id}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Info Mobil
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.directions_car, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          transaksi.namaMobil,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Tanggal & Waktu
                _buildSimpleRow('Tanggal', formatTanggal),
                _buildSimpleRow('Waktu', formatJam),
                
                const Divider(height: 24),
                
                // Data Pembeli
                Text(
                  'DATA PEMBELI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                _buildSimpleRow('Nama', transaksi.namaPembeli),
                _buildSimpleRow('Username', transaksi.emailPembeli),
                if (transaksi.nomorTelepon.isNotEmpty)
                  _buildSimpleRow('Telepon', transaksi.nomorTelepon),
                
                const Divider(height: 24),
                
                // Detail Pembayaran
                Text(
                  'DETAIL PEMBAYARAN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                _buildSimpleRow('Harga Mobil', transaksi.hargaMobil),
                if (transaksi.biayaPengiriman != null && transaksi.biayaPengiriman!.isNotEmpty)
                  _buildSimpleRow('Jasa Kirim', transaksi.biayaPengiriman!),
                if (transaksi.opsiPengiriman != null)
                  _buildSimpleRow('Opsi Pengiriman', transaksi.opsiPengiriman!),
                
                const Divider(height: 24),
                
                // Info Transaksi
                Text(
                  'INFO TRANSAKSI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                _buildSimpleRow('Metode Pembayaran', transaksi.metodePembayaran),
                if (transaksi.mataUang != null)
                  _buildSimpleRow('Mata Uang', transaksi.mataUang!),
                _buildSimpleRow('Status', transaksi.status, valueColor: Colors.green),
                if (transaksi.catatan != null && transaksi.catatan!.isNotEmpty)
                  _buildSimpleRow('Catatan', transaksi.catatan!),
                
                const Divider(height: 24),
                
                // Total
                if (transaksi.jumlahPembayaran != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          transaksi.jumlahPembayaran!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSimpleRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}
