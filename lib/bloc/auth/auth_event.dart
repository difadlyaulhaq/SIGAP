// lib/bloc/auth/auth_event.dart

part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class _AuthUserChanged extends AuthEvent {
  final User? user;
  _AuthUserChanged(this.user);
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested({required this.email, required this.password});
}

class AuthSignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String nama;
  final String jenisKelamin;
  final DateTime tanggalLahir;
  final String telepon;
  final String alamat;
  final String golonganDarah;
  final String kontakDarurat;
  // FIX: Ubah tipe data menjadi List<String>
  final List<String> alergi;
  final List<String> riwayatPenyakit;
  final List<String> obatRutin;
  final String catatanTambahan;

  AuthSignupRequested({
    required this.email,
    required this.password,
    required this.nama,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.telepon,
    required this.alamat,
    required this.golonganDarah,
    required this.kontakDarurat,
    required this.alergi,
    required this.riwayatPenyakit,
    required this.obatRutin,
    required this.catatanTambahan,
  });
}

class AuthLogoutRequested extends AuthEvent {}

class AuthRefreshRequested extends AuthEvent {}

class AuthRestoreOfflineSession extends AuthEvent {}