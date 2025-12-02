import 'package:flutter/material.dart';
import 'screens/halaman_splash.dart';
import 'logic/models/hive_service.dart';
import 'logic/services/service_auth.dart';
import 'logic/services/service_notifikasi.dart';
import 'styles/app_theme.dart';

void main() async {
  // Pastikan Flutter binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database
  await HiveService.init();
  
  // Initialize ServiceAuth (Hive boxes untuk users)
  await ServiceAuth.initialize();
  
  // Initialize Local Notifications
  await ServiceNotifikasi.initialize();
  
  runApp(const AplikasiHexoCar());
}

class AplikasiHexoCar extends StatelessWidget {
  const AplikasiHexoCar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HexoCar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HalamanSplash(),
    );
  }
}
