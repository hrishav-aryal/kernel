import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import 'content_interactor.dart';
import 'utils.dart';
import 'code_fill_code_renderer.dart';
import 'code_output_widget.dart';

/// Code Fill Widget that works with CodeFillInteractor
class CodeFillInteractorWidget extends StatefulWidget {
  final ContentElement element;
  final CodeFillInteractor interactor;
  final bool isBlockCompleted;

  const CodeFillInteractorWidget({
    super.key,
    required this.element,
    required this.interactor,
    this.isBlockCompleted = false,
  });

  @override
  State<CodeFillInteractorWidget> createState() =>
      _CodeFillInteractorWidgetState();
}

class _CodeFillInteractorWidgetState extends State<CodeFillInteractorWidget>
    with TickerProviderStateMixin {
  List<String> _blankIds = [];
  late AnimationController _shakeController;
  late AnimationController _checkmarkController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _checkmarkAnimation;
  late AnimationController _hintController;
  late Animation<double> _hintFadeAnimation;
  bool _showingWrongAnswer = false;
  bool _showHint = false;
  bool _hasAttempted = false;

  // Randomized options
  late List<MapEntry<int, String>>
  _shuffledOptions; // original_index -> option_text

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hintController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _checkmarkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkmarkController, curve: Curves.easeIn),
    );
    _hintFadeAnimation = Tween<double>(
      begin: 0.0, // Start invisible
      end: 1.0, // End fully visible
    ).animate(CurvedAnimation(parent: _hintController, curve: Curves.easeOut));

    // Extract blank IDs from lines and initialize interactor
    final lines = widget.element.lines ?? [];
    _blankIds = [];
    for (final line in lines) {
      final blankString = line['blank'] as String?;
      if (blankString != null) {
        // Handle comma-separated blank IDs (e.g., "1,2")
        final blankIds = blankString.split(',').map((id) => id.trim()).toList();
        _blankIds.addAll(blankIds);
      }
    }

    // Shuffle options
    final options = widget.element.options ?? [];
    _shuffledOptions =
        options.asMap().entries.map((e) => MapEntry(e.key, e.value)).toList();
    _shuffledOptions.shuffle(Random());

    // Initialize interactor with shuffled options
    final shuffledOptionStrings = _shuffledOptions.map((e) => e.value).toList();
    widget.interactor.initializeOptions(shuffledOptionStrings, _blankIds);

    // If block is completed, fill all blanks with correct answers
    if (widget.isBlockCompleted) {
      final solutions = widget.element.solutions ?? {};
      for (String blankId in _blankIds) {
        final correctAnswer = solutions[blankId];
        if (correctAnswer != null) {
          // Find the index of the correct answer in options
          final optionIndex = widget.interactor.availableOptions.indexOf(
            correctAnswer,
          );
          if (optionIndex != -1) {
            // Simulate filling the blank with correct answer
            widget.interactor.onOptionSelected(correctAnswer, [
              blankId,
            ], optionIndex);
          }
        }
      }
      widget.interactor.onAnsweredCorrectly();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _checkmarkController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prompt = widget.element.content;
    final lines = widget.element.lines ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prompt Section
          if (prompt.isNotEmpty) ...[
            buildRichText(
              prompt,
              Theme.of(context).textTheme.bodyMedium?.copyWith(),
              context,
            ),
            const SizedBox(height: 16),
          ],

          // Code Section
          CodeFillCodeRenderer(
            lines: lines,
            language: widget.element.language ?? 'python',
            interactor: widget.interactor,
            shakeAnimation: _shakeAnimation,
            checkmarkAnimation: _checkmarkAnimation,
            showingWrongAnswer: _showingWrongAnswer,
            onBlankTapped: _onBlankTapped,
          ),

          // Output Section (shows when answered correctly)
          if (widget.element.output != null)
            CodeOutputWidget(
              output: widget.element.output!,
              show:
                  widget.interactor.hasAnswered &&
                  widget.interactor.isCompleted,
            ),

          // See Answer button (appears after first wrong attempt)
          _buildSeeAnswerSection(context),

          const SizedBox(height: 24),
          // Options Section
          _buildOptionsSection(context),

          // Hint Section (slides in on wrong answer)
          _buildHintSection(context),
        ],
      ),
    );
  }

  Widget _buildOptionsSection(BuildContext context) {
    final hasFilledBlanks = widget.interactor.filledBlanks.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 0,
        ),
      ),
      child: Stack(
        children: [
          // Centered options
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
            child: Center(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children:
                    _shuffledOptions.asMap().entries.map((entry) {
                      final displayIndex = entry.key;
                      final option = entry.value.value;
                      return _buildOptionChip(context, option, displayIndex);
                    }).toList(),
              ),
            ),
          ),

          // Clear button positioned at top right corner
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed:
                  (hasFilledBlanks && !widget.interactor.hasAnswered)
                      ? _onClearAll
                      : null,
              icon: Icon(
                Icons.refresh,
                size: 30,
                color:
                    (hasFilledBlanks && !widget.interactor.hasAnswered)
                        ? Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7)
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.3),
              ),
              tooltip: 'Clear All',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeeAnswerSection(BuildContext context) {
    // Only show if user has attempted at least once and hasn't completed yet
    if (!_hasAttempted ||
        widget.interactor.isCompleted ||
        widget.isBlockCompleted) {
      return const SizedBox.shrink();
    }

    // Check if any blank is filled
    final hasFilledBlanks = widget.interactor.filledBlanks.isNotEmpty;

    return Container(
      width: double.infinity,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(top: 8),
      child: GestureDetector(
        onTap: hasFilledBlanks ? null : _onSeeAnswerTapped,
        child: Text(
          'See Answer',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color:
                hasFilledBlanks
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.3)
                    : Theme.of(context).colorScheme.primary,
            decoration: TextDecoration.underline,
            decorationColor:
                hasFilledBlanks
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.3)
                    : Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildHintSection(BuildContext context) {
    final hint = widget.element.hint;

    if (hint == null || hint.isEmpty || !_showHint) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      child: FadeTransition(
        opacity: _hintFadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionChip(BuildContext context, String option, int index) {
    final isUsed = widget.interactor.usedOptionIndices.contains(index);
    final isDisabled =
        widget.interactor.hasAnswered || widget.isBlockCompleted || isUsed;
    final isAnsweredCorrectly =
        widget.interactor.hasAnswered && widget.interactor.isCompleted;
    final shouldGreyOut = isUsed || isAnsweredCorrectly;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : () => _onOptionSelected(option, index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color:
                shouldGreyOut
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.05)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color:
                  shouldGreyOut
                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.1)
                      : Theme.of(context).colorScheme.primary.withOpacity(0.1),
              width: 0,
            ),
          ),
          child: Text(
            option,
            style: GoogleFonts.sourceCodePro(
              color:
                  shouldGreyOut
                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.2)
                      : Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: -0.6,
            ),
          ),
        ),
      ),
    );
  }

  void _onOptionSelected(String option, int index) {
    widget.interactor.onOptionSelected(option, _blankIds, index);
    setState(() {});
  }

  void _onBlankTapped(String blankId) {
    if (!widget.interactor.hasAnswered && !widget.isBlockCompleted) {
      widget.interactor.onBlankCleared(blankId, _blankIds);
      setState(() {});
    }
  }

  void _onClearAll() {
    widget.interactor.onClearAll();
    setState(() {});
  }

  void _onSeeAnswerTapped() {
    if (widget.interactor.isCompleted || widget.isBlockCompleted) {
      return;
    }

    // Fill all blanks with correct answers
    final solutions = widget.element.solutions ?? {};
    for (String blankId in _blankIds) {
      final correctAnswer = solutions[blankId];
      if (correctAnswer != null) {
        // Find the index of the correct answer in options
        final optionIndex = widget.interactor.availableOptions.indexOf(
          correctAnswer,
        );
        if (optionIndex != -1) {
          // Simulate filling the blank with correct answer
          widget.interactor.onOptionSelected(correctAnswer, [
            blankId,
          ], optionIndex);
        }
      }
    }

    // Mark as completed and trigger checkmark animation
    widget.interactor.onAnsweredCorrectly();
    _checkmarkController.forward();

    setState(() {});
  }

  /// Public method to validate the Code Fill (called by interactor)
  bool validateAnswer() {
    if (!widget.interactor.areAllBlanksFilled(_blankIds) ||
        widget.interactor.hasAnswered ||
        widget.isBlockCompleted) {
      return false;
    }

    // Mark that user has attempted at least once
    _hasAttempted = true;

    final solutions = widget.element.solutions ?? {};
    final filledBlanks = widget.interactor.filledBlanks;

    // Check each blank
    Map<String, bool> results = {};
    bool allCorrect = true;

    for (String blankId in _blankIds) {
      final filledValue = filledBlanks[blankId];
      final correctValue = solutions[blankId];
      final isCorrect = filledValue == correctValue;

      results[blankId] = isCorrect;
      if (!isCorrect) {
        allCorrect = false;
      }
    }

    // Set results for visual feedback
    widget.interactor.setBlankResults(results);

    if (allCorrect) {
      // Mark as completed in interactor
      widget.interactor.onAnsweredCorrectly();

      // Start checkmark animation
      _checkmarkController.forward();
      setState(() {}); // Update UI with results
    } else {
      // Wrong answer - show feedback then reset
      setState(() {
        _showingWrongAnswer = true;
        // Don't show hint yet - wait until after reset
      });

      // Start shake animation
      _shakeController.forward().then((_) {
        // After animation, reset everything
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            widget.interactor.resetAfterWrongAnswer();
            setState(() {
              _showingWrongAnswer = false;
              _showHint = true; // Now show hint after reset
            });
            _shakeController.reset();

            // Start hint fade animation after reset is complete
            _hintController.forward();
          }
        });
      });
    }

    return allCorrect;
  }
}
