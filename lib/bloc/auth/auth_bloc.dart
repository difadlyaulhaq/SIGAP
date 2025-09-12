import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:rescuein/bloc/auth/auth_repository.dart';
import 'package:rescuein/bloc/auth/auth_state.dart';
import 'package:rescuein/services/session_manager.dart';

part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<_AuthUserChanged>(_onAuthUserChanged);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthSignupRequested>(_onAuthSignupRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);

    _userSubscription = _authRepository.user.listen((user) {
      add(_AuthUserChanged(user));
    });
  }

  Future<void> _onAuthUserChanged(
    _AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    final user = event.user;
    if (user != null) {
      try {
        final userModel = await _authRepository.getUserData(user.uid);
        await SessionManager.instance.saveSession(userModel);
        emit(AuthAuthenticated(user: user));
      } catch (e) {
        emit(AuthFailure(message: "Gagal memuat data profil. Silakan coba lagi."));
      }
    } else {
      await SessionManager.instance.clearSession();
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.logIn(
        email: event.email, 
        password: event.password
      );
    } catch (e) {
      emit(AuthFailure(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onAuthSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
        nama: event.nama,
        jenisKelamin: event.jenisKelamin,
        tanggalLahir: event.tanggalLahir,
        telepon: event.telepon,
        alamat: event.alamat,
        golonganDarah: event.golonganDarah,
        kontakDarurat: event.kontakDarurat,
        alergi: event.alergi,
        riwayatPenyakit: event.riwayatPenyakit,
        obatRutin: event.obatRutin,
        catatanTambahan: event.catatanTambahan,
      );
    } catch (e) {
      emit(AuthFailure(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.logOut();
    } catch (e) {
      print('Logout error: $e');
      emit(AuthFailure(message: 'Gagal untuk logout.'));
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Email tidak ditemukan. Silakan daftar terlebih dahulu.';
        case 'wrong-password':
          return 'Password salah. Silakan coba lagi.';
        case 'email-already-in-use':
          return 'Email sudah digunakan. Silakan gunakan email lain.';
        case 'weak-password':
          return 'Password terlalu lemah. Gunakan minimal 8 karakter.';
        case 'invalid-email':
          return 'Format email tidak valid.';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan. Silakan coba lagi nanti.';
        case 'network-request-failed':
          return 'Gagal terhubung ke internet. Periksa koneksi Anda.';
        case 'invalid-credential':
          return 'Email atau password salah. Silakan coba lagi.';
        default:
          return error.message ?? 'Terjadi kesalahan. Silakan coba lagi.';
      }
    }
    return error.toString().replaceAll('Exception: ', '');
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}