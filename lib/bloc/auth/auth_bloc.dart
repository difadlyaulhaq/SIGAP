import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:rescuein/bloc/auth/auth_repository.dart';


part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {

    // Pantau perubahan status login dari repository
    _userSubscription = _authRepository.user.listen((user) {
      if (user != null) {
        add(AuthCheckRequested()); // Trigger event internal jika ada user
      }
    });

    on<AuthCheckRequested>((event, emit) async {
      try {
        final user = _authRepository.user.first;
        if (await user != null) {
          emit(AuthAuthenticated(user: (await user)!));
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        emit(AuthUnauthenticated());
      }
    });

    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.logIn(email: event.email, password: event.password);
        final user = _authRepository.user.first;
        emit(AuthAuthenticated(user: (await user)!));
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });

    on<AuthSignupRequested>((event, emit) async {
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
        final user = _authRepository.user.first;
        emit(AuthAuthenticated(user: (await user)!));
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.logOut();
        emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}