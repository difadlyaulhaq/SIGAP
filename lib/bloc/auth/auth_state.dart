part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

// State saat proses autentikasi sedang berjalan
final class AuthLoading extends AuthState {}

// State saat user berhasil login/signup
final class AuthAuthenticated extends AuthState {
  final User user; // Membawa data user dari Firebase Auth
  AuthAuthenticated({required this.user});
}

// State saat user tidak login
final class AuthUnauthenticated extends AuthState {}

// State jika terjadi kegagalan
final class AuthFailure extends AuthState {
  final String message;
  AuthFailure({required this.message});
}