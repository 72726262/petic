import 'package:equatable/equatable.dart';
import 'package:employee_portal/features/events/models/event_model.dart';

abstract class EventState extends Equatable {
  const EventState();
  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {
  const EventInitial();
}

class EventLoading extends EventState {
  const EventLoading();
}

class EventsLoaded extends EventState {
  final List<EventModel> events;
  const EventsLoaded({required this.events});
  @override
  List<Object?> get props => [events];
}

class EventDetailLoading extends EventState {
  const EventDetailLoading();
}

class EventDetailLoaded extends EventState {
  final EventModel event;
  final List<VoteModel> votes;
  final List<CommentModel> comments;

  const EventDetailLoaded({
    required this.event,
    required this.votes,
    required this.comments,
  });

  @override
  List<Object?> get props => [event, votes, comments];
}

class EventError extends EventState {
  final String message;
  const EventError({required this.message});
  @override
  List<Object?> get props => [message];
}

class EventActionSuccess extends EventState {
  final String message;
  const EventActionSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}
