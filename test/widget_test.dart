// Test untuk aplikasi HexoCar
//
// Test sederhana untuk memastikan aplikasi berjalan dengan baik

import 'package:flutter_test/flutter_test.dart';

import 'package:bismmilah_ta/main.dart';

void main() {
  testWidgets('Aplikasi HexoCar berjalan dengan baik', (WidgetTester tester) async {
    // Build aplikasi dan trigger frame
    await tester.pumpWidget(const AplikasiHexoCar());

    // Verifikasi bahwa halaman profil muncul
    expect(find.text('Profil Saya'), findsOneWidget);
  });
}
