import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model_mobil.dart';

/// Service untuk fetch data mobil dari NHTSA API (Real API - GRATIS!)
/// NHTSA = National Highway Traffic Safety Administration (US Government API)
class ServiceMobilAPI {
  
  // NHTSA API Base URL (GRATIS, tidak perlu API key!)
  static const String _nhtsaBaseUrl = 'https://vpic.nhtsa.dot.gov/api/vehicles';
  
  /// Fetch data mobil REAL dari NHTSA API berdasarkan brand
  static Future<List<ModelMobil>> fetchFromNHTSA({String brand = 'Honda'}) async {
    try {
      final url = '$_nhtsaBaseUrl/GetModelsForMake/$brand?format=json';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['Results'] as List;
        
        List<ModelMobil> mobils = [];
        
        // Ambil max 10 mobil pertama
        for (int i = 0; i < results.length && i < 10; i++) {
          final item = results[i];
          final modelName = item['Model_Name'] ?? 'Unknown';
          final makeName = item['Make_Name'] ?? brand;
          
          mobils.add(ModelMobil(
            id: 'nhtsa_${item['Model_ID']}',
            nama: '$makeName $modelName',
            harga: _estimasiHarga(makeName, modelName),
            tahun: _estimasiTahun(i),
            bahanBakar: 'Bensin',
            transmisi: i % 2 == 0 ? 'Automatic' : 'Manual',
            gambar: _getCarImageUrl(makeName, modelName, i), // Gambar dari web!
            deskripsi: 'Mobil $makeName $modelName dari NHTSA database dengan performa dan keamanan terjamin.',
            latitude: -6.2088 + (i * 0.05),
            longitude: 106.8456 + (i * 0.05),
            alamat: _randomLocation(i),
          ));
        }
        
        return mobils;
      } else {
        return []; // Return empty list if API fails
      }
    } catch (e) {
      return []; // Return empty list on error
    }
  }
  
  /// Estimasi harga berdasarkan brand dan model
  static String _estimasiHarga(String brand, String model) {
    brand = brand.toLowerCase();
    model = model.toLowerCase();
    
    int basePrice = 300000000; // 300 juta default
    
    // Luxury brands
    if (brand.contains('bmw') || brand.contains('mercedes') || 
        brand.contains('audi') || brand.contains('lexus')) {
      basePrice = 800000000;
    }
    // Premium Japanese
    else if (brand.contains('honda') || brand.contains('toyota') || 
             brand.contains('nissan')) {
      basePrice = 400000000;
    }
    // Sports models
    if (model.contains('civic') || model.contains('accord')) {
      basePrice += 100000000;
    }
    if (model.contains('sport') || model.contains('turbo') || 
        model.contains('type r')) {
      basePrice += 200000000;
    }
    
    // Format dengan titik pemisah ribuan
    return _formatRupiah(basePrice);
  }
  
  /// Format angka ke Rupiah dengan titik pemisah ribuan
  static String _formatRupiah(int amount) {
    // Convert ke string dan reverse
    String numStr = amount.toString();
    String reversed = numStr.split('').reversed.join('');
    
    // Tambahkan titik setiap 3 digit
    String formatted = '';
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted += '.';
      }
      formatted += reversed[i];
    }
    
    // Reverse lagi dan tambah prefix Rp
    return 'Rp ${formatted.split('').reversed.join('')}';
  }
  
  /// Estimasi tahun (random antara 2018-2024)
  static String _estimasiTahun(int index) {
    final tahun = 2018 + (index % 7); // 2018-2024
    return tahun.toString();
  }
  
  /// Random location di Indonesia
  static String _randomLocation(int index) {
    final locations = [
      'Jakarta, Indonesia',
      'Bandung, Indonesia',
      'Surabaya, Indonesia',
      'Yogyakarta, Indonesia',
      'Semarang, Indonesia',
      'Malang, Indonesia',
      'Bali, Indonesia',
      'Medan, Indonesia',
      'Makassar, Indonesia',
      'Palembang, Indonesia',
    ];
    return locations[index % locations.length];
  }
  
  /// Generate URL gambar mobil dari web
  static String _getCarImageUrl(String brand, String model, int index) {
    // Gunakan LoremFlickr (kadang gambar mobil, kadang orang, kadang kucing - SERU! wkwkwk)
    // Format: https://loremflickr.com/800/600/honda,civic,car
    final cleanBrand = brand.toLowerCase().replaceAll(' ', '-');
    final cleanModel = model.toLowerCase().replaceAll(' ', '-');
    return 'https://loremflickr.com/800/600/$cleanBrand,$cleanModel,car';
    
    // ALTERNATIF 1: Assets lokal (boring tapi pasti muncul)
    // final imageNum = (index % 5) + 1;
    // return 'assets/gambar/$imageNum.jpg';
    
    // ALTERNATIF 2: Picsum (random scenery, ga ada orang)
    // final seed = '${brand.toLowerCase()}-${model.toLowerCase()}-$index'.hashCode.abs();
    // return 'https://picsum.photos/800/600?random=$seed';
    
    // CATATAN: LoremFlickr emang random, tapi bikin aplikasi lebih "hidup" wkwkwk 😂
  }
}
