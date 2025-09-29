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
      alergi: List<String>.from(data['alergi'] ?? []),
      riwayatPenyakit: List<String>.from(data['riwayatPenyakit'] ?? []),
      obatRutin: List<String>.from(data['obatRutin'] ?? []),
      catatanTambahan: data['catatanTambahan'] ?? '',
    );
  }

  // ==> [FIX] TAMBAHKAN FACTORY CONSTRUCTOR INI <==
  // Factory constructor untuk membuat instance dari JSON map (dari SharedPreferences)
  factory MedicalHistoryModel.fromJson(Map<String, dynamic> json) {
    return MedicalHistoryModel(
      alergi: List<String>.from(json['alergi'] ?? []),
      riwayatPenyakit: List<String>.from(json['riwayatPenyakit'] ?? []),
      obatRutin: List<String>.from(json['obatRutin'] ?? []),
      catatanTambahan: json['catatanTambahan'] ?? '',
    );
  }

  factory MedicalHistoryModel.empty() {
    return MedicalHistoryModel(
      alergi: [],
      riwayatPenyakit: [],
      obatRutin: [],
      catatanTambahan: 'Data medis tidak tersedia saat offline.',
    );
  }

  // Method untuk mengubah instance menjadi Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'alergi': alergi,
      'riwayatPenyakit': riwayatPenyakit,
      'obatRutin': obatRutin,
      'catatanTambahan': catatanTambahan,
    };
  }
}