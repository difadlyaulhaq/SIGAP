import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rescuein/models/user_model.dart';
import 'package:rescuein/models/medical_history_model.dart';

class SessionManager {
  static SessionManager? _instance;
  static SessionManager get instance => _instance ??= SessionManager._();
  
  SessionManager._();
  
  SharedPreferences? _prefs;
  
  // Keys untuk penyimpanan
  static const String _userDataKey = 'user_data';
  static const String _medicalHistoryKey = 'medical_history';
  static const String _loginCredentialsKey = 'login_credentials';
  static const String _lastSyncKey = 'last_sync';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _emergencyIdKey = 'emergency_id';
  
  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ========== USER SESSION MANAGEMENT ==========
  
  /// Menyimpan sesi lengkap pengguna (user data + medical history)
  Future<void> saveSession(UserModel user, {MedicalHistoryModel? medicalHistory}) async {
    try {
      final preferences = await prefs;
      
      // Simpan user data
      final userJson = jsonEncode(user.toJson());
      await preferences.setString(_userDataKey, userJson);
      
      // Simpan medical history jika ada
      if (medicalHistory != null) {
        final medicalJson = jsonEncode(medicalHistory.toJson());
        await preferences.setString(_medicalHistoryKey, medicalJson);
      }
      
      // Tandai sebagai logged in
      await preferences.setBool(_isLoggedInKey, true);
      await preferences.setString(_userIdKey, user.uid);
      
      // Simpan timestamp sync terakhir
      await preferences.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      
      print('✅ Session saved successfully for user: ${user.nama}');
    } catch (e) {
      print('❌ Error saving session: $e');
      throw Exception('Failed to save user session: $e');
    }
  }
  
  /// Mendapatkan data user yang tersimpan
  Future<UserModel?> getUserData() async {
    try {
      final preferences = await prefs;
      final userJson = preferences.getString(_userDataKey);
      
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
    }
  }
  
  /// Mendapatkan medical history yang tersimpan
  Future<MedicalHistoryModel?> getMedicalHistory() async {
    try {
      final preferences = await prefs;
      final medicalJson = preferences.getString(_medicalHistoryKey);
      
      if (medicalJson != null) {
        final medicalMap = jsonDecode(medicalJson) as Map<String, dynamic>;
        return MedicalHistoryModel.fromJson(medicalMap);
      }
      return null;
    } catch (e) {
      print('❌ Error getting medical history: $e');
      return null;
    }
  }
  
  /// Update medical history tersimpan
  Future<void> updateMedicalHistory(MedicalHistoryModel medicalHistory) async {
    try {
      final preferences = await prefs;
      final medicalJson = jsonEncode(medicalHistory.toJson());
      await preferences.setString(_medicalHistoryKey, medicalJson);
      
      // Update timestamp sync
      await preferences.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      
      print('✅ Medical history updated successfully');
    } catch (e) {
      print('❌ Error updating medical history: $e');
      throw Exception('Failed to update medical history: $e');
    }
  }
  
  /// Cek apakah user sudah login
  Future<bool> isLoggedIn() async {
    try {
      final preferences = await prefs;
      return preferences.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('❌ Error checking login status: $e');
      return false;
    }
  }
  
  /// Mendapatkan user ID yang tersimpan
  Future<String?> getCurrentUserId() async {
    try {
      final preferences = await prefs;
      return preferences.getString(_userIdKey);
    } catch (e) {
      print('❌ Error getting current user ID: $e');
      return null;
    }
  }

  // ========== EMERGENCY ID MANAGEMENT ==========
  
  /// Menyimpan Emergency ID
  Future<void> saveEmergencyId(String emergencyId) async {
    try {
      final preferences = await prefs;
      await preferences.setString(_emergencyIdKey, emergencyId);
      print('✅ Emergency ID saved successfully');
    } catch (e) {
      print('❌ Error saving emergency ID: $e');
    }
  }
  
  /// Mendapatkan Emergency ID yang tersimpan
  Future<String?> getEmergencyId() async {
    try {
      final preferences = await prefs;
      return preferences.getString(_emergencyIdKey);
    } catch (e) {
      print('❌ Error getting emergency ID: $e');
      return null;
    }
  }

  // ========== LOGIN CREDENTIALS (OPTIONAL) ==========
  
