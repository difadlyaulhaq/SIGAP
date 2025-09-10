import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rescuein/bloc/auth/auth_repository.dart'; // Pastikan path ini benar

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
        final userId = _firebaseAuth.currentUser?.uid;
        if (userId == null) {
          emit(ProfileFailure(message: "User not logged in."));
          return;
        }

        final user = await _authRepository.getUserData(userId);
        final medicalHistory = await _authRepository.getMedicalHistory(userId);

        emit(ProfileLoaded(user: user, medicalHistory: medicalHistory));
      } catch (e) {
        emit(ProfileFailure(message: "Gagal memuat data: ${e.toString()}"));
      }
    });

    // LOGIKA BARU UNTUK UPDATE
    on<UpdateMedicalHistory>((event, emit) async {
      emit(ProfileUpdateInProgress());
      try {
        final userId = _firebaseAuth.currentUser?.uid;
        if (userId == null) {
          emit(ProfileFailure(message: "User not logged in."));
          return;
        }

        await _authRepository.updateMedicalHistory(
          userId: userId,
          medicalHistory: event.updatedMedicalHistory,
        );

        emit(ProfileUpdateSuccess());
        // Panggil FetchProfileData lagi untuk refresh data di UI
        add(FetchProfileData());
      } catch (e) {
        emit(ProfileFailure(message: "Gagal memperbarui data: ${e.toString()}"));
      }
    });
  }
}