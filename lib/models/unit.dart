import 'package:flutter/material.dart';

// ================================
// UNIT MODEL
// ================================

class Unit {
  final String id;
  final String courseId;
  final String title;
  final int unitOrder;
  final DateTime createdAt;

  const Unit({
    required this.id,
    required this.courseId,
    required this.title,
    required this.unitOrder,
    required this.createdAt,
  });

  factory Unit.fromMap(Map<String, dynamic> map) {
    return Unit(
      id: map['id'],
      courseId: map['course_id'],
      title: map['title'],
      unitOrder: map['unit_order'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'unit_order': unitOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper method to get hardcoded color based on unit order
  Color get colorValue {
    return const Color(0xFF4B8BBE);
    final colors = [
      const Color(0xFF3776a9), // Indigo
      const Color(0xFFfcd573), // Emerald
      const Color(0xFFDC2626), // Red
      const Color(0xFFD97706), // Amber
      const Color(0xFF7C3AED), // Violet
      const Color.fromARGB(255, 49, 63, 67), // Cyan
    ];
    return colors[unitOrder % colors.length];
  }

  // Helper method to get hardcoded icon based on unit order
  IconData get iconData {
    final icons = [
      Icons.foundation,
      Icons.storage,
      Icons.hub,
      Icons.security,
      Icons.speed,
      Icons.cloud,
    ];
    return icons[unitOrder % icons.length];
  }
}
