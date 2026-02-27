import 'package:equatable/equatable.dart';
import 'package:employee_portal/features/mood/models/mood_model.dart';

abstract class MoodState extends Equatable {
  const MoodState();
  @override
  List<Object?> get props => [];
}

class MoodInitial extends MoodState {
  const MoodInitial();
}

class MoodLoading extends MoodState {
  const MoodLoading();
}

class MoodLoaded extends MoodState {
  final List<MoodModel> history;
  final MoodModel? todayMood;

  const MoodLoaded({required this.history, this.todayMood});

  @override
  List<Object?> get props => [history, todayMood];
}

class MoodSubmitting extends MoodState {
  const MoodSubmitting();
}

class MoodSubmitSuccess extends MoodState {
  const MoodSubmitSuccess();
}

class MoodError extends MoodState {
  final String message;
  const MoodError({required this.message});
  @override
  List<Object?> get props => [message];
}
