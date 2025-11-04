import 'package:flutter/material.dart';
import 'views/pages/halaman_splash.dart';
import 'models/hive_service.dart';
import 'models/services/service_auth.dart';
import 'models/services/service_notifikasi.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2193b0),
          primary: const Color(0xFF2193b0),
          secondary: const Color(0xFF6dd5ed),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const HalamanSplash(),
    );
  }
}
