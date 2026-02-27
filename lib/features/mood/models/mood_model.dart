/// Mood levels
enum MoodLevel { excellent, good, neutral, bad, terrible }

class MoodModel {
  final String id;
  final String userId;
  final MoodLevel mood;
  final String? note;
  final DateTime createdAt;

  const MoodModel({
    required this.id,
    required this.userId,
    required this.mood,
    this.note,
    required this.createdAt,
  });

  factory MoodModel.fromJson(Map<String, dynamic> json) {
    return MoodModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mood: _parseMood(json['mood'] as String? ?? 'neutral'),
      note: json['note'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  static MoodLevel _parseMood(String value) {
    switch (value) {
      case 'excellent':
        return MoodLevel.excellent;
      case 'good':
        return MoodLevel.good;
      case 'bad':
        return MoodLevel.bad;
      case 'terrible':
        return MoodLevel.terrible;
      default:
        return MoodLevel.neutral;
    }
  }

  String get moodKey {
    switch (mood) {
      case MoodLevel.excellent:
        return 'excellent';
      case MoodLevel.good:
        return 'good';
      case MoodLevel.neutral:
        return 'neutral';
      case MoodLevel.bad:
        return 'bad';
      case MoodLevel.terrible:
        return 'terrible';
    }
  }

  String get emoji {
    switch (mood) {
      case MoodLevel.excellent:
        return '😄';
      case MoodLevel.good:
        return '😊';
      case MoodLevel.neutral:
        return '😐';
      case MoodLevel.bad:
        return '😔';
      case MoodLevel.terrible:
        return '😢';
    }
  }

  String get label {
    switch (mood) {
      case MoodLevel.excellent:
        return 'ممتاز';
      case MoodLevel.good:
        return 'جيد';
      case MoodLevel.neutral:
        return 'محايد';
      case MoodLevel.bad:
        return 'سيئ';
      case MoodLevel.terrible:
        return 'سيئ جدًا';
    }
  }
}
