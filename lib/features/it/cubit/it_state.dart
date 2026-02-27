import 'package:equatable/equatable.dart';
import 'package:employee_portal/features/it/models/it_content_model.dart';

abstract class ITState extends Equatable {
  const ITState();
  @override
  List<Object?> get props => [];
}

class ITInitial extends ITState {
  const ITInitial();
}

class ITLoading extends ITState {
  const ITLoading();
}

class ITLoaded extends ITState {
  final List<ITContentModel> alerts;
  final List<ITContentModel> tips;
  final List<ITContentModel> policies;
  final List<ITContentModel> guides;

  const ITLoaded({
    required this.alerts,
    required this.tips,
    required this.policies,
    required this.guides,
  });

  @override
  List<Object?> get props => [alerts, tips, policies, guides];
}

class ITError extends ITState {
  final String message;
  const ITError({required this.message});
  @override
  List<Object?> get props => [message];
}
