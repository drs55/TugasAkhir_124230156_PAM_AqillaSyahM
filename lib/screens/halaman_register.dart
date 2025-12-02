import 'package:flutter/material.dart';
import '../logic/services/service_auth.dart';
import 'halaman_beranda.dart';

// ============================================================================
// 🖥️ SCREEN/UI - Halaman Register
// ============================================================================
class HalamanRegister extends StatefulWidget {
  const HalamanRegister({super.key});

  @override
  State<HalamanRegister> createState() => _HalamanRegisterState();
}

// ============================================================================
// 🎮 CONTROLLER/LOGIC - State management untuk Register
// ============================================================================
class _HalamanRegisterState extends State<HalamanRegister> {
  // --- Form Controllers ---
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiPasswordController = TextEditingController();
  
  // --- State Variables ---
  bool _sedangMemuat = false;
  bool _sembunyikanPassword = true;
  bool _sembunyikanKonfirmasiPassword = true;

  // --- Lifecycle Methods ---
  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

  // --- CONTROLLER METHOD: Proses Register ---
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _sedangMemuat = true);

    final result = await ServiceAuth.register(
      nama: _namaController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _sedangMemuat = false);

    if (!mounted) return;

    if (result['success']) {
      // Register berhasil, navigate ke home
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
      
      // Auto login setelah register
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HalamanBeranda()),
        (route) => false,
      );
    } else {
      // Tampilkan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
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
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Daftar Akun Baru',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo
                          Center(
                            child: Image.asset(
                              'assets/logo/2.png',
                              width: 200,
                              height: 200,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback jika logo belum ada
                                return const Icon(
                                  Icons.directions_car,
                                  size: 60,
                                  color: Color(0xFF2193b0),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Nama Lengkap
                          TextFormField(
                            controller: _namaController,
                            decoration: InputDecoration(
                              labelText: 'Nama Lengkap *',
                              hintText: 'Masukkan nama lengkap',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama harus diisi';
                              }
                              if (value.length < 3) {
                                return 'Nama minimal 3 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Username (Required)
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username *',
                              hintText: 'Masukkan username',
                              prefixIcon: const Icon(Icons.account_circle_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Username harus diisi';
                              }
                              if (value.length < 3) {
                                return 'Username minimal 3 karakter';
                              }
                              if (value.contains(' ')) {
                                return 'Username tidak boleh mengandung spasi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _sembunyikanPassword,
                            decoration: InputDecoration(
                              labelText: 'Password *',
                              hintText: 'Minimal 6 karakter',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _sembunyikanPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _sembunyikanPassword = !_sembunyikanPassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password harus diisi';
                              }
                              if (value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Konfirmasi Password
                          TextFormField(
                            controller: _konfirmasiPasswordController,
                            obscureText: _sembunyikanKonfirmasiPassword,
                            decoration: InputDecoration(
                              labelText: 'Konfirmasi Password *',
                              hintText: 'Ketik ulang password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _sembunyikanKonfirmasiPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _sembunyikanKonfirmasiPassword = !_sembunyikanKonfirmasiPassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Konfirmasi password harus diisi';
                              }
                              if (value != _passwordController.text) {
                                return 'Password tidak cocok';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Register Button
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _sedangMemuat ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2193b0),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              child: _sedangMemuat
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Daftar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Sudah punya akun? ',
                                style: TextStyle(color: Colors.grey),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2193b0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
