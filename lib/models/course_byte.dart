// ================================
// COURSE BYTE MODEL
// ================================

class CourseByte {
  final String id;
  final String unitId;
  final String title;
  final String contentUrl;
  final int totalBlocks;
  final int byteOrder;
  final DateTime createdAt;

  const CourseByte({
    required this.id,
    required this.unitId,
    required this.title,
    required this.contentUrl,
    required this.totalBlocks,
    required this.byteOrder,
    required this.createdAt,
  });

  factory CourseByte.fromMap(Map<String, dynamic> map) {
    return CourseByte(
      id: map['id'],
      unitId: map['unit_id'],
      title: map['title'],
      contentUrl: map['content_json_url'],
      totalBlocks: map['total_blocks'] ?? 0,
      byteOrder: map['byte_order'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'unit_id': unitId,
      'title': title,
      'content_json_url': contentUrl,
      'total_blocks': totalBlocks,
      'byte_order': byteOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
