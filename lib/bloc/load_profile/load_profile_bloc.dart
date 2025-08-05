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
        final userId = _firebaseAuth.currentUser?.uid;
        if (userId == null) {
          emit(ProfileFailure(message: "User not logged in."));
          return;
        }

        final user = await _authRepository.getUserData(userId);
        final medicalHistory = await _authRepository.getMedicalHistory(userId);

        emit(ProfileLoaded(user: user, medicalHistory: medicalHistory));
      } catch (e) {
        emit(ProfileFailure(message: e.toString()));
      }
    });
  }
}