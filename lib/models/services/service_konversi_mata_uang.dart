import 'dart:convert';
import 'package:http/http.dart' as http;

class ServiceKonversiMataUang {
  // Mendapatkan kurs dari IDR ke USD, JPY, MYR
  static Future<Map<String, double>> fetchKursIDR() async {
    // Gunakan API exchangerate-api.com (free, no API key needed untuk basic)
    const url = 'https://open.er-api.com/v6/latest/IDR';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data == null || data['rates'] == null) {
          throw Exception('Response API tidak memiliki field rates');
        }
        
        final ratesRaw = data['rates'];
        if (ratesRaw is! Map) {
          throw Exception('Field rates bukan object');
        }
        
        final rates = Map<String, dynamic>.from(ratesRaw);
        
        return {
          'USD': (rates['USD'] as num?)?.toDouble() ?? 0.000062,
          'JPY': (rates['JPY'] as num?)?.toDouble() ?? 0.0095,
          'MYR': (rates['MYR'] as num?)?.toDouble() ?? 0.00028,
        };
      } else {
        throw Exception('HTTP ${response.statusCode}: Gagal mengambil kurs mata uang');
      }
    } catch (e) {
      // Fallback ke nilai kurs default jika API gagal
      return {
        'USD': 0.000062, // 1 IDR ≈ 0.000062 USD
        'JPY': 0.0095,   // 1 IDR ≈ 0.0095 JPY
        'MYR': 0.00028,  // 1 IDR ≈ 0.00028 MYR
      };
    }
  }

  // Fungsi konversi harga dari IDR ke mata uang lain
  static Future<double> konversiHarga(double hargaIDR, String kodeMataUang) async {
    final kurs = await fetchKursIDR();
    if (!kurs.containsKey(kodeMataUang)) throw Exception('Kode mata uang tidak didukung');
    return hargaIDR * kurs[kodeMataUang]!;
  }
}