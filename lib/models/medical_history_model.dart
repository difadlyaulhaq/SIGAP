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

  factory MedicalHistoryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MedicalHistoryModel(
      alergi: List<String>.from(data['alergi'] ?? []),
      riwayatPenyakit: List<String>.from(data['riwayatPenyakit'] ?? []),
      obatRutin: List<String>.from(data['obatRutin'] ?? []),
      catatanTambahan: data['catatanTambahan'] ?? '',
    );
  }
}