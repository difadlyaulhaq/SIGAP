
import 'package:rescuein/models/medical_history_model.dart';
import 'package:rescuein/models/user_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel user;
  final MedicalHistoryModel medicalHistory;

  ProfileLoaded({required this.user, required this.medicalHistory});
}

class ProfileFailure extends ProfileState {
  final String message;

  ProfileFailure({required this.message});
}
class ProfileUpdateInProgress extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {}