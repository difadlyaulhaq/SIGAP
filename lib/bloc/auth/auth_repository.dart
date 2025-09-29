// lib/bloc/auth/auth_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rescuein/models/medical_history_model.dart';
import 'package:rescuein/models/user_model.dart';
import 'package:uuid/uuid.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get user => _firebaseAuth.authStateChanges();
  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> signUp({
    required String email,
    required String password,
    required String nama,
    required String jenisKelamin,
    required DateTime tanggalLahir,
    required String telepon,
    required String alamat,
    required String golonganDarah,
    required String kontakDarurat,
    // FIX: Tipe data disesuaikan menjadi List<String>
    required List<String> alergi,
    required List<String> riwayatPenyakit,
    required List<String> obatRutin,
    required String catatanTambahan,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception("Gagal membuat user, tidak ada data user.");
      }

      final userId = credential.user!.uid;

      await _saveUserData(
        userId: userId,
        email: email,
        nama: nama,
        telepon: telepon,
        alamat: alamat,
        jenisKelamin: jenisKelamin,
        tanggalLahir: tanggalLahir,
        golonganDarah: golonganDarah,
        kontakDarurat: kontakDarurat,
      );

      await _saveMedicalHistory(
        userId: userId,
        alergi: alergi,
        riwayatPenyakit: riwayatPenyakit,
        obatRutin: obatRutin,
        catatanTambahan: catatanTambahan,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Terjadi eror saat pendaftaran');
    }
  }

  Future<void> _saveUserData({
    required String userId,
    required String email,
    required String nama,
    required String telepon,
    required String alamat,
    required String jenisKelamin,
    required DateTime tanggalLahir,
    required String golonganDarah,
    required String kontakDarurat,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'uid': userId,
      'email': email,
      'nama': nama,
      'telepon': telepon,
      'alamat': alamat,
      'jenisKelamin': jenisKelamin,
      'tanggalLahir': Timestamp.fromDate(tanggalLahir),
      'golonganDarah': golonganDarah,
      'kontakDarurat': kontakDarurat,
    });
  }

  Future<void> _saveMedicalHistory({
    required String userId,
    required List<String> alergi,
    required List<String> riwayatPenyakit,
    required List<String> obatRutin,
    required String catatanTambahan,
  }) async {
    await _firestore.collection('medicalHistories').doc(userId).set({
      'alergi': alergi,
      'riwayatPenyakit': riwayatPenyakit,
      'obatRutin': obatRutin,
      'catatanTambahan': catatanTambahan,
    });
  }

  // FIX: Tambahkan parameter opsional {bool forceOnline = false}
  Future<UserModel> getUserData(String userId, {bool forceOnline = false}) async {
    // Anda bisa menambahkan logika caching di sini menggunakan `forceOnline`
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        throw Exception("User data not found!");
      }
    } catch (e) {
      throw Exception("Failed to get user data: $e");
    }
  }

  Future<MedicalHistoryModel> getMedicalHistory(String userId) async {
    try {
      final doc =
          await _firestore.collection('medicalHistories').doc(userId).get();
      if (doc.exists) {
        return MedicalHistoryModel.fromFirestore(doc);
      } else {
        throw Exception("Medical history not found!");
      }
    } catch (e) {
      throw Exception("Failed to get medical history: $e");
    }
  }

  Future<String> getOrCreateEmergencyId(String userId) async {
    try {
      final userDocRef = _firestore.collection('users').doc(userId);
      final userDoc = await userDocRef.get();

      if (userDoc.exists && userDoc.data()!.containsKey('emergencyId')) {
        return userDoc.data()!['emergencyId'] as String;
      } else {
        final uuid = Uuid();
        final newEmergencyId = uuid.v4();
        await userDocRef.update({'emergencyId': newEmergencyId});
        return newEmergencyId;
      }
    } catch (e) {
      throw Exception('Gagal mendapatkan atau membuat Emergency ID: $e');
    }
  }

  Future<void> updateMedicalHistory({
    required String userId,
    required MedicalHistoryModel medicalHistory,
  }) async {
    try {
      final docRef = _firestore.collection('medicalHistories').doc(userId);
      await docRef.update(medicalHistory.toJson());
    } catch (e) {
      throw Exception('Error updating medical history: $e');
    }
  }

  Future<void> logIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Terjadi eror saat login');
    }
  }

  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }
  
  // FIX: Tambahkan metode-metode yang hilang yang dipanggil oleh BLoC
  Future<void> autoSyncIfNeeded() async {
    // TODO: Implementasikan logika sinkronisasi data otomatis di sini
    print("Auto-syncing data if needed...");
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<bool> hasValidOfflineSession() async {
    // TODO: Implementasikan logika pengecekan sesi offline di sini
    print("Checking for valid offline session...");
    return false; // Ganti dengan logika sesungguhnya
  }

  Future<void> refreshUserData() async {
    // TODO: Implementasikan logika untuk refresh data pengguna dari server
    print("Refreshing user data...");
    final user = currentUser;
    if (user != null) {
      await getUserData(user.uid, forceOnline: true);
    }
  }
} // FIX: Hapus satu '}' berlebih dari sini