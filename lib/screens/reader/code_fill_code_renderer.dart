import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:google_fonts/google_fonts.dart';
import 'content_interactor.dart';

/// Renders the code section with blanks for CodeFillInteractorWidget
class CodeFillCodeRenderer extends StatelessWidget {
  final List<Map<String, dynamic>> lines;
  final String language;
  final CodeFillInteractor interactor;
  final Animation<double> shakeAnimation;
  final Animation<double> checkmarkAnimation;
  final bool showingWrongAnswer;
  final Function(String) onBlankTapped;

  const CodeFillCodeRenderer({
    super.key,
    required this.lines,
    required this.language,
    required this.interactor,
    required this.shakeAnimation,
    required this.checkmarkAnimation,
    required this.showingWrongAnswer,
    required this.onBlankTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isAnsweredCorrectly =
        interactor.hasAnswered && interactor.isCompleted;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Theme.of(context).colorScheme.surface.withOpacity(0.5)
                : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Code header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.code,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  "script.py",
                  style: GoogleFonts.nunito(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                // Success checkmark
                if (isAnsweredCorrectly)
                  AnimatedBuilder(
                    animation: checkmarkAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: checkmarkAnimation.value,
                        child: Opacity(
                          opacity: checkmarkAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          // Code content - wrap entire code block in single horizontal scroll
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? atomOneDarkTheme['root']?.backgroundColor
                      : atomOneLightTheme['root']?.backgroundColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      lines
                          .map(
                            (line) => _buildCodeLine(
                              context,
                              line,
                              language,
                              isDarkMode,
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeLine(
    BuildContext context,
    Map<String, dynamic> line,
    String language,
    bool isDarkMode,
  ) {
    final code = line['code'] as String? ?? '';
    final indent = line['indent'] as int? ?? 0;
    final blankId = line['blank'] as String?;

    // Create a custom theme with transparent backgrounds for non-interactive lines
    final baseTheme = isDarkMode ? atomOneDarkTheme : atomOneLightTheme;
    final customTheme = Map<String, TextStyle>.from(baseTheme);
    customTheme.forEach((key, style) {
      customTheme[key] = style.copyWith(backgroundColor: Colors.transparent);
    });

    return Padding(
      padding: EdgeInsets.only(left: indent.toDouble(), bottom: 4),
      child:
          blankId != null
              ? _buildInteractiveCodeLine(
                context,
                code, // Pass original code with {blankId} pattern
                blankId, // This is the comma-separated string like "1,2"
                language,
                isDarkMode,
              )
              : HighlightView(
                code, // Use original code without indentation for highlighting
                language: language,
                theme: customTheme,
                padding: EdgeInsets.zero,
                textStyle: GoogleFonts.sourceCodePro(
                  fontSize: 13,
                  height: 1.4,
                  letterSpacing: -0.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
    );
  }

  Widget _buildInteractiveCodeLine(
    BuildContext context,
    String originalCode,
    String blankIdsString, // This can be "1" or "1,2" etc.
    String language,
    bool isDarkMode,
  ) {
    // Create a custom theme with transparent backgrounds
    final baseTheme = isDarkMode ? atomOneDarkTheme : atomOneLightTheme;
    final customTheme = Map<String, TextStyle>.from(baseTheme);
    customTheme.forEach((key, style) {
      customTheme[key] = style.copyWith(backgroundColor: Colors.transparent);
    });

    // Parse the blank IDs from the comma-separated string
    final blankIds = blankIdsString.split(',').map((id) => id.trim()).toList();

    // Build a list of widgets representing the code line with blanks
    List<Widget> lineWidgets = [];
    String remainingCode = originalCode;

    // Process each blank in order
    for (int i = 0; i < blankIds.length; i++) {
      final blankId = blankIds[i];
      final blankPattern = '{$blankId}';

      // Find the position of this blank in the remaining code
      final blankIndex = remainingCode.indexOf(blankPattern);
      if (blankIndex == -1) continue; // Skip if blank pattern not found

      // Add code before this blank
      final codeBeforeBlank = remainingCode.substring(0, blankIndex);
      if (codeBeforeBlank.isNotEmpty) {
        lineWidgets.add(
          HighlightView(
            codeBeforeBlank,
            language: language,
            theme: customTheme,
            padding: EdgeInsets.zero,
            textStyle: GoogleFonts.sourceCodePro(
              fontSize: 13,
              height: 1.4,
              letterSpacing: -0.6,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }

      // Add the blank widget
      lineWidgets.add(
        _buildBlankWidget(context, blankId, language, customTheme),
      );

      // Update remaining code (remove processed part including the blank pattern)
      remainingCode = remainingCode.substring(blankIndex + blankPattern.length);
    }

    // Add any remaining code after the last blank
    if (remainingCode.isNotEmpty) {
      lineWidgets.add(
        HighlightView(
          remainingCode,
          language: language,
          theme: customTheme,
          padding: EdgeInsets.zero,
          textStyle: GoogleFonts.sourceCodePro(
            fontSize: 14,
            height: 1.4,
            letterSpacing: -0.6,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: lineWidgets,
    );
  }

  Widget _buildBlankWidget(
    BuildContext context,
    String blankId,
    String language,
    Map<String, TextStyle> customTheme,
  ) {
    final filledValue = interactor.filledBlanks[blankId];
    final blankResults = interactor.blankResults;
    final isCorrect = blankResults[blankId];
    final hasAnswered = interactor.hasAnswered;
    final isEmpty = filledValue?.isEmpty ?? true;

    // Determine border and fill colors based on state
    Color borderColor;
    Color fillColor;

    if (showingWrongAnswer && isCorrect == false) {
      // Wrong answer (during shake animation)
      borderColor = Colors.red.withOpacity(0.6);
      fillColor = Colors.red.withOpacity(0.1);
    } else if (hasAnswered && isCorrect == true) {
      // Correct answer
      borderColor = Colors.green.withOpacity(0.6);
      fillColor = Colors.green.withOpacity(0.1);
    } else {
      // Empty blank and Filled but not yet checked
      borderColor = Theme.of(context).colorScheme.primary;
      fillColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
    }

    return AnimatedBuilder(
      animation: shakeAnimation,
      builder: (context, child) {
        final shouldShake =
            showingWrongAnswer && filledValue != null && isCorrect == false;
        final offset =
            shouldShake ? sin(shakeAnimation.value * 3.14159 * 6) * 2 : 0.0;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: GestureDetector(
            onTap: () => onBlankTapped(blankId),
            child: Container(
              constraints: const BoxConstraints(minWidth: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              // margin: const EdgeInsets.only(right: 2, left: 2),
              decoration: BoxDecoration(
                color: fillColor,
                border: Border.all(color: borderColor, width: 0),
                borderRadius: BorderRadius.circular(4),
              ),
              child:
                  isEmpty
                      ? Text(
                        ' ',
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 13,
                          height: 1.4,
                          color: borderColor,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                      : HighlightView(
                        filledValue!,
                        language: language,
                        theme: customTheme,
                        padding: EdgeInsets.zero,
                        textStyle: GoogleFonts.sourceCodePro(
                          fontSize: 13,
                          letterSpacing: -0.6,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
            ),
          ),
        );
      },
    );
  }
}
