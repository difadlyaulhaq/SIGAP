import 'dart:convert';
import 'package:rescuein/models/user_model.dart'; // Pastikan path ini benar
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // Singleton pattern untuk memastikan hanya ada satu instance
  SessionManager._privateConstructor();
  static final SessionManager _instance = SessionManager._privateConstructor();
  static SessionManager get instance => _instance;

  static SharedPreferences? _prefs;

  // Kunci untuk data di SharedPreferences
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserData = 'userData';

  // Inisialisasi SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Menyimpan sesi login dan data user
  Future<void> saveSession(UserModel user) async {
    if (_prefs == null) await init();
    
    await _prefs!.setBool(_keyIsLoggedIn, true);
    
    // GANTI toFirestore() menjadi toJson()
    String userJson = jsonEncode(user.toJson()); 
    await _prefs!.setString(_keyUserData, userJson);
    print("Sesi dan data pengguna disimpan: ${user.nama}");
  }

  // Mengambil data user dari local storage
Future<UserModel?> getUserData() async {
    if (_prefs == null) await init();
    
    final userJson = _prefs!.getString(_keyUserData);
    if (userJson != null) {
      // Metode fromJson sekarang sudah ada di UserModel
      return UserModel.fromJson(jsonDecode(userJson)); 
    }
    return null;
  }

  // Memeriksa apakah user sudah login
  Future<bool> isLoggedIn() async {
    if (_prefs == null) await init();
    
    return _prefs!.getBool(_keyIsLoggedIn) ?? false;
  }

  // Menghapus sesi saat logout
  Future<void> clearSession() async {
    if (_prefs == null) await init();
    
    await _prefs!.clear();
    print("Sesi pengguna dibersihkan.");
  }
}