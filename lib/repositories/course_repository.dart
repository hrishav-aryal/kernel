import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kernel/models/models.dart';

class CourseRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get complete course data with units and course bytes in a single query
  Future<CourseData?> getCourseContent() async {
    try {
      // Single optimized query to get everything
      final response = await _supabase
          .from('courses')
          .select('''
            *,
            units!inner(
              *,
              course_bytes(*)
            )
          ''')
          .eq('is_active', true)
          .order('created_at', ascending: true)
          .limit(1);

      if (response.isEmpty) return null;

      final courseMap = response.first;
      final course = Course.fromMap(courseMap);

      // Parse units and course bytes
      final List<Unit> units = [];
      final Map<String, List<CourseByte>> unitBytes = {};

      final unitsData = courseMap['units'] as List<dynamic>? ?? [];
      for (final unitMap in unitsData) {
        final unit = Unit.fromMap(unitMap);
        units.add(unit);

        // Parse course bytes for this unit
        final bytesData = unitMap['course_bytes'] as List<dynamic>? ?? [];
        final courseBytes =
            bytesData.map((byteMap) => CourseByte.fromMap(byteMap)).toList();

        // Sort by byte_order
        courseBytes.sort((a, b) => a.byteOrder.compareTo(b.byteOrder));
        unitBytes[unit.id] = courseBytes;
      }

      // Sort units by unit_order
      units.sort((a, b) => a.unitOrder.compareTo(b.unitOrder));

      return CourseData(course: course, units: units, unitBytes: unitBytes);
    } catch (e) {
      throw Exception('Failed to fetch course content: $e');
    }
  }
}

// ================================
// HELPER CLASS
// ================================

class CourseData {
  final Course course;
  final List<Unit> units;
  final Map<String, List<CourseByte>> unitBytes; // unitId -> course bytes

  CourseData({
    required this.course,
    required this.units,
    required this.unitBytes,
  });

  /// Get total number of course bytes in the course
  int get totalByteCount {
    return unitBytes.values.fold(0, (total, bytes) => total + bytes.length);
  }

  /// Get course bytes for a specific unit
  List<CourseByte> getBytesForUnit(String unitId) {
    return unitBytes[unitId] ?? [];
  }

  /// Get flat ordered list of all bytes across all units
  /// Maintains unit order and byte order within units
  List<CourseByte> getAllBytesOrdered() {
    final List<CourseByte> allBytes = [];
    for (final unit in units) {
      final bytes = getBytesForUnit(unit.id);
      allBytes.addAll(bytes);
    }
    return allBytes;
  }

  /// Get the previous byte for a given byte
  /// Returns null if this is the first byte
  CourseByte? getPreviousByte(CourseByte currentByte) {
    final allBytes = getAllBytesOrdered();
    final currentIndex = allBytes.indexWhere((b) => b.id == currentByte.id);

    if (currentIndex <= 0) {
      return null; // First byte or not found
    }

    return allBytes[currentIndex - 1];
  }
}
