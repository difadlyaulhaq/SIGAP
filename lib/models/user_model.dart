import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nama;
  final String email;
  final String telepon;
  final String alamat;
  final String jenisKelamin;
  final DateTime tanggalLahir;
  final String golonganDarah;
  final String kontakDarurat;

  UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    required this.telepon,
    required this.alamat,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.golonganDarah,
    required this.kontakDarurat,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'],
      nama: data['nama'],
      email: data['email'],
      telepon: data['telepon'],
      alamat: data['alamat'],
      jenisKelamin: data['jenisKelamin'],
      tanggalLahir: (data['tanggalLahir'] as Timestamp).toDate(),
      golonganDarah: data['golonganDarah'],
      kontakDarurat: data['kontakDarurat'],
    );
  }
}