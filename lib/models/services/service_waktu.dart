import 'dart:convert';
import 'package:http/http.dart' as http;

class ServiceWaktu {
  // Ambil waktu sekarang untuk timezone (mis. 'Asia/Jakarta')
  static Future<DateTime> fetchTimeForZone(String zone) async {
    final url = 'https://worldtimeapi.org/api/timezone/$zone';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      final dtStr = data['datetime'] as String?;
      if (dtStr != null) {
        return DateTime.parse(dtStr);
      }
      throw Exception('Response tidak berisi datetime');
    } else {
      throw Exception('Gagal mengambil waktu: ${res.statusCode}');
    }
  }

  // Optional: ambil info zona (utc_offset, abbreviation)
  static Future<Map<String, dynamic>> fetchZoneInfo(String zone) async {
    final url = 'https://worldtimeapi.org/api/timezone/$zone';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      return data;
    } else {
      throw Exception('Gagal mengambil info zona: ${res.statusCode}');
    }
  }
}
