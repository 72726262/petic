import 'package:equatable/equatable.dart';

class NewsModel extends Equatable {
  final String id;
  final String title;
  final String? subtitle;
  final String? content;
  final String? imageUrl;
  final String? authorId;
  final DateTime createdAt;

  const NewsModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.content,
    this.imageUrl,
    this.authorId,
    required this.createdAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) => NewsModel(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String?,
        content: json['content'] as String?,
        imageUrl: json['image_url'] as String?,
        authorId: json['author_id'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'content': content,
        'image_url': imageUrl,
        'author_id': authorId,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props =>
      [id, title, subtitle, content, imageUrl, authorId, createdAt];
}
