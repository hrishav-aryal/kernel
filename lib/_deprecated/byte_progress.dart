// ================================
// BYTE PROGRESS MODEL
// ================================

class ByteProgress {
  final String id;
  final String userId;
  final String byteId;
  final int currentBlockIndex;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime lastAccessedAt;
  final DateTime createdAt;

  const ByteProgress({
    required this.id,
    required this.userId,
    required this.byteId,
    required this.currentBlockIndex,
    required this.isCompleted,
    this.completedAt,
    required this.lastAccessedAt,
    required this.createdAt,
  });

  // Helper method for derived values
  double getProgressPercentage(int totalBlocks) {
    if (totalBlocks <= 0) return 0.0;
    return currentBlockIndex / totalBlocks;
  }

  factory ByteProgress.fromMap(Map<String, dynamic> map) {
    return ByteProgress(
      id: map['id'],
      userId: map['userId'],
      byteId: map['byteId'],
      currentBlockIndex: map['currentBlockIndex'],
      isCompleted: map['isCompleted'] ?? false,
      completedAt:
          map['completedAt'] != null
              ? DateTime.parse(map['completedAt'])
              : null,
      lastAccessedAt: DateTime.parse(map['lastAccessedAt']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'byteId': byteId,
      'currentBlockIndex': currentBlockIndex,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'lastAccessedAt': lastAccessedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
