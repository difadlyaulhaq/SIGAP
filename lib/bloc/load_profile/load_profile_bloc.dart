import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rescuein/bloc/auth/auth_repository.dart';

import 'load_profile_event.dart';
import 'load_profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository _authRepository;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  ProfileBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(ProfileInitial()) {
    on<FetchProfileData>((event, emit) async {
      emit(ProfileLoading());
      try {
        // PERBAIKAN: Validasi authentication lebih ketat
        final currentUser = _firebaseAuth.currentUser;
        if (currentUser == null) {
          emit(ProfileFailure(message: "Sesi telah berakhir. Silakan login kembali."));
          return;
        }

        // Refresh token to ensure it's still valid
        try {
          await currentUser.reload();
          final refreshedUser = _firebaseAuth.currentUser;
          if (refreshedUser == null) {
            emit(ProfileFailure(message: "Sesi telah berakhir. Silakan login kembali."));
            return;
          }
        } catch (tokenError) {
          print('Token validation error: $tokenError');
          emit(ProfileFailure(message: "Sesi telah berakhir. Silakan login kembali."));
          return;
        }

        final userId = currentUser.uid;
        
        // Fetch data with timeout
        final user = await _authRepository.getUserData(userId)
            .timeout(const Duration(seconds: 10));
        final medicalHistory = await _authRepository.getMedicalHistory(userId)
            .timeout(const Duration(seconds: 10));

        emit(ProfileLoaded(user: user, medicalHistory: medicalHistory));
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'user-token-expired':
          case 'invalid-user-token':
          case 'user-disabled':
            errorMessage = "Sesi telah berakhir. Silakan login kembali.";
            break;
          case 'network-request-failed':
            errorMessage = "Gagal terhubung ke internet. Periksa koneksi Anda.";
            break;
          default:
            errorMessage = "Terjadi kesalahan autentikasi: ${e.message}";
        }
        emit(ProfileFailure(message: errorMessage));
      } catch (e) {
        print('ProfileBloc fetch error: $e');
        String errorMessage;
        
        if (e.toString().contains('timeout') || e.toString().contains('TimeoutException')) {
          errorMessage = "Koneksi timeout. Silakan coba lagi.";
        } else if (e.toString().contains('User data not found') || 
                   e.toString().contains('Medical history not found')) {
          errorMessage = "Data profil tidak ditemukan. Silakan hubungi support.";
        } else if (e.toString().contains('permission-denied')) {
          errorMessage = "Akses ditolak. Silakan login kembali.";
        } else {
          errorMessage = "Gagal memuat data profil. Silakan coba lagi.";
        }
        
        emit(ProfileFailure(message: errorMessage));
      }
    });

    on<UpdateMedicalHistory>((event, emit) async {
      emit(ProfileUpdateInProgress());
      try {
        final currentUser = _firebaseAuth.currentUser;
        if (currentUser == null) {
          emit(ProfileFailure(message: "Sesi telah berakhir. Silakan login kembali."));
          return;
        }

        // Refresh token before update
        await currentUser.reload();
        final refreshedUser = _firebaseAuth.currentUser;
        if (refreshedUser == null) {
          emit(ProfileFailure(message: "Sesi telah berakhir. Silakan login kembali."));
          return;
        }

        final userId = refreshedUser.uid;

        await _authRepository.updateMedicalHistory(
          userId: userId,
          medicalHistory: event.updatedMedicalHistory,
        ).timeout(const Duration(seconds: 10));

        emit(ProfileUpdateSuccess());
        // Refresh data after successful update
        add(FetchProfileData());
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'user-token-expired':
          case 'invalid-user-token':
          case 'user-disabled':
            errorMessage = "Sesi telah berakhir. Silakan login kembali.";
            break;
          case 'network-request-failed':
            errorMessage = "Gagal terhubung ke internet. Periksa koneksi Anda.";
            break;
          default:
            errorMessage = "Terjadi kesalahan autentikasi: ${e.message}";
        }
        emit(ProfileFailure(message: errorMessage));
      } catch (e) {
        print('ProfileBloc update error: $e');
        String errorMessage;
        
        if (e.toString().contains('timeout') || e.toString().contains('TimeoutException')) {
          errorMessage = "Koneksi timeout. Silakan coba lagi.";
        } else if (e.toString().contains('permission-denied')) {
          errorMessage = "Akses ditolak. Silakan login kembali.";
        } else {
          errorMessage = "Gagal memperbarui data: ${e.toString()}";
        }
        
        emit(ProfileFailure(message: errorMessage));
      }
    });
  }
}