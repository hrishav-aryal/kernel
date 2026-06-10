import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';

/// Utility functions for reader widgets

/// Create inline code themes with transparent backgrounds
Map<String, TextStyle> _createInlineCodeTheme(
  Map<String, TextStyle> baseTheme,
  bool isDarkMode,
) {
  final theme = Map<String, TextStyle>.from(baseTheme);
  // Override root background to be transparent for inline code
  theme['root'] = TextStyle(
    backgroundColor: Colors.transparent,
    color: theme['root']?.color,
  );
  return theme;
}

/// Helper method to parse text with **bold** and `code` syntax
List<InlineSpan> parseRichText(
  String text,
  TextStyle? baseStyle,
  BuildContext? context,
) {
  final List<InlineSpan> spans = [];
  // Combined regex to match both **bold** and `code`
  final RegExp combinedRegex = RegExp(r'\*\*(.*?)\*\*|`([^`]+)`');
  int currentIndex = 0;

  for (final match in combinedRegex.allMatches(text)) {
    // Add text before the match
    if (match.start > currentIndex) {
      spans.add(
        TextSpan(
          text: text.substring(currentIndex, match.start),
          style: baseStyle,
        ),
      );
    }

    // Check which pattern matched
    if (match.group(1) != null) {
      // Bold text matched (**text**)
      spans.add(
        TextSpan(
          text: match.group(1),
          style: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w800,
            fontSize: baseStyle?.fontSize,
            color: baseStyle?.color,
          ),
        ),
      );
    } else if (match.group(2) != null) {
      // Code text matched (`code`)
      final isDarkMode =
          context != null
              ? Theme.of(context).brightness == Brightness.dark
              : false;

      final codeText = match.group(2)!;

      // Create inline theme with transparent background
      final inlineTheme = _createInlineCodeTheme(
        isDarkMode ? atomOneDarkTheme : atomOneLightTheme,
        isDarkMode,
      );

      // Use WidgetSpan to add padding around code text with syntax highlighting
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Colors.grey[800]?.withOpacity(0.6)
                      : Colors.grey[300]?.withOpacity(0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: HighlightView(
              codeText,
              language: 'python',
              theme: inlineTheme,
              padding: EdgeInsets.zero,
              textStyle: GoogleFonts.sourceCodePro(
                fontSize:
                    baseStyle?.fontSize != null
                        ? baseStyle!.fontSize! * 0.9
                        : 13,
                letterSpacing: -0.3,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
          ),
        ),
      );
    }

    currentIndex = match.end;
  }

  // Add remaining text
  if (currentIndex < text.length) {
    spans.add(TextSpan(text: text.substring(currentIndex), style: baseStyle));
  }

  return spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans;
}

/// Builds a rich text widget that supports **bold** and `code` syntax
Widget buildRichText(String text, TextStyle? style, [BuildContext? context]) {
  final spans = parseRichText(text, style, context);

  if (spans.length == 1 && !text.contains('**') && !text.contains('`')) {
    return Text(text, style: style);
  }

  return RichText(text: TextSpan(children: spans));
}
