import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String nama;
  final String jenisKelamin;
  final DateTime tanggalLahir;
  final String telepon;
  final String alamat;
  final String golonganDarah;
  final String kontakDarurat;
  final String? emergencyId; // Bisa null saat awal dibuat

  UserModel({
    required this.uid,
    required this.email,
    required this.nama,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.telepon,
    required this.alamat,
    required this.golonganDarah,
    required this.kontakDarurat,
    this.emergencyId,
  });

  // --- METODE BARU UNTUK MEMBACA DARI FIRESTORE ---
  // Mengubah DocumentSnapshot dari Firestore menjadi objek UserModel
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      nama: data['nama'] ?? '',
      jenisKelamin: data['jenisKelamin'] ?? '',
      // Mengonversi Timestamp Firebase menjadi DateTime Dart
      tanggalLahir: (data['tanggalLahir'] as Timestamp).toDate(),
      telepon: data['telepon'] ?? '',
      alamat: data['alamat'] ?? '',
      golonganDarah: data['golonganDarah'] ?? '',
      kontakDarurat: data['kontakDarurat'] ?? '',
      emergencyId: data['emergencyId'],
    );
  }

  // --- METODE BARU UNTUK LOCAL STORAGE (SharedPreferences) ---
  // Mengubah data Map (dari JSON) menjadi objek UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      nama: json['nama'] ?? '',
      jenisKelamin: json['jenisKelamin'] ?? '',
      // Mengonversi string ISO 8601 menjadi DateTime
      tanggalLahir: DateTime.parse(json['tanggalLahir']),
      telepon: json['telepon'] ?? '',
      alamat: json['alamat'] ?? '',
      golonganDarah: json['golonganDarah'] ?? '',
      kontakDarurat: json['kontakDarurat'] ?? '',
      emergencyId: json['emergencyId'],
    );
  }

  // --- METODE BARU UNTUK LOCAL STORAGE (SharedPreferences) ---
  // Mengubah objek UserModel menjadi Map untuk disimpan sebagai JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'nama': nama,
      'jenisKelamin': jenisKelamin,
      // Mengonversi DateTime menjadi string format ISO 8601 agar bisa di-encode
      'tanggalLahir': tanggalLahir.toIso8601String(),
      'telepon': telepon,
      'alamat': alamat,
      'golonganDarah': golonganDarah,
      'kontakDarurat': kontakDarurat,
      'emergencyId': emergencyId,
    };
  }
}