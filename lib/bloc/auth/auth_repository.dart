import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Stream untuk memantau perubahan status autentikasi
  Stream<User?> get user => _firebaseAuth.authStateChanges();

  // Fungsi untuk signup
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
    required List<String> alergi,
    required List<String> riwayatPenyakit,
    required List<String> obatRutin,
    required String catatanTambahan,
  }) async {
    try {
      // 1. Buat user di Firebase Authentication
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception("Gagal membuat user, tidak ada data user.");
      }

      final userId = credential.user!.uid;

      // 2. Simpan data user ke collection 'users'
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

      // 3. Simpan data riwayat kesehatan ke collection 'medicalHistories'
      await _saveMedicalHistory(
        userId: userId,
        alergi: alergi,
        riwayatPenyakit: riwayatPenyakit,
        obatRutin: obatRutin,
        catatanTambahan: catatanTambahan,
      );
    } on FirebaseAuthException catch (e) {
      // Menangani eror spesifik dari Firebase Auth
      throw Exception(e.message ?? 'Terjadi eror saat pendaftaran');
    }
  }

  // --- PERBAIKAN DI SINI ---
  // Fungsi untuk menyimpan data user utama
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
      'tanggalLahir': Timestamp.fromDate(tanggalLahir), // Konversi ke Timestamp
      'golonganDarah': golonganDarah,
      'kontakDarurat': kontakDarurat,
    });
  }

  // --- PERBAIKAN DI SINI ---
  // Fungsi untuk menyimpan riwayat kesehatan
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

  // Fungsi untuk login
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

  // Fungsi untuk logout
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }
}