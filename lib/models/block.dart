import 'content_element.dart';

// ================================
// CONTENT BLOCK MODEL
// ================================

class Block {
  final List<ContentElement> elements;

  const Block({required this.elements});

  factory Block.fromMap(Map<String, dynamic> map) {
    return Block(
      elements:
          (map['elements'] as List)
              .map((elementMap) => ContentElement.fromMap(elementMap))
              .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'elements': elements.map((element) => element.toMap()).toList()};
  }
}
