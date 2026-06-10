// ================================
// BYTE WITH PROGRESS MODEL
// ================================

import 'byte.dart';
import 'byte_progress.dart';

/// Composite model that contains byte data along with user progress
/// Used for efficient "Jump Back In" sections
class ByteWithProgress {
  final Byte byte;
  final ByteProgress progress;

  const ByteWithProgress({required this.byte, required this.progress});

  factory ByteWithProgress.fromMap(Map<String, dynamic> map) {
    return ByteWithProgress(
      byte: Byte.fromMap({
        'id': map['id'],
        'slug': map['slug'],
        'title': map['title'],
        'description': map['description'],
        'content_json_url': map['content_json_url'],
        'is_premium': map['is_premium'],
        'tags': map['tags'],
        'published_at': map['published_at'],
        'updated_at': map['updated_at'],
        'thumbnail_url': map['thumbnail_url'],
        'reading_time_minutes': map['reading_time_minutes'],
        'total_blocks': map['total_blocks'],
      }),
      progress: ByteProgress.fromMap({
        'id': map['progress_id'],
        'userId': map['progress_user_id'],
        'byteId': map['progress_byte_id'],
        'currentBlockIndex': map['current_block_index'],
        'isCompleted': map['is_completed'],
        'completedAt': map['completed_at'],
        'lastAccessedAt': map['last_accessed_at'],
        'createdAt': map['progress_created_at'],
      }),
    );
  }

  Map<String, dynamic> toMap() {
    return {'byte': byte.toMap(), 'progress': progress.toMap()};
  }
}
