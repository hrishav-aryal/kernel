// ================================
// SAVED BYTE MODEL
// ================================

class SavedByte {
  final String id;
  final String userId;
  final String byteId;
  final DateTime savedAt;

  const SavedByte({
    required this.id,
    required this.userId,
    required this.byteId,
    required this.savedAt,
  });

  factory SavedByte.fromMap(Map<String, dynamic> map) {
    return SavedByte(
      id: map['id'],
      userId:
          map['userId'] ??
          map['user_id'], // Handle both camelCase and snake_case
      byteId: map['byteId'] ?? map['byte_id'],
      savedAt: DateTime.parse(map['savedAt'] ?? map['saved_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'byteId': byteId,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  /// Convert to database format (snake_case)
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'byte_id': byteId,
      'saved_at': savedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedByte &&
        other.id == id &&
        other.userId == userId &&
        other.byteId == byteId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ byteId.hashCode;
  }

  @override
  String toString() {
    return 'SavedByte(id: $id, userId: $userId, byteId: $byteId, savedAt: $savedAt)';
  }
}
