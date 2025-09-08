
import 'package:rescuein/models/medical_history_model.dart';

abstract class ProfileEvent {}

class FetchProfileData extends ProfileEvent {}
class UpdateMedicalHistory extends ProfileEvent {
  final MedicalHistoryModel updatedMedicalHistory;

  UpdateMedicalHistory({required this.updatedMedicalHistory});
}