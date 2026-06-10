import '../models/block.dart';

// ================================
// BYTE MODEL (Weekly Bytes Only)
// ================================

class Byte {
  final String id;
  final String slug;
  final String title;
  final String description;
  final String contentUrl;
  final bool isPremium;
  final List<String> tags;
  final DateTime publishedAt;
  final DateTime? updatedAt;
  final String? thumbnailUrl;
  final int readingTimeMinutes;
  final int totalBlocks;
  final List<Block>? blocks;

  const Byte({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.contentUrl,
    required this.isPremium,
    required this.tags,
    required this.publishedAt,
    this.updatedAt,
    this.thumbnailUrl,
    required this.readingTimeMinutes,
    required this.totalBlocks,
    this.blocks,
  });

  factory Byte.fromMap(Map<String, dynamic> map) {
    return Byte(
      id: map['id'],
      slug: map['slug'],
      title: map['title'],
      description: map['description'],
      contentUrl: map['content_json_url'],
      isPremium: map['is_premium'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      publishedAt: DateTime.parse(map['published_at']),
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      thumbnailUrl: map['thumbnail_url'],
      readingTimeMinutes: map['reading_time_minutes'] ?? 5, // Default 5 minutes
      totalBlocks: map['total_blocks'] ?? 0,
      blocks:
          map['blocks'] != null
              ? (map['blocks'] as List)
                  .map((block) => Block.fromMap(block))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'slug': slug,
      'title': title,
      'description': description,
      'content_json_url': contentUrl,
      'is_premium': isPremium,
      'tags': tags,
      'published_at': publishedAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'thumbnail_url': thumbnailUrl,
      'reading_time_minutes': readingTimeMinutes,
      'total_blocks': totalBlocks,
      'blocks': blocks?.map((block) => block.toMap()).toList(),
    };
  }
}
