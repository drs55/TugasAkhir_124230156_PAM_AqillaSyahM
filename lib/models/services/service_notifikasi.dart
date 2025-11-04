import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service untuk Local Notifications (kayak WhatsApp)
class ServiceNotifikasi {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize notification service
  static Future<void> initialize() async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize plugin dengan handler untuk notification tap
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap (bisa dikembangkan untuk navigasi)
      },
    );

    // Request permissions for Android 13+
    await _requestPermissions();
  }

  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final IOSFlutterLocalNotificationsPlugin? iosPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Tampilkan notifikasi pencapaian (kelipatan 2)
  static Future<void> tampilkanNotifikasiPencapaian({
    required int jumlahMobil,
    required String namaMobil,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'pencapaian_channel', // channel ID
      'Pencapaian Pembelian', // channel name
      channelDescription: 'Notifikasi pencapaian pembelian mobil',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      styleInformation: BigTextStyleInformation(''),
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: Color(0xFF2193b0),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      jumlahMobil, // notification ID (unique per pencapaian)
      '🎉 Selamat! Pencapaian Baru!',
      'Anda telah membeli $jumlahMobil mobil! Terakhir: $namaMobil. Terima kasih atas kepercayaan Anda. 🚗✨',
      notificationDetails,
      payload: 'pencapaian_$jumlahMobil',
    );
  }

  /// Tampilkan notifikasi pembelian berhasil
  static Future<void> tampilkanNotifikasiPembelian({
    required String namaMobil,
    required String harga,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'pembelian_channel', // channel ID
      'Pembelian Mobil', // channel name
      channelDescription: 'Notifikasi pembelian mobil berhasil',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF4CAF50),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      0, // notification ID (0 untuk pembelian biasa)
      '✅ Pembelian Berhasil',
      'Mobil "$namaMobil" ($harga) berhasil dibeli. Riwayat tersimpan.',
      notificationDetails,
      payload: 'pembelian_$namaMobil',
    );
  }

  /// Tampilkan notifikasi test
  static Future<void> tampilkanNotifikasiTest({
    required int jumlahTransaksi,
    required bool isKelipatan2,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'test_channel', // channel ID
      'Test Notifikasi', // channel name
      channelDescription: 'Notifikasi untuk testing',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF2193b0),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      999, // notification ID untuk test
      ' TEST NOTIFIKASI',
      'Total transaksi: $jumlahTransaksi mobil. ',
      notificationDetails,
      payload: 'test',
    );
  }

  /// Cancel semua notifikasi
  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Cancel notifikasi by ID
  static Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
