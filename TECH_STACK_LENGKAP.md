# 🚗 **HEXOCAR - COMPLETE TECH STACK DOCUMENTATION**

---

## 📋 **TABLE OF CONTENTS**
1. [Core Framework & Language](#1-core-framework--language)
2. [Dependencies List (pubspec.yaml)](#2-dependencies-list)
3. [External APIs Used](#3-external-apis-used)
4. [Database & Storage](#4-database--storage)
5. [Security & Encryption](#5-security--encryption)
6. [Maps & Location Services](#6-maps--location-services)
7. [Media Handling](#7-media-handling)
8. [Notifications](#8-notifications)
9. [UI/UX & Styling](#9-uiux--styling)
10. [Development Tools](#10-development-tools)
11. [Architecture Overview](#11-architecture-overview)
12. [Tech Stack Summary](#12-tech-stack-summary)

---

## **1. CORE FRAMEWORK & LANGUAGE**

| Component | Version | Purpose |
|-----------|---------|---------|
| **Flutter** | 3.9.2+ | Cross-platform mobile development framework |
| **Dart** | 3.9.2+ | Programming language for Flutter |
| **Material Design** | 3.0 | Google's design system & UI components |
| **Null Safety** | Full | Type safety with null awareness |

**Platform Support:**
- ✅ Android (6.0+)
- ✅ iOS (11.0+)
- ✅ Web (Future)
- ✅ Windows (Future)

---

## **2. DEPENDENCIES LIST**

### **A. USER INTERFACE & STYLING**

```yaml
# Material Design 3
flutter:
  sdk: flutter

# Icon library (iOS style icons)
cupertino_icons: ^1.0.8

# Custom Google Fonts
google_fonts: ^6.3.2
  - Poppins
  - Roboto
  - Inter
  - Lato
```

**Digunakan untuk:**
- ✅ Material 3 design components (AppBar, Button, Card, etc)
- ✅ Custom fonts styling
- ✅ Icons (Material Icons, Cupertino Icons)

---

### **B. LOCATION & MAPS SERVICES**

```yaml
# Get device location (GPS)
geolocator: ^10.1.0
  - getCurrentPosition()
  - onPositionChanged stream
  - Distance calculation
  - Geofencing support

# Convert coordinates to address (Reverse Geocoding)
geocoding: ^2.1.1
  - placemarkFromCoordinates() → Get address from GPS
  - placemarkFromAddress() → Get GPS from address
  - Country, city, street name resolution

# Display maps
google_maps_flutter: ^2.5.0
  - GoogleMap widget
  - Markers & Polylines
  - Camera control & animation
  - Map styling

# Launch external apps (Maps, Phone, etc)
url_launcher: ^6.2.2
  - Launch Google Maps
  - Open WhatsApp
  - Phone call
  - SMS
```

**API Requirements:**
- Google Maps API Key (for google_maps_flutter)
- Location permissions (Android & iOS)

---

### **C. DATABASE & LOCAL STORAGE**

```yaml
# NoSQL Local Database
hive: ^2.2.3
  - Box<ModelUser>
  - Box<ModelMobil>
  - Box<ModelTransaksi>
  - Box<SessionData>

# Hive Flutter Integration
hive_flutter: ^1.1.0
  - Hive.initFlutter()
  - app directory access

# Legacy Storage (migration support)
shared_preferences: ^2.2.2
  - Key-value storage
  - User preferences
  - App settings

# File system access
path_provider: ^2.1.1
  - getApplicationDocumentsDirectory()
  - getApplicationSupportDirectory()
  - getTemporaryDirectory()
```

**Database Schema:**
```
users_box → List<ModelUser>
  ├─ id (unique)
  ├─ username
  ├─ passwordHash (PBKDF2)
  ├─ email
  ├─ nomorTelepon
  └─ created timestamp

mobil_box → List<ModelMobil>
  ├─ id (unique)
  ├─ nama
  ├─ harga
  ├─ tahun
  ├─ bahanBakar
  ├─ transmisi
  ├─ gambar (Base64)
  ├─ latitude/longitude
  └─ alamat

transaksi_box → List<ModelTransaksi>
  ├─ id (unique)
  ├─ mobilId
  ├─ pembeli
  ├─ harga
  ├─ metodePembayaran
  ├─ status (pending/process/complete)
  └─ tanggalTransaksi

session_box → SessionData
  ├─ currentUserId
  ├─ sessionToken
  └─ sessionExpiry (7 days)
```

---

### **D. HTTP & API COMMUNICATION**

```yaml
# HTTP Client library
http: ^1.1.0
  - GET requests
  - JSON parsing
  - Error handling
  - No auto-retry (manual implemented)
```

**HTTP Usage:**
```dart
// Example: NHTSA API call
final response = await http.get(
  Uri.parse('https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMake/...')
);
```

---

### **E. SECURITY & ENCRYPTION**

```yaml
# Cryptography library
crypto: ^3.0.3
  - PBKDF2-HMAC-SHA256
  - SHA256
  - HMAC
  - Random salt generation
```

**Password Security Implementation:**
```dart
// Algorithm: PBKDF2-HMAC-SHA256
- Iterations: 10,000
- Key Length: 32 bytes
- Hash Function: SHA256
- Salt: Random (32 bytes)
- Pepper: Konstanta "HEXOCAR#P3pp3r!2025"

Example Password Hash:
plaintext:  "password123"
→ _pbkdf2(password, salt, iterations=10000)
→ hex: "a7f3d4e2f1c9b8a7f3d4e2f1c9b8a7f3d4e2f1c9b8a7f3d4e2f1c9b8a7f3d"
```

---

### **F. NOTIFICATIONS**

```yaml
# Local Push Notifications (like WhatsApp)
flutter_local_notifications: ^17.2.3
  - Android notifications
  - iOS local notifications
  - Custom sound & vibration
  - Notification channels
  - Tap handling

# Toast/Snackbar Notifications
another_flushbar: ^1.12.30
  - Toast messages
  - Flushbar widget
  - Custom styling
  - Duration control
```

**Notification Types:**
1. **Status Update Notification**
   - Title: "Transaksi Diproses"
   - Body: "Pembayaran sedang diverifikasi"

2. **Success Notification**
   - Title: "Pembayaran Berhasil"
   - Body: "Mobil Anda siap diambil"

3. **Error Notification**
   - Title: "Pembayaran Gagal"
   - Body: "Mohon coba lagi"

---

### **G. DATE & TIME FORMATTING**

```yaml
# Internationalization & Date Formatting
intl: ^0.18.1
  - DateFormat (dd/MM/yyyy, dd MMM yyyy, etc)
  - Currency formatting
  - Number formatting
  - Locale support
```

**Usage Examples:**
```dart
// Date formatting
DateFormat('dd/MM/yyyy').format(DateTime.now())
// Output: "02/12/2025"

// Currency formatting
NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(1500000000)
// Output: "Rp 1.500.000.000"

// Custom format
DateFormat('dd MMM yyyy - kk:mm').format(dateTime)
// Output: "02 Des 2025 - 14:30"
```

---

## **3. EXTERNAL APIs USED**

### **A. NHTSA API (National Highway Traffic Safety Administration)**

**🔗 Endpoint:**
```
https://vpic.nhtsa.dot.gov/api/vehicles
```

**Authentication:** 
- ✅ **PUBLIC API - NO API KEY REQUIRED**
- Maintained by US Government
- Free tier unlimited requests

**HTTP Method:** `GET`

**Endpoints Used:**
```
1. Get All Makes:
   GET /GetAllMakes?format=json
   
2. Get Models for Make:
   GET /GetModelsForMake/{make}?format=json
   
3. Get Details:
   GET /GetModelYear/{year}/{make}/{model}?format=json
```

**Data Fetched:**
```json
{
  "Results": [
    {
      "Make_ID": 12345,
      "Make_Name": "Porsche",
      "Model_Name": "911 Carrera",
      "Model_ID": 67890,
      "Years": [2023, 2024, 2025]
    }
  ]
}
```

**Integration in App:**
```dart
// File: lib/logic/services/service_mobil_api.dart
class ServiceMobilAPI {
  static const String _nhtsaBaseUrl = 'https://vpic.nhtsa.dot.gov/api/vehicles';
  
  static Future<List<ModelMobil>> fetchFromNHTSA({String brand = 'Honda'}) async {
    // Returns 15 hardcoded sport cars with real brand data
    // - Porsche, BMW, Nissan, Toyota, Mazda
    // - Audi, Chevrolet
  }
}
```

**Cars Data from API:**
| Brand | Model | Price (IDR) | Fuel | Transmission |
|-------|-------|------------|------|--------------|
| Porsche | 911 Carrera | 2,000,000,000 | Bensin | Automatic |
| BMW | M3 Competition | 1,500,000,000 | Bensin | Automatic |
| Nissan | GT-R R35 Nismo | 1,800,000,000 | Bensin | Automatic |
| Toyota | Supra GR A90 | 1,400,000,000 | Bensin | Automatic |
| Mazda | RX-7 FD Spirit R | 1,200,000,000 | Bensin | Manual |
| Audi | RS7 Sportback | 1,700,000,000 | Bensin | Automatic |
| Chevrolet | Corvette C8 Z06 | 1,500,000,000 | Bensin | Automatic |

**Response Time:** ~500ms (typical)
**Data Format:** JSON

---

### **B. Google Geocoding API**

**🔗 Endpoints:**
```
https://maps.googleapis.com/maps/api/geocode/json
```

**Authentication:**
- Requires Google Maps API Key
- Set in AndroidManifest.xml & Info.plist

**Features:**
```dart
// Reverse Geocoding: Coordinates → Address
placemarkFromCoordinates(latitude, longitude)
→ Returns: Placemark with street, city, country, etc

// Forward Geocoding: Address → Coordinates
placemarkFromAddress(address)
→ Returns: Placemark with lat/lng
```

**Implementation:**
```dart
import 'package:geocoding/geocoding.dart';

// Get address from GPS
List<Placemark> placemarks = await placemarkFromCoordinates(
  -6.2088,  // latitude (Jakarta)
  106.8456  // longitude
);

// Extract data
String street = placemarks[0].street ?? '';
String city = placemarks[0].locality ?? '';
String country = placemarks[0].country ?? '';
```

---

### **C. Exchange Rate API (Currency Conversion)**

**🔗 Endpoint:**
```
https://open.er-api.com/v6/latest/IDR
```

**Authentication:**
- ✅ **PUBLIC API - NO API KEY REQUIRED**
- Free tier: 1,500 calls/month
- Rate limited: 10 calls/minute

**HTTP Method:** `GET`

**Response Format:**
```json
{
  "result": "success",
  "documentation": "https://www.exchangerate-api.com/docs",
  "rates": {
    "IDR": 1.0,
    "USD": 0.000062,
    "JPY": 0.0095,
    "MYR": 0.00028,
    "SGD": 0.000084,
    "EUR": 0.000058
  },
  "base_currency": "IDR",
  "last_update_utc": "2025-12-02T10:30:00Z"
}
```

**Implementation:**
```dart
// File: lib/logic/services/service_konversi_mata_uang.dart
class ServiceKonversiMataUang {
  static Future<Map<String, double>> fetchKursIDR() async {
    const url = 'https://open.er-api.com/v6/latest/IDR';
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'USD': data['rates']['USD'],
        'JPY': data['rates']['JPY'],
        'MYR': data['rates']['MYR'],
      };
    }
  }
  
  // Fallback rates jika API gagal
  static const Map<String, double> _fallbackRates = {
    'USD': 0.000062,
    'JPY': 0.0095,
    'MYR': 0.00028,
  };
}
```

**Usage in App:**
```dart
// Convert IDR to USD
double hargaIDR = 1500000000;
double hargaUSD = await ServiceKonversiMataUang.konversiHarga(
  hargaIDR, 
  'USD'
);
// Result: ~93,000 USD
```

---

## **4. DATABASE & STORAGE**

### **Hive Database Architecture**

**What is Hive?**
- NoSQL local database for Flutter/Dart
- Type-safe key-value store
- Built-in encryption support
- No external dependencies (SQLite)
- Fast performance (~5000 ops/sec)

**Adapter Registration:**
```dart
// Main.dart initialization
await HiveService.init();

if (!Hive.isAdapterRegistered(1)) {
  Hive.registerAdapter(ModelTransaksiAdapter());
}
if (!Hive.isAdapterRegistered(2)) {
  Hive.registerAdapter(ModelUserAdapter());
}
```

**Box Operations:**
```dart
// Open box
final box = await Hive.openBox<ModelMobil>('mobil_box');

// Create
box.put('mobil_001', ModelMobil(...));

// Read
ModelMobil? mobil = box.get('mobil_001');
List<ModelMobil> all = box.values.toList();

// Update
box.put('mobil_001', updatedMobil);

// Delete
box.delete('mobil_001');

// Clear all
box.clear();

// Get count
int count = box.length;
```

---

## **5. SECURITY & ENCRYPTION**

### **A. Password Security (PBKDF2-HMAC-SHA256)**

**Implementation:**
```dart
// File: lib/logic/services/service_auth.dart

static const String _pepper = 'HEXOCAR#P3pp3r!2025';
static const int _pbkdf2Iterations = 10000;
static const int _saltLength = 32;
static const int _dkLen = 32;

// Password hashing process:
1. Generate random salt (32 bytes)
2. Salt + Pepper → PBKDF2
3. 10,000 iterations of HMAC-SHA256
4. Output: 32-byte hash

Example:
plainPassword = "MyPassword123!"
salt = "a7f3d4e2..." (random)
hash = _pbkdf2(plainPassword, salt)
stored = salt + "$" + hash
```

**Verification Process:**
```dart
1. User login dengan password
2. Extract salt dari database
3. Hash input password with stored salt
4. Compare hash dengan stored hash
5. Match = Login berhasil
```

**Code Example:**
```dart
// Hash password saat register
static Future<ModelUser?> register(String username, String password) async {
  final salt = _generateRandomSalt();
  final hash = _hashPasswordNew(password, salt);
  
  final user = ModelUser(
    id: 'user_${DateTime.now().millisecondsSinceEpoch}',
    username: username,
    password: '$salt\$$hash', // Simpan salt + hash
    email: email,
  );
  
  await _usersBox.put(user.id, user);
  return user;
}

// Verify password saat login
static Future<bool> verifyPassword(String inputPassword, String storedHash) async {
  final parts = storedHash.split('\$');
  final salt = parts[0];
  final hash = parts[1];
  
  final inputHash = _pbkdf2(inputPassword, salt);
  return inputHash == hash;
}
```

### **B. Session Management**

**Token Generation:**
```dart
static const int _sessionDays = 7;

static String _generateSessionToken() {
  final random = Random.secure();
  final values = List<int>.generate(32, (i) => random.nextInt(256));
  return base64Url.encode(values).replaceAll('=', '');
  // Example: "X7kPqM9nZ2bF4vW6yR8tU1jL5hQ3xC8mN9pA0bD6eE2gG7"
}
```

**Expiry Handling:**
```dart
static Future<void> _setSessionExpiry() async {
  final expiry = DateTime.now().add(Duration(days: 7));
  await _sessionBox.put(_keySessionExpiry, expiry.toIso8601String());
  // Example: "2025-12-09T10:30:00.000Z"
}

static Future<bool> isSessionValid() async {
  final expiryStr = _sessionBox.get(_keySessionExpiry);
  if (expiryStr == null) return false;
  
  final expiry = DateTime.parse(expiryStr);
  return DateTime.now().isBefore(expiry);
}
```

### **C. Data at Rest**

**Image Storage:**
- Images disimpan sebagai **Base64 string**
- Stored in Hive (dengan optional encryption)
- Size: ~4-8 MB per image (large)

**Example:**
```dart
// Convert image to Base64
Uint8List imageBytes = await imageFile.readAsBytes();
String base64Image = base64Encode(imageBytes);

// Store di Hive
ModelMobil mobil = ModelMobil(
  gambar: base64Image, // Base64 string
  // ...
);
```

---

## **6. MAPS & LOCATION SERVICES**

### **A. Google Maps Implementation**

**Features:**
```dart
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(-6.2088, 106.8456), // Jakarta
    zoom: 15.0,
  ),
  markers: {
    Marker(
      markerId: MarkerId('penjual_1'),
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(
        title: 'Lokasi Penjual',
        snippet: 'Klik untuk detail',
      ),
    ),
  },
  onMapCreated: (GoogleMapController controller) {
    mapController = controller;
  },
)
```

**Required Setup:**

**Android (AndroidManifest.xml):**
```xml
<application>
  <meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
</application>

<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

**iOS (Info.plist):**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Aplikasi membutuhkan akses lokasi Anda</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Aplikasi membutuhkan akses lokasi background</string>
```

### **B. Geolocator Service**

**Get Current Location:**
```dart
import 'package:geolocator/geolocator.dart';

// Request permission
LocationPermission permission = await Geolocator.requestPermission();

// Get current position
Position position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high,
  timeLimit: Duration(seconds: 10),
);

print('Latitude: ${position.latitude}');    // -6.2088
print('Longitude: ${position.longitude}');  // 106.8456
print('Accuracy: ${position.accuracy}');    // ±10 meters
print('Altitude: ${position.altitude}');    // 0 meters
```

**Listen to Location Changes:**
```dart
StreamSubscription<Position> positionStream =
  Geolocator.getPositionStream(
    locationSettings: LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    ),
  ).listen((Position position) {
    print('New location: ${position.latitude}, ${position.longitude}');
  });
```

### **C. Geocoding Service**

**Reverse Geocoding (Coordinates → Address):**
```dart
import 'package:geocoding/geocoding.dart';

List<Placemark> placemarks = await placemarkFromCoordinates(
  -6.2088,  // latitude
  106.8456  // longitude
);

Placemark place = placemarks[0];
print('Street: ${place.street}');           // Jl. Sudirman
print('City: ${place.locality}');           // Jakarta Selatan
print('Country: ${place.country}');         // Indonesia
print('Postal code: ${place.postalCode}');  // 12920
```

**Forward Geocoding (Address → Coordinates):**
```dart
List<Placemark> placemarks = await placemarkFromAddress(
  'Jl. Sudirman, Jakarta Selatan'
);

Placemark place = placemarks[0];
print('Latitude: ${place.latitude}');      // -6.2088
print('Longitude: ${place.longitude}');    // 106.8456
```

### **D. URL Launcher**

**Open Maps:**
```dart
import 'package:url_launcher/url_launcher.dart';

// Open Google Maps to location
final lat = -6.2088;
final lng = 106.8456;
final String googleMapsUrl = 
  'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
  await launchUrl(Uri.parse(googleMapsUrl));
}

// Or launch Waze
final String wazeUrl = 'https://waze.com/ul?ll=$lat,$lng&navigate=yes';
await launchUrl(Uri.parse(wazeUrl));
```

**WhatsApp Integration:**
```dart
// Send WhatsApp message
String phoneNumber = '6281234567890';
String message = 'Saya tertarik dengan mobil Anda';

final String whatsappUrl =
  'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
  await launchUrl(Uri.parse(whatsappUrl));
}
```

---

## **7. MEDIA HANDLING**

### **Image Picker**

**Pick from Gallery:**
```dart
import 'package:image_picker/image_picker.dart';

final ImagePicker picker = ImagePicker();

final XFile? image = await picker.pickImage(
  source: ImageSource.gallery,
  imageQuality: 85, // Compress to 85%
);

if (image != null) {
  Uint8List bytes = await image.readAsBytes();
  String base64String = base64Encode(bytes);
}
```

**Take Photo from Camera:**
```dart
final XFile? photo = await picker.pickImage(
  source: ImageSource.camera,
  preferredCameraDevice: CameraDevice.rear,
);
```

**Storage Locations:**
- Android: `/sdcard/DCIM/Camera/`
- iOS: `Photos Library`

---

## **8. NOTIFICATIONS**

### **Flutter Local Notifications**

**Android Setup (AndroidManifest.xml):**
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<application>
  <receiver
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
    android:exported="false">
    <intent-filter>
      <action android:name="android.intent.action.BOOT_COMPLETED" />
    </intent-filter>
  </receiver>
</application>
```

**Initialize:**
```dart
await ServiceNotifikasi.initialize();

// Android settings
const AndroidInitializationSettings initSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

// iOS settings
const DarwinInitializationSettings initSettingsIOS =
  DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

// Initialize
await flutterLocalNotificationsPlugin.initialize(
  InitializationSettings(
    android: initSettingsAndroid,
    iOS: initSettingsIOS,
  ),
);
```

**Show Notification:**
```dart
static Future<void> showNotification({
  required String title,
  required String body,
  required String payload,
}) async {
  const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'hexocar_channel',
      'HexoCar Notifications',
      channelDescription: 'Notifikasi transaksi dan update',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      vibrationPattern: [0, 250, 250, 250],
    );

  const DarwinNotificationDetails iosDetails =
    DarwinNotificationDetails(
      sound: 'notification_sound.caf',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

  await _notificationsPlugin.show(
    DateTime.now().millisecond,
    title,
    body,
    NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    ),
    payload: payload,
  );
}
```

---

## **9. UI/UX & STYLING**

### **Material Design 3**

**Theme Definition (app_theme.dart):**
```dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.backgroundColor,
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      
      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
```

### **Color Palette**

```dart
class AppColors {
  static const Color primary = Color(0xFF2193b0);        // Ocean Blue
  static const Color secondary = Color(0xFF6dd5ed);      // Sky Blue
  static const Color accent = Color(0xFFFF6B6B);         // Coral Red
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Gray
  static const Color success = Color(0xFF4CAF50);        // Green
  static const Color error = Color(0xFFFF6B6B);          // Red
  static const Color warning = Color(0xFFFFC107);        // Amber
  static const Color text = Color(0xFF212121);           // Dark Gray
  static const Color textHint = Color(0xFF9E9E9E);       // Medium Gray
}
```

### **Text Styles**

```dart
class AppTextStyles {
  static TextStyle get headline1 => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  
  static TextStyle get body1 => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.text,
  );
  
  static TextStyle get caption => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
  );
}
```

---

## **10. DEVELOPMENT TOOLS**

### **Code Generation (Hive)**

**pubspec.yaml (dev_dependencies):**
```yaml
dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

**Generate Adapters:**
```bash
# Run once
flutter pub run build_runner build

# Watch mode (auto-rebuild)
flutter pub run build_runner watch
```

**Generated Files:**
```
lib/logic/models/
├── model_user.g.dart       (auto-generated)
├── model_transaksi.g.dart  (auto-generated)
└── model_mobil.g.dart      (auto-generated)
```

### **Linting & Analysis**

```yaml
# analysis_options.yaml
linter:
  rules:
    - avoid_empty_else
    - avoid_print
    - avoid_relative_lib_imports
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - prefer_final_fields
    - prefer_final_in_for_each
```

**Run Analysis:**
```bash
flutter analyze
```

---

## **11. ARCHITECTURE OVERVIEW**

### **Folder Structure**

```
lib/
├── main.dart                 # Entry point
│   └── Initialize Hive, ServiceAuth, Notifications
│
├── styles/                   # 🎨 UI/Styling
│   ├── app_colors.dart
│   ├── app_theme.dart
│   ├── app_text_styles.dart
│   ├── app_constants.dart
│   └── styles.dart           # Export all
│
├── logic/                    # 🧠 Business Logic
│   ├── controllers/
│   │   ├── auth_controller.dart
│   │   ├── mobil_controller.dart
│   │   ├── transaksi_controller.dart
│   │   └── controllers.dart
│   │
│   ├── services/
│   │   ├── service_auth.dart            # PBKDF2 hashing
│   │   ├── service_mobil.dart           # CRUD mobil lokal
│   │   ├── service_mobil_api.dart       # NHTSA API
│   │   ├── service_transaksi.dart       # Transaction logic
│   │   ├── service_notifikasi.dart      # Local notifications
│   │   ├── service_konversi_mata_uang.dart # Currency API
│   │   └── service_waktu.dart           # Time utilities
│   │
│   ├── models/
│   │   ├── model_user.dart              # Hive model
│   │   ├── model_mobil.dart             # Hive model
│   │   ├── model_transaksi.dart         # Hive model
│   │   ├── hive_service.dart            # Hive manager
│   │   ├── data_profil.dart
│   │   ├── model_user.g.dart            # Generated
│   │   └── model_transaksi.g.dart       # Generated
│   │
│   └── logic.dart           # Export all logic
│
└── screens/                  # 📱 UI/Screens
    ├── halaman_splash.dart
    ├── halaman_login.dart
    ├── halaman_register.dart
    ├── halaman_beranda.dart
    ├── halaman_profil.dart
    ├── halaman_tambah_mobil.dart
    ├── halaman_beli_mobil.dart
    ├── halaman_transaksi.dart
    ├── halaman_riwayat_transaksi.dart
    ├── halaman_daftar_mobil_api.dart
    ├── halaman_pilih_metode_pembayaran.dart
    └── screens.dart         # Export all screens
```

### **Data Flow**

```
User Input
   ↓
Widget (Screen)
   ↓
Service/Logic (Business Logic)
   ↓
Hive Database / External API
   ↓
Display in UI
```

**Example: Login Flow**
```
1. User fills username & password in HalamanLogin
2. User clicks "Login" button
3. HalamanLogin calls ServiceAuth.login(username, password)
4. ServiceAuth:
   - Fetch user from Hive (users_box)
   - Extract salt dari stored password hash
   - Hash input password dengan salt
   - Compare hash dengan stored hash
5. If match:
   - Generate session token
   - Set session expiry (7 days)
   - Save to Hive (session_box)
   - Return user object
6. Navigate to HalamanBeranda
7. HalamanBeranda calls ServiceMobil.daftarMobil()
8. Display mobil list in UI
```

---

## **12. TECH STACK SUMMARY**

### **Quick Reference Table**

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| **Framework** | Flutter | 3.9.2+ | Mobile App Development |
| **Language** | Dart | 3.9.2+ | Programming Language |
| **Design** | Material Design | 3.0 | UI Framework |
| **Database** | Hive | 2.2.3 | NoSQL Local Database |
| **Legacy Storage** | SharedPreferences | 2.2.2 | Key-value Storage |
| **HTTP** | http | 1.1.0 | API Calls |
| **Security** | crypto | 3.0.3 | PBKDF2-HMAC-SHA256 |
| **Maps** | google_maps_flutter | 2.5.0 | Map Display |
| **Location** | geolocator | 10.1.0 | GPS Services |
| **Geocoding** | geocoding | 2.1.1 | Coordinates ↔ Address |
| **URL Launch** | url_launcher | 6.2.2 | External App Launch |
| **Media** | image_picker | 1.0.7 | Image Selection |
| **Notifications** | flutter_local_notifications | 17.2.3 | Push Notifications |
| **Toast** | another_flushbar | 1.12.30 | Toast Messages |
| **Formatting** | intl | 0.18.1 | Date/Currency Format |
| **Fonts** | google_fonts | 6.3.2 | Custom Fonts |
| **File Storage** | path_provider | 2.1.1 | File System Access |

### **External APIs**

| API | Endpoint | Auth | Rate Limit | Data |
|-----|----------|------|-----------|------|
| **NHTSA** | vpic.nhtsa.dot.gov | FREE | Unlimited | Car Models |
| **Google Maps** | maps.googleapis.com | Key | 25,000 req/day | Geocoding |
| **Exchange Rate** | open.er-api.com | FREE | 1,500/month | Currency |

### **Security Features**

- ✅ PBKDF2-HMAC-SHA256 password hashing (10,000 iterations)
- ✅ Random salt + pepper
- ✅ Session token with 7-day expiry
- ✅ HTTPS for API calls
- ✅ Base64 image encoding
- ✅ Offline-first with Hive database

### **Platforms Supported**

- ✅ Android 6.0+
- ✅ iOS 11.0+
- 🔲 Web (future)
- 🔲 macOS (future)
- 🔲 Windows (future)
- 🔲 Linux (future)

---

## **📦 DEPENDENCIES INSTALLATION**

```bash
# Get all dependencies
flutter pub get

# Generate code (Hive adapters)
flutter pub run build_runner build

# Run app
flutter run

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

---

## **🎯 KEY HIGHLIGHTS**

1. **Offline-First Architecture** - Works without internet (Hive database)
2. **Security-Focused** - PBKDF2 encryption, session management
3. **Free APIs** - NHTSA & ExchangeRate APIs don't need keys
4. **Location Services** - Complete GPS, maps, and geocoding integration
5. **Cross-Platform** - Single codebase for Android & iOS
6. **Scalable** - Clean architecture ready for expansion
7. **Modern UI** - Material Design 3 with custom styling

---

**Last Updated:** December 2, 2025
**App Version:** 1.0.0
**Author:** HexoCar Team

