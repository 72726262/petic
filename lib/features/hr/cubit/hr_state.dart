import 'package:equatable/equatable.dart';
import 'package:employee_portal/features/hr/models/hr_content_model.dart';

abstract class HRState extends Equatable {
  const HRState();
  @override
  List<Object?> get props => [];
}

class HRInitial extends HRState {
  const HRInitial();
}

class HRLoading extends HRState {
  const HRLoading();
}

class HRLoaded extends HRState {
  final List<HRContentModel> policies;
  final List<HRContentModel> trainings;
  final List<HRContentModel> jobs;

  const HRLoaded({
    required this.policies,
    required this.trainings,
    required this.jobs,
  });

  @override
  List<Object?> get props => [policies, trainings, jobs];
}

class HRError extends HRState {
  final String message;
  const HRError({required this.message});
  @override
  List<Object?> get props => [message];
}