  /// Menyimpan kredensial login (opsional, untuk remember me)
  Future<void> saveLoginCredentials(String email, String encryptedPassword) async {
    try {
      final preferences = await prefs;
      final credentials = {
        'email': email,
        'password': encryptedPassword,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await preferences.setString(_loginCredentialsKey, jsonEncode(credentials));
      print('✅ Login credentials saved');
    } catch (e) {
      print('❌ Error saving login credentials: $e');
    }
  }
  
  /// Mendapatkan kredensial login yang tersimpan
  Future<Map<String, dynamic>?> getLoginCredentials() async {
    try {
      final preferences = await prefs;
      final credentialsJson = preferences.getString(_loginCredentialsKey);
      
      if (credentialsJson != null) {
        return jsonDecode(credentialsJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('❌ Error getting login credentials: $e');
      return null;
    }
  }

  // ========== SYNC MANAGEMENT ==========
  
  /// Mendapatkan timestamp sync terakhir
  Future<DateTime?> getLastSyncTime() async {
    try {
      final preferences = await prefs;
      final timestamp = preferences.getInt(_lastSyncKey);
      
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    } catch (e) {
      print('❌ Error getting last sync time: $e');
      return null;
    }
  }
  
  /// Cek apakah data perlu di-sync ulang (lebih dari 24 jam)
  Future<bool> needsSync() async {
    try {
      final lastSync = await getLastSyncTime();
      if (lastSync == null) return true;
      
      final now = DateTime.now();
      final difference = now.difference(lastSync);
      
      return difference.inHours >= 24; // Sync jika lebih dari 24 jam
    } catch (e) {
      print('❌ Error checking sync status: $e');
      return true;
    }
  }
  
  /// Update timestamp sync
  Future<void> updateSyncTime() async {
    try {
      final preferences = await prefs;
      await preferences.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('❌ Error updating sync time: $e');
    }
  }

  // ========== SESSION CLEANUP ==========
  
  /// Membersihkan semua data sesi
  Future<void> clearSession() async {
    try {
      final preferences = await prefs;
      
      // Hapus semua data user
      await preferences.remove(_userDataKey);
      await preferences.remove(_medicalHistoryKey);
      await preferences.remove(_loginCredentialsKey);
      await preferences.remove(_lastSyncKey);
      await preferences.remove(_isLoggedInKey);
      await preferences.remove(_userIdKey);
      await preferences.remove(_emergencyIdKey);
      
      print('✅ Session cleared successfully');
    } catch (e) {
      print('❌ Error clearing session: $e');
      throw Exception('Failed to clear session: $e');
    }
  }
  
  /// Membersihkan hanya kredensial login (tetap simpan data user)
  Future<void> clearLoginCredentials() async {
    try {
      final preferences = await prefs;
      await preferences.remove(_loginCredentialsKey);
      print('✅ Login credentials cleared');
    } catch (e) {
      print('❌ Error clearing login credentials: $e');
    }
  }

  // ========== UTILITY METHODS ==========
  
  /// Mendapatkan informasi storage yang digunakan
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final preferences = await prefs;
      
      return {
        'hasUserData': preferences.getString(_userDataKey) != null,
        'hasMedicalHistory': preferences.getString(_medicalHistoryKey) != null,
        'hasCredentials': preferences.getString(_loginCredentialsKey) != null,
        'isLoggedIn': preferences.getBool(_isLoggedInKey) ?? false,
        'lastSync': await getLastSyncTime(),
        'needsSync': await needsSync(),
        'userId': preferences.getString(_userIdKey),
      };
    } catch (e) {
      print('❌ Error getting storage info: $e');
      return {};
    }
  }
  
  /// Debug: Print semua data yang tersimpan
  Future<void> debugPrintStoredData() async {
    try {
      final info = await getStorageInfo();
      print('📱 STORED DATA INFO:');
      print('   - Has User Data: ${info['hasUserData']}');
      print('   - Has Medical History: ${info['hasMedicalHistory']}');
      print('   - Has Credentials: ${info['hasCredentials']}');
      print('   - Is Logged In: ${info['isLoggedIn']}');
      print('   - User ID: ${info['userId']}');
      print('   - Last Sync: ${info['lastSync']}');
      print('   - Needs Sync: ${info['needsSync']}');
    } catch (e) {
      print('❌ Error in debug print: $e');
    }
  }
}