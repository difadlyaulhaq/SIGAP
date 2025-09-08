import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalHistoryModel {
  final List<String> alergi;
  final List<String> riwayatPenyakit;
  final List<String> obatRutin;
  final String catatanTambahan;

  MedicalHistoryModel({
    required this.alergi,
    required this.riwayatPenyakit,
    required this.obatRutin,
    required this.catatanTambahan,
  });

  // Factory constructor untuk membuat instance dari Firestore document
  factory MedicalHistoryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MedicalHistoryModel(
      // Menggunakan List.from untuk konversi yang aman dari List<dynamic>
      alergi: List<String>.from(data['alergi'] ?? []),
      riwayatPenyakit: List<String>.from(data['riwayatPenyakit'] ?? []),
      obatRutin: List<String>.from(data['obatRutin'] ?? []),
      catatanTambahan: data['catatanTambahan'] ?? '',
    );
  }

  // TAMBAHKAN METHOD INI 👇
  // Method untuk mengubah instance menjadi Map agar bisa disimpan ke Firestore
  Map<String, dynamic> toJson() {
    return {
      'alergi': alergi,
      'riwayatPenyakit': riwayatPenyakit,
      'obatRutin': obatRutin,
      'catatanTambahan': catatanTambahan,
    };
  }
}