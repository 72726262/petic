import 'package:equatable/equatable.dart';
import 'package:employee_portal/features/news/models/news_model.dart';

abstract class NewsState extends Equatable {
  const NewsState();
  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {
  const NewsInitial();
}

class NewsLoading extends NewsState {
  const NewsLoading();
}

class NewsLoaded extends NewsState {
  final List<NewsModel> news;
  const NewsLoaded({required this.news});

  @override
  List<Object?> get props => [news];
}

class NewsDetailLoading extends NewsState {
  const NewsDetailLoading();
}

class NewsDetailLoaded extends NewsState {
  final NewsModel news;
  const NewsDetailLoaded({required this.news});

  @override
  List<Object?> get props => [news];
}

class NewsError extends NewsState {
  final String message;
  const NewsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class NewsActionSuccess extends NewsState {
  final String message;
  const NewsActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
