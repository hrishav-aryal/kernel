/// Helper class to map course titles/IDs to their corresponding image assets
class CourseImageHelper {
  /// Get image path for a course based on its title
  /// Falls back to a default image if not found
  static String getImageForCourse(String courseTitle) {
    final titleLower = courseTitle.toLowerCase();

    if (titleLower.contains('python')) {
      return 'assets/images/python.png';
    } else if (titleLower.contains('javascript') || titleLower.contains('js')) {
      return 'assets/images/js.png';
    } else if (titleLower.contains('java')) {
      return 'assets/images/java.png';
    } else if (titleLower.contains('backend')) {
      return 'assets/images/backend.png';
    } else if (titleLower.contains('frontend')) {
      return 'assets/images/frontend.png';
    } else if (titleLower.contains('system') || titleLower.contains('design')) {
      return 'assets/images/sysdesign.png';
    }

    // Default fallback
    return 'assets/images/code.png';
  }
}
