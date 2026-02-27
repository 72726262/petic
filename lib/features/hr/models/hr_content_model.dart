/// HR Content categories
enum HRCategory { policy, training, job }

class HRContentModel {
  final String id;
  final String title;
  final String? description;
  final String? fileUrl;
  final HRCategory category;
  final DateTime createdAt;

  const HRContentModel({
    required this.id,
    required this.title,
    this.description,
    this.fileUrl,
    required this.category,
    required this.createdAt,
  });

  factory HRContentModel.fromJson(Map<String, dynamic> json) {
    return HRContentModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      fileUrl: json['file_url'] as String?,
      category: _parseCategory(json['category'] as String? ?? 'policy'),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  static HRCategory _parseCategory(String value) {
    switch (value) {
      case 'training':
        return HRCategory.training;
      case 'job':
        return HRCategory.job;
      default:
        return HRCategory.policy;
    }
  }

  String get categoryLabel {
    switch (category) {
      case HRCategory.policy:
        return 'السياسات';
      case HRCategory.training:
        return 'التدريب';
      case HRCategory.job:
        return 'الوظائف';
    }
  }
}
