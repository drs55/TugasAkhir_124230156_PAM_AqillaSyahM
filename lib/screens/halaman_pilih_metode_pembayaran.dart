import 'package:flutter/material.dart';
import '../styles/styles.dart';

class HalamanPilihMetodePembayaran extends StatefulWidget {
  const HalamanPilihMetodePembayaran({super.key});

  @override
  State<HalamanPilihMetodePembayaran> createState() => _HalamanPilihMetodePembayaranState();
}

class _HalamanPilihMetodePembayaranState extends State<HalamanPilihMetodePembayaran> {
  String? _metodeDipilih;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Metode Pembayaran'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Bank Transfer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMetodeTile('BRI', Icons.account_balance, const Color(0xFF0047AB)),
                  const SizedBox(height: 12),
                  _buildMetodeTile('Mandiri', Icons.account_balance, const Color(0xFF003D79)),
                  const SizedBox(height: 12),
                  _buildMetodeTile('BCA', Icons.account_balance, const Color(0xFF003D79)),
                  const SizedBox(height: 12),
                  _buildMetodeTile('BNI', Icons.account_balance, const Color(0xFFFF6600)),
                  const SizedBox(height: 20),
                  
                  const Text(
                    'E-Wallet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMetodeTile('GoPay', Icons.account_balance_wallet, const Color(0xFF00AA13)),
                  const SizedBox(height: 12),
                  _buildMetodeTile('OVO', Icons.account_balance_wallet, const Color(0xFF4C3494)),
                  const SizedBox(height: 12),
                  _buildMetodeTile('DANA', Icons.account_balance_wallet, const Color(0xFF118EEA)),
                  const SizedBox(height: 12),
                  _buildMetodeTile('ShopeePay', Icons.account_balance_wallet, const Color(0xFFEE4D2D)),
                  const SizedBox(height: 12),
                  _buildMetodeTile('LinkAja', Icons.account_balance_wallet, const Color(0xFFE31E24)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Button tetap di bawah (tidak ikut scroll)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: _metodeDipilih == null
                ? ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, color: Colors.grey.shade600, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Pilih Metode Pembayaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF2193b0),
                          Color(0xFF6dd5ed),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2193b0).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, _metodeDipilih),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Lanjutkan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetodeTile(String nama, IconData icon, Color color) {
    final selected = _metodeDipilih == nama;
    return Card(
      color: selected ? color.withOpacity(0.15) : Colors.white,
      elevation: selected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? color : Colors.grey.shade300,
          width: selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 36),
        title: Text(
          nama,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selected ? color : Colors.black87,
            fontSize: 18,
          ),
        ),
        trailing: selected
            ? Icon(Icons.check_circle, color: color)
            : null,
        onTap: () {
          setState(() {
            _metodeDipilih = nama;
          });
        },
      ),
    );
  }
}