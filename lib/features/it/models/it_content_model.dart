/// IT Content categories
enum ITCategory { alert, tip, policy, guide }

class ITContentModel {
  final String id;
  final String title;
  final String? description;
  final String? fileUrl;
  final ITCategory category;
  final bool isUrgent;
  final DateTime createdAt;

  const ITContentModel({
    required this.id,
    required this.title,
    this.description,
    this.fileUrl,
    required this.category,
    this.isUrgent = false,
    required this.createdAt,
  });

  factory ITContentModel.fromJson(Map<String, dynamic> json) {
    return ITContentModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      fileUrl: json['file_url'] as String?,
      category: _parseCategory(json['category'] as String? ?? 'tip'),
      isUrgent: json['is_urgent'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  static ITCategory _parseCategory(String value) {
    switch (value) {
      case 'alert':
        return ITCategory.alert;
      case 'policy':
        return ITCategory.policy;
      case 'guide':
        return ITCategory.guide;
      default:
        return ITCategory.tip;
    }
  }

  String get categoryLabel {
    switch (category) {
      case ITCategory.alert:
        return 'تنبيهات';
      case ITCategory.tip:
        return 'نصائح';
      case ITCategory.policy:
        return 'السياسات';
      case ITCategory.guide:
        return 'أدلة';
    }
  }
}
