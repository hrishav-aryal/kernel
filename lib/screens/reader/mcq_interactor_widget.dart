import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../config/supabase_config.dart';
import '../../services/image_preloader_service.dart';
import 'content_interactor.dart';
import 'utils.dart';

/// MCQ Widget that works with MCQInteractor
/// This replaces the existing MCQWidget but maintains identical functionality
class MCQInteractorWidget extends StatefulWidget {
  final ContentElement element;
  final MCQInteractor interactor;
  final bool isBlockCompleted;

  const MCQInteractorWidget({
    super.key,
    required this.element,
    required this.interactor,
    this.isBlockCompleted = false,
  });

  @override
  State<MCQInteractorWidget> createState() => _MCQInteractorWidgetState();
}

class _MCQInteractorWidgetState extends State<MCQInteractorWidget>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  int? _animatingOptionIndex; // Track which option is animating

  // Randomized options
  late List<MapEntry<int, String>>
  _shuffledOptions; // original_index -> option_text
  late int
  _shuffledCorrectIndex; // The correct answer's position in shuffled list

  @override
  void initState() {
    super.initState();

    // Shuffle options
    final options = widget.element.options ?? [];
    final correctIndex = widget.element.correctAnswerIndex ?? 0;

    // Create list of entries with original indices
    _shuffledOptions =
        options.asMap().entries.map((e) => MapEntry(e.key, e.value)).toList();

    // Shuffle the options
    _shuffledOptions.shuffle(Random());

    // Find the new position of the correct answer
    _shuffledCorrectIndex = _shuffledOptions.indexWhere(
      (entry) => entry.key == correctIndex,
    );

    // If block is completed, set the correct answer as selected in interactor
    if (widget.isBlockCompleted) {
      widget.interactor.onOptionSelected(_shuffledCorrectIndex);
      widget.interactor.onAnsweredCorrectly();
    }

    // Initialize animation controllers
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Create animations
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.element.question ?? widget.element.content;
    final options = widget.element.options ?? [];
    final questionImageUrl = widget.element.questionImageUrl;

    if (options.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Section
          _buildQuestionSection(context, question, questionImageUrl),

          const SizedBox(height: 24),

          // Options Section
          _buildOptionsSection(context, options),
        ],
      ),
    );
  }

  Widget _buildQuestionSection(
    BuildContext context,
    String question,
    String? questionImageUrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question text
        if (question.isNotEmpty) ...[
          buildRichText(
            question,
            Theme.of(context).textTheme.bodyMedium?.copyWith(),
            context,
          ),
          const SizedBox(height: 16),
        ],

        // Question image (if provided)
        if (questionImageUrl != null && questionImageUrl.isNotEmpty)
          _buildQuestionImage(context, questionImageUrl),
      ],
    );
  }

  Widget _buildQuestionImage(BuildContext context, String imageUrl) {
    final fullImageUrl = SupabaseConfig.getContentUrl(imageUrl);
    final imagePreloader = ImagePreloaderService();
    final isPreloaded = imagePreloader.isImagePreloaded(fullImageUrl);
    final imageProvider = imagePreloader.getImageProvider(fullImageUrl);

    if (!isPreloaded || imageProvider == null) {
      return _buildImagePlaceholder(context);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image(
          image: imageProvider,
          width: double.infinity,
          fit: BoxFit.fitWidth,
          errorBuilder: (context, error, stackTrace) {
            return _buildImagePlaceholder(context);
          },
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 32,
          color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildOptionsSection(BuildContext context, List<String> options) {
    return Column(
      children:
          _shuffledOptions.asMap().entries.map((entry) {
            final displayIndex = entry.key; // Index in shuffled list
            final optionData =
                entry.value; // MapEntry<original_index, option_text>
            final option = optionData.value;
            final isSelected =
                widget.interactor.selectedOptionIndex == displayIndex;
            final isCorrect = displayIndex == _shuffledCorrectIndex;
            final showResult = widget.interactor.hasAnswered && isSelected;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOptionTile(
                context,
                option,
                displayIndex,
                isSelected,
                showResult,
                isCorrect,
              ),
            );
          }).toList(),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    String option,
    int index,
    bool isSelected,
    bool showResult,
    bool isCorrect,
  ) {
    Color? backgroundColor;
    Color? borderColor;
    Color? textColor;
    bool isDisabled = false;

    // Check if this option is in the wrong answers set
    final isWrongAnswer = widget.interactor.wrongAnswers.contains(index);

    if (widget.interactor.hasAnswered) {
      if (isSelected && isCorrect) {
        // Show the selected correct answer
        backgroundColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        textColor = Colors.green[700];
      } else {
        // Grey out all other options (including previously selected wrong ones)
        backgroundColor = Theme.of(
          context,
        ).colorScheme.surface.withOpacity(0.5);
        borderColor = Theme.of(context).colorScheme.outline.withOpacity(0.3);
        textColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.4);
        isDisabled = true;
      }
    } else if (isWrongAnswer) {
      // Grey out options that have been proven wrong in previous attempts
      backgroundColor = Theme.of(context).colorScheme.surface.withOpacity(0.5);
      borderColor = Theme.of(context).colorScheme.outline.withOpacity(0.3);
      textColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.4);
      isDisabled = true;
    } else if (isSelected) {
      backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
      borderColor = Theme.of(context).colorScheme.primary;
      textColor = Theme.of(context).colorScheme.primary;
    }

    // Check if this option should be animated
    final shouldAnimate = _animatingOptionIndex == index;

    Widget optionTile = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            (widget.interactor.hasAnswered ||
                    isDisabled ||
                    widget.isBlockCompleted)
                ? null
                : () => _selectOption(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor ?? Theme.of(context).colorScheme.outline,
              width: isSelected || showResult ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Option text with code block support
              Expanded(
                child: buildRichText(
                  option,
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor ?? Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                  context,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Wrap with shake animation for wrong answers only
    if (shouldAnimate && widget.interactor.wrongAnswers.contains(index)) {
      // Shake animation for wrong answer
      return AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          final offset = sin(_shakeAnimation.value * pi * 3) * 5;
          return Transform.translate(
            offset: Offset(offset, 0),
            child: optionTile,
          );
        },
      );
    }

    return optionTile;
  }

  void _selectOption(int index) {
    if (!widget.interactor.hasAnswered && !widget.isBlockCompleted) {
      widget.interactor.onOptionSelected(index);
      setState(() {
        // Trigger rebuild to show selection
      });
      // Trigger parent state change to update button
      widget.interactor.onSelectionChanged();
    }
  }

  /// Public method to validate the MCQ (called by interactor)
  bool validateAnswer() {
    if (widget.interactor.selectedOptionIndex == null ||
        widget.interactor.hasAnswered ||
        widget.isBlockCompleted) {
      return false;
    }

    final isCorrect =
        widget.interactor.selectedOptionIndex == _shuffledCorrectIndex;
    final selectedIndex = widget.interactor.selectedOptionIndex;

    setState(() {
      _animatingOptionIndex = selectedIndex; // Mark for animation
    });

    // Trigger animations
    if (selectedIndex != null) {
      if (!isCorrect) {
        // Add to wrong answers in interactor
        widget.interactor.addWrongAnswer(selectedIndex);

        // Reset selection in interactor to allow trying again
        widget.interactor.resetSelection();

        // Shake animation for wrong answer
        _shakeController.forward().then((_) {
          _shakeController.reset();
          setState(() {
            _animatingOptionIndex = null;
          });
        });
      } else {
        // Mark as completed in interactor
        widget.interactor.onAnsweredCorrectly();
      }
    }

    return isCorrect;
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }
}
