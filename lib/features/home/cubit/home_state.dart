import 'package:equatable/equatable.dart';
import 'package:employee_portal/features/news/models/news_model.dart';
import 'package:employee_portal/features/events/models/event_model.dart';
import 'package:employee_portal/features/auth/models/user_model.dart';

/// Home screen data bundle
class HomeData extends Equatable {
  final List<NewsModel> latestNews;
  final List<EventModel> upcomingEvents;
  final String? ceoMessage;
  final bool ceoMessageVisible;

  const HomeData({
    required this.latestNews,
    required this.upcomingEvents,
    this.ceoMessage,
    this.ceoMessageVisible = false,
  });

  @override
  List<Object?> get props =>
      [latestNews, upcomingEvents, ceoMessage, ceoMessageVisible];
}

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final HomeData data;

  const HomeLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class HomeError extends HomeState {
  final String message;
  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
