// lib/bloc/auth/auth_bloc.dart

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
  Timer? _autoSyncTimer;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    // Event handlers
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<_AuthUserChanged>(_onAuthUserChanged);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthSignupRequested>(_onAuthSignupRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthRefreshRequested>(_onAuthRefreshRequested);
    on<AuthRestoreOfflineSession>(_onAuthRestoreOfflineSession);

    // Listen to Firebase Auth state changes
    _userSubscription = _authRepository.user.listen((user) {
      add(_AuthUserChanged(user));
    });

    // Setup auto-sync timer
    _setupAutoSync();
  }

  void _setupAutoSync() {
    _autoSyncTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      if (state is AuthAuthenticated) {
        _authRepository.autoSyncIfNeeded();
      }
    });
  }

  // ========== AUTH CHECK (STARTUP) ==========
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser != null) {
        // User masih login di Firebase
        // Lakukan logging: '🔄 Firebase user found, validating session...'
        try {
          await currentUser.getIdToken(true);
          final hasOfflineSession = await _authRepository.hasValidOfflineSession();
          if (hasOfflineSession) {
            // Gunakan data offline sambil sync di background
            // Lakukan logging: '📱 Using offline session data'
            final userData = await SessionManager.instance.getUserData();
            if (userData != null) {
              emit(AuthAuthenticated(user: currentUser));
              _authRepository.autoSyncIfNeeded();
              return;
            }
          }
          // Tidak ada data offline yang valid, fetch dari server
          // Lakukan logging: '🌐 Fetching fresh data from server...'
          final userModel = await _authRepository.getUserData(currentUser.uid);
          await SessionManager.instance.saveSession(userModel);
          emit(AuthAuthenticated(user: currentUser));
        } catch (e) {
          // Lakukan logging error: '❌ Token validation failed: $e'
          await _tryOfflineSession(emit);
        }
      } else {
        // Lakukan logging: '🔍 No Firebase user, checking offline session...'
        await _tryOfflineSession(emit);
      }
    } catch (e) {
      // Lakukan logging error: '❌ Auth check error: $e'
      await _tryOfflineSession(emit);
    }
  }

  Future<void> _tryOfflineSession(Emitter<AuthState> emit) async {
    try {
      final hasOfflineSession = await _authRepository.hasValidOfflineSession();
      if (hasOfflineSession) {
        // Lakukan logging: '📱 Valid offline session found, using cached data'
        final currentUser = _authRepository.currentUser;
        if (currentUser != null) {
          emit(AuthAuthenticated(user: currentUser));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        // Lakukan logging: '❌ No valid offline session found'
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      // Lakukan logging error: '❌ Error checking offline session: $e'
      emit(AuthUnauthenticated());
    }
  }

  // ========== AUTH USER CHANGED (FIREBASE AUTH STREAM) ==========
  Future<void> _onAuthUserChanged(
    _AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    final user = event.user;
    if (user != null) {
      try {
        // Lakukan logging: '🔄 Firebase auth state changed: User logged in'
        final needsSync = await SessionManager.instance.needsSync();
        final cachedUser = await SessionManager.instance.getUserData();
        if (cachedUser != null && !needsSync) {
          // Lakukan logging: '📱 Using fresh cached user data'
          emit(AuthAuthenticated(user: user));
        } else {
          // Lakukan logging: '🌐 Fetching fresh user data from server'
          final userModel = await _authRepository.getUserData(user.uid, forceOnline: true);
          await SessionManager.instance.saveSession(userModel);
          emit(AuthAuthenticated(user: user));
        }
        _authRepository.autoSyncIfNeeded();
      } catch (e) {
        // Lakukan logging error: '❌ Error handling auth user change: $e'
        final cachedUser = await SessionManager.instance.getUserData();
        if (cachedUser != null) {
          // Lakukan logging: '⚠️ Using cached data as fallback'
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthFailure(message: "Gagal memuat data profil. Silakan coba lagi."));
        }
      }
    } else {
      // Lakukan logging: '🔄 Firebase auth state changed: User logged out'
      await SessionManager.instance.clearSession();
      emit(AuthUnauthenticated());
    }
  }

  // ========== LOGIN ==========
  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.logIn(
        email: event.email,
        password: event.password,
      );
    } catch (e) {
      // Lakukan logging error: '❌ Login error: $e'
      emit(AuthFailure(message: _getErrorMessage(e)));
    }
  }

  // ========== SIGNUP ==========
  Future<void> _onAuthSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Anda perlu meneruskan semua parameter dari event ke repository
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
      // Lakukan logging error: '❌ Signup error: $e'
      emit(AuthFailure(message: _getErrorMessage(e)));
    }
  }

  // ========== LOGOUT ==========
  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.logOut();
    } catch (e) {
      // Lakukan logging error: '❌ Logout error: $e'
      emit(AuthFailure(message: 'Gagal untuk logout.'));
    }
  }

  // ========== REFRESH DATA ==========
  Future<void> _onAuthRefreshRequested(
    AuthRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthAuthenticated) return;
    try {
      // Lakukan logging: '🔄 Refreshing user data...'
      await _authRepository.refreshUserData();
      final currentUser = _authRepository.currentUser;
      if (currentUser != null) {
        emit(AuthAuthenticated(user: currentUser));
      }
    } catch (e) {
      // Lakukan logging error: '❌ Refresh error: $e'
    }
  }

  // ========== RESTORE OFFLINE SESSION ==========
  Future<void> _onAuthRestoreOfflineSession(
    AuthRestoreOfflineSession event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final hasValidSession = await _authRepository.hasValidOfflineSession();
      if (hasValidSession) {
        final currentUser = _authRepository.currentUser;
        if (currentUser != null) {
          emit(AuthAuthenticated(user: currentUser));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      // Lakukan logging error: '❌ Error restoring offline session: $e'
      emit(AuthUnauthenticated());
    }
  }

  // ========== ERROR MESSAGE HELPER ==========
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
    _autoSyncTimer?.cancel();
    return super.close();
  }
}