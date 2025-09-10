import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:rescuein/bloc/auth/auth_repository.dart';
import 'package:rescuein/services/session_manager.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _userSubscription;
  bool _isInitialCheck = true;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthSignupRequested>(_onAuthSignupRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);

    _userSubscription = _authRepository.user.listen((user) {
      if (!_isInitialCheck) {
        print('Firebase User changed (not initial): ${user?.email ?? 'null'}');
        add(AuthCheckRequested());
      }
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthCheckRequested received (initial: $_isInitialCheck)');
    
    if (state is! AuthLoading) {
      emit(AuthLoading());
    }
    
    try {
      final currentUser = _authRepository.currentUser;
      print('Current user: ${currentUser?.email ?? 'null'}');
      
      if (_isInitialCheck) {
        await Future.delayed(const Duration(milliseconds: 1000));
      }
      
      if (currentUser != null) {
        emit(AuthAuthenticated(user: currentUser));
      } else {
        emit(AuthUnauthenticated());
      }
      
      if (_isInitialCheck) {
        _isInitialCheck = false;
      }
      
    } catch (e) {
      print('AuthCheckRequested error: $e');
      emit(AuthUnauthenticated());
      
      if (_isInitialCheck) {
        _isInitialCheck = false;
      }
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('Login requested for: ${event.email}');
    emit(AuthLoading());
    
    try {
      await _authRepository.logIn(
        email: event.email, 
        password: event.password
      );
      
      final currentUser = _authRepository.currentUser;
      if (currentUser != null) {
        final userModel = await _authRepository.getUserData(currentUser.uid);
        await SessionManager.instance.saveSession(userModel);
        emit(AuthAuthenticated(user: currentUser));
      } else {
        throw Exception('Login berhasil tapi user tidak ditemukan');
      }
      
    } catch (e) {
      print('Login error: $e');
      emit(AuthFailure(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onAuthSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('Signup requested for: ${event.email}');
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
      
      final currentUser = _authRepository.currentUser;
      if (currentUser != null) {
        final userModel = await _authRepository.getUserData(currentUser.uid);
        await SessionManager.instance.saveSession(userModel);
        emit(AuthAuthenticated(user: currentUser));
      } else {
        throw Exception('Registrasi berhasil tapi user tidak ditemukan');
      }
      
    } catch (e) {
      print('Signup error: $e');
      emit(AuthFailure(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('Logout requested');
    emit(AuthLoading());
    
    try {
      await _authRepository.logOut();
      await SessionManager.instance.clearSession();
      emit(AuthUnauthenticated());
    } catch (e) {
      print('Logout error: $e');
      await SessionManager.instance.clearSession();
      emit(AuthUnauthenticated());
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