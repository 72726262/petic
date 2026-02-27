import 'package:equatable/equatable.dart';

class EventModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final String? location;
  final List<String> pollOptions;
  final DateTime createdAt;

  const EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.location,
    this.pollOptions = const [],
    required this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        date: json['date'] != null
            ? DateTime.parse(json['date'] as String)
            : DateTime.now(),
        location: json['location'] as String?,
        pollOptions: json['poll_options'] != null
            ? List<String>.from(json['poll_options'] as List)
            : [],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'location': location,
        'poll_options': pollOptions,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props =>
      [id, title, description, date, location, pollOptions, createdAt];
}

class VoteModel extends Equatable {
  final String id;
  final String eventId;
  final String userId;
  final String option;
  final DateTime createdAt;

  const VoteModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.option,
    required this.createdAt,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) => VoteModel(
        id: json['id'] as String,
        eventId: json['event_id'] as String,
        userId: json['user_id'] as String,
        option: json['option'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'user_id': userId,
        'option': option,
      };

  @override
  List<Object?> get props => [id, eventId, userId, option, createdAt];
}

class CommentModel extends Equatable {
  final String id;
  final String eventId;
  final String userId;
  final String content;
  final String? userFullName;
  final String? userAvatar;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.content,
    this.userFullName,
    this.userAvatar,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        id: json['id'] as String,
        eventId: json['event_id'] as String,
        userId: json['user_id'] as String,
        content: json['content'] as String,
        userFullName: json['users']?['full_name'] as String?,
        userAvatar: json['users']?['avatar_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  @override
  List<Object?> get props =>
      [id, eventId, userId, content, userFullName, createdAt];
}
