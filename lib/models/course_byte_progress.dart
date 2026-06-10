// ================================
// COURSE BYTE PROGRESS MODEL
// ================================

class CourseByteProgress {
  final String id;
  final String userId;
  final String courseByteId;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime lastAccessedAt;
  final DateTime createdAt;

  const CourseByteProgress({
    required this.id,
    required this.userId,
    required this.courseByteId,
    required this.isCompleted,
    this.completedAt,
    required this.lastAccessedAt,
    required this.createdAt,
  });

  factory CourseByteProgress.fromMap(Map<String, dynamic> map) {
    return CourseByteProgress(
      id: map['id'],
      userId: map['user_id'],
      courseByteId: map['course_byte_id'],
      isCompleted: map['is_completed'] ?? false,
      completedAt:
          map['completed_at'] != null
              ? DateTime.parse(map['completed_at'])
              : null,
      lastAccessedAt: DateTime.parse(map['last_accessed_at']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'user_id': userId,
      'course_byte_id': courseByteId,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'last_accessed_at': lastAccessedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };

    // Only include ID if it's not empty (for updates)
    if (id.isNotEmpty) {
      map['id'] = id;
    }

    return map;
  }
}
