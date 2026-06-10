import 'enums.dart';

// ================================
// CONTENT ELEMENT MODEL
// ================================

/// Represents a single content element within a block
/// Each element has a specific type and associated properties
class ContentElement {
  final ContentElementType type;
  final String content;
  final Map<String, dynamic>? properties;

  const ContentElement({
    required this.type,
    required this.content,
    this.properties,
  });

  // Convenience getters for common properties
  String? get caption => properties?['caption'];
  String? get imageUrl => properties?['imageUrl'];
  List<String>? get items => properties?['items']?.cast<String>();
  int? get headingLevel => properties?['level']; // 1-6 for h1-h6
  String? get language =>
      properties?['language']; // for code syntax highlighting
  bool? get isNumberedList => properties?['numbered']; // for list type
  double? get spacerHeight => properties?['height']; // for spacer
  double? get aspectRatio =>
      properties?['aspectRatio']; // for image aspect ratio

  // MCQ specific getters
  String? get question => properties?['question']; // MCQ question text
  String? get questionImageUrl =>
      properties?['questionImageUrl']; // Optional question image
  List<String>? get options =>
      properties?['options']?.cast<String>(); // MCQ options
  int? get correctAnswerIndex =>
      properties?['correctAnswerIndex']; // Index of correct answer
  String? get explanation =>
      properties?['explanation']; // Explanation for correct answer
  String? get correctFeedback =>
      properties?['correctFeedback']; // Feedback for correct answer
  String? get incorrectFeedback =>
      properties?['incorrectFeedback']; // Feedback for incorrect answer

  // Code Fill specific getters
  List<Map<String, dynamic>>? get lines =>
      properties?['lines']
          ?.cast<Map<String, dynamic>>(); // Code lines with blanks
  Map<String, String>? get solutions =>
      properties?['solutions']
          ?.cast<String, String>(); // Blank ID to correct answer mapping
  String? get hint => properties?['hint']; // Hint for code completion
  String? get output => properties?['output']; // Expected output for code

  factory ContentElement.fromMap(Map<String, dynamic> map) {
    return ContentElement(
      type: ContentElementType.values.byName(map['type'] ?? 'text'),
      content: map['content'] ?? '',
      properties:
          map['properties'] != null
              ? Map<String, dynamic>.from(map['properties'])
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'content': content,
      if (properties != null) 'properties': properties,
    };
  }
}
