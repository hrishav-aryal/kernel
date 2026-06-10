// ================================
// COURSE MODEL
// ================================

class Course {
  final String id;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final bool isActive;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata; // JSON field for extensible metadata

  const Course({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    required this.isActive,
    required this.createdAt,
    this.metadata,
  });

  // Helper getters for common metadata fields
  String? get level => metadata?['level'];
  int? get numberOfLessons => metadata?['numberOfLessons'];

  /// Check if this course uses local content instead of Supabase Storage
  bool get useLocalContent => metadata?['use_local_content'] == true;

  /// Get the base path for local content (e.g., "assets/courses/python")
  String? get localContentPath => metadata?['local_content_path'];

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      thumbnailUrl: map['thumbnail_url'],
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
      metadata:
          map['metadata'] != null
              ? Map<String, dynamic>.from(map['metadata'])
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}
