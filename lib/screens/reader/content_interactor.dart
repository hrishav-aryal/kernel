import 'package:flutter/material.dart';
import '../../models/models.dart';

/// Base interface for content element interactors
/// Each content type implements this to handle its specific logic
abstract class ContentInteractor {
  /// Whether this content element is completed (user has successfully interacted)
  bool get isCompleted;

  /// Whether the user can proceed (has made selections/inputs but may not be correct yet)
  bool get canProceed;

  /// Text to display on the CTA button
  String get ctaText;

  /// Optional color for the CTA button (e.g., green for correct MCQ)
  Color? get ctaColor;

  /// Handle the CTA button press (validate, show feedback, etc.)
  void handleCTAPressed();

  /// Reset the interactor state (for retries, navigation back, etc.)
  void reset();

  /// Build the widget for this content element
  Widget buildWidget(
    BuildContext context,
    ContentElement element, {
    VoidCallback? onStateChanged,
  });

  /// Dispose resources when no longer needed
  void dispose() {}
}

/// Factory to create appropriate interactor for content element type
class ContentInteractorFactory {
  static ContentInteractor createInteractor(ContentElementType type) {
    switch (type) {
      case ContentElementType.mcq:
        return MCQInteractor();
      case ContentElementType.code_fill:
        return CodeFillInteractor();
      case ContentElementType.heading:
      case ContentElementType.text:
      case ContentElementType.image:
      case ContentElementType.code:
      case ContentElementType.list:
      case ContentElementType.spacer:
        return TextInteractor();
    }
  }
}

/// Simple interactor for non-interactive content (text, images, etc.)
class TextInteractor extends ContentInteractor {
  @override
  bool get isCompleted => true; // Text content is always "completed"

  @override
  bool get canProceed => true; // Can always proceed past text content

  @override
  String get ctaText => 'Continue';

  @override
  Color? get ctaColor => null; // Use default button color

  @override
  void handleCTAPressed() {
    // No action needed for text content
  }

  @override
  void reset() {
    // No state to reset for text content
  }

  @override
  Widget buildWidget(
    BuildContext context,
    ContentElement element, {
    VoidCallback? onStateChanged,
  }) {
    // This will be implemented to return the existing content widgets
    // For now, return a placeholder
    return const SizedBox.shrink();
  }
}

/// Interactor for MCQ content elements
class MCQInteractor extends ContentInteractor {
  bool _isCompleted = false;
  bool _hasSelection = false;
  String _currentCtaText = 'Check'; // Initialize with Check for MCQs
  Color? _currentCtaColor;

  // Callback to handle MCQ state changes
  VoidCallback? _onStateChanged;

  // MCQ-specific state
  int? _selectedOptionIndex;
  bool _hasAnswered = false;
  Set<int> _wrongAnswers = {};

  // Reference to the widget for validation
  GlobalKey? _widgetKey;

  MCQInteractor() {
    // Set initial button state for MCQs
    _updateButtonState();
  }

  @override
  bool get isCompleted => _isCompleted;

  @override
  bool get canProceed => _hasSelection;

  @override
  String get ctaText => _currentCtaText;

  @override
  Color? get ctaColor => _currentCtaColor;

  @override
  void handleCTAPressed() {
    if (_isCompleted) {
      // Already completed, this should trigger navigation
      return;
    }

    if (_hasSelection && !_hasAnswered) {
      // Validate the selected answer through the widget
      _validateAnswer();
    }
  }

  @override
  void reset() {
    _isCompleted = false;
    _hasSelection = false;
    _currentCtaText = 'Continue';
    _currentCtaColor = null;
    _selectedOptionIndex = null;
    _hasAnswered = false;
    _wrongAnswers.clear();
    _onStateChanged?.call();
  }

  @override
  Widget buildWidget(
    BuildContext context,
    ContentElement element, {
    VoidCallback? onStateChanged,
  }) {
    _onStateChanged = onStateChanged;
    // This method is not used in the new architecture
    // MCQ widgets are created directly in the block widget
    return const SizedBox.shrink();
  }

  /// Called when user selects an MCQ option
  void onOptionSelected(int optionIndex) {
    _selectedOptionIndex = optionIndex;
    _hasSelection = true;
    _updateButtonState();
    _onStateChanged?.call();
  }

  /// Called when MCQ selection changes (for button state updates)
  void onSelectionChanged() {
    _updateButtonState();
    _onStateChanged?.call();
  }

  /// Called when MCQ is answered correctly
  void onAnsweredCorrectly() {
    _isCompleted = true;
    _hasAnswered = true;
    _updateButtonState();
    _onStateChanged?.call();
  }

  /// Validate the currently selected answer
  void _validateAnswer() {
    // Trigger validation in the widget
    if (_widgetKey?.currentState != null) {
      // The widget will handle the validation logic and call back to this interactor
      final widget = _widgetKey!.currentState as dynamic;
      if (widget.validateAnswer != null) {
        widget.validateAnswer();
      }
    }
  }

  /// Update button text and color based on current state
  void _updateButtonState() {
    if (_isCompleted) {
      _currentCtaText = 'Continue';
      _currentCtaColor = Colors.green[600];
    } else {
      // For MCQs, always show "Check" when not completed, regardless of selection
      _currentCtaText = 'Check';
      _currentCtaColor = null;
    }
  }

  /// Set the widget key for validation callbacks
  void setWidgetKey(GlobalKey key) {
    _widgetKey = key;
  }

  /// Check if user has selected an answer
  bool hasSelectedAnswer() {
    return _selectedOptionIndex != null;
  }

  /// Get the selected option index
  int? get selectedOptionIndex => _selectedOptionIndex;

  /// Check if answer has been validated
  bool get hasAnswered => _hasAnswered;

  /// Get wrong answers set
  Set<int> get wrongAnswers => _wrongAnswers;

  /// Add a wrong answer
  void addWrongAnswer(int optionIndex) {
    _wrongAnswers.add(optionIndex);
  }

  /// Reset selection (for wrong answers)
  void resetSelection() {
    _selectedOptionIndex = null;
    _hasSelection = false;
    _hasAnswered = false;
    _updateButtonState();
    _onStateChanged?.call();
  }

  /// Set the state change callback
  void setStateChangeCallback(VoidCallback? callback) {
    _onStateChanged = callback;
  }
}

/// Interactor for Code Fill content elements
class CodeFillInteractor extends ContentInteractor {
  bool _isCompleted = false;
  String _currentCtaText = 'Check';
  Color? _currentCtaColor;

  // Callback to handle state changes
  VoidCallback? _onStateChanged;

  // Code Fill specific state
  Map<String, String> _filledBlanks = {}; // blank_id -> selected_option
  List<String> _allOptions = []; // All original options
  Set<int> _usedOptionIndices = {}; // Option indices that have been used
  bool _hasAnswered = false;
  Map<String, bool> _blankResults = {}; // blank_id -> is_correct
  bool _allBlanksFilled = false; // Track if all blanks are filled

  // Reference to the widget for validation
  GlobalKey? _widgetKey;

  CodeFillInteractor() {
    _updateButtonState();
  }

  @override
  bool get isCompleted => _isCompleted;

  @override
  bool get canProceed => _isCompleted;

  @override
  String get ctaText => _currentCtaText;

  @override
  Color? get ctaColor => _currentCtaColor;

  @override
  void handleCTAPressed() {
    if (_isCompleted) {
      // Already completed, this should trigger navigation
      return;
    }

    // Only validate if all blanks are filled and not yet answered
    if (_allBlanksFilled && !_hasAnswered) {
      // Validate the filled blanks through the widget
      _validateAnswer();
    }
  }

  @override
  void reset() {
    _isCompleted = false;
    _currentCtaText = 'Check';
    _currentCtaColor = null;
    _filledBlanks.clear();
    _usedOptionIndices.clear();
    _hasAnswered = false;
    _blankResults.clear();
    _allBlanksFilled = false;
    _onStateChanged?.call();
  }

  @override
  Widget buildWidget(
    BuildContext context,
    ContentElement element, {
    VoidCallback? onStateChanged,
  }) {
    _onStateChanged = onStateChanged;
    // This method is not used in the new architecture
    // Code Fill widgets are created directly in the block widget
    return const SizedBox.shrink();
  }

  /// Initialize with options from content element
  void initializeOptions(List<String> options, List<String> blankIds) {
    _allOptions = List.from(options);
    _allBlanksFilled = _filledBlanks.length == blankIds.length;
  }

  /// Called when user selects an option
  void onOptionSelected(String option, List<String> blankIds, int optionIndex) {
    if (_hasAnswered || _usedOptionIndices.contains(optionIndex)) return;

    // Find the next empty blank in sequential order
    String? nextBlankId;
    for (String blankId in blankIds) {
      if (!_filledBlanks.containsKey(blankId)) {
        nextBlankId = blankId;
        break;
      }
    }

    if (nextBlankId != null) {
      _filledBlanks[nextBlankId] = option;
      _usedOptionIndices.add(optionIndex);
      _allBlanksFilled = _filledBlanks.length == blankIds.length;
      _updateButtonState();
      _onStateChanged?.call();
    }
  }

  /// Called when user taps a filled blank to clear it
  void onBlankCleared(String blankId, List<String> allBlankIds) {
    if (_hasAnswered) return;

    final clearedOption = _filledBlanks.remove(blankId);
    if (clearedOption != null) {
      // Find the index of the cleared option and remove it from used indices
      final optionIndex = _allOptions.indexOf(clearedOption);
      if (optionIndex != -1) {
        _usedOptionIndices.remove(optionIndex);
      }
      _allBlanksFilled = _filledBlanks.length == allBlankIds.length;
      _updateButtonState();
      _onStateChanged?.call();
    }
  }

  /// Called when user taps clear all button
  void onClearAll() {
    if (_hasAnswered) return;

    _usedOptionIndices.clear();
    _filledBlanks.clear();
    _allBlanksFilled = false;
    _updateButtonState();
    _onStateChanged?.call();
  }

  /// Called when code fill is answered correctly
  void onAnsweredCorrectly() {
    _isCompleted = true;
    _hasAnswered = true;
    _updateButtonState();
    _onStateChanged?.call();
  }

  /// Validate the currently filled blanks
  void _validateAnswer() {
    // Trigger validation in the widget
    if (_widgetKey?.currentState != null) {
      final widget = _widgetKey!.currentState as dynamic;
      if (widget.validateAnswer != null) {
        widget.validateAnswer();
      }
    }
  }

  /// Update button text and color based on current state
  void _updateButtonState() {
    if (_isCompleted) {
      _currentCtaText = 'Continue';
      _currentCtaColor = Colors.green[600];
    } else {
      _currentCtaText = 'Check';
      _currentCtaColor = null;
    }
  }

  /// Check if the check button should be enabled (all blanks filled)
  bool get canCheck => _allBlanksFilled && !_hasAnswered;

  /// Reset after wrong answer - clear everything and start over
  void resetAfterWrongAnswer() {
    _hasAnswered = false;
    _blankResults.clear();
    // Clear all filled blanks - user starts fresh
    _usedOptionIndices.clear();
    _filledBlanks.clear();
    _allBlanksFilled = false;
    _updateButtonState();
    _onStateChanged?.call();
  }

  /// Check if all blanks are filled
  bool get allBlanksFilled => _allBlanksFilled;

  /// Set the widget key for validation callbacks
  void setWidgetKey(GlobalKey key) {
    _widgetKey = key;
  }

  /// Check if all blanks are filled
  bool areAllBlanksFilled(List<String> blankIds) {
    return blankIds.every((blankId) => _filledBlanks.containsKey(blankId));
  }

  /// Get filled blanks map
  Map<String, String> get filledBlanks => Map.unmodifiable(_filledBlanks);

  /// Get available options (now returns all options for display)
  List<String> get availableOptions => List.unmodifiable(_allOptions);

  /// Get used option indices
  Set<int> get usedOptionIndices => Set.unmodifiable(_usedOptionIndices);

  /// Check if answer has been validated
  bool get hasAnswered => _hasAnswered;

  /// Get blank results (for visual feedback)
  Map<String, bool> get blankResults => Map.unmodifiable(_blankResults);

  /// Set blank results after validation
  void setBlankResults(Map<String, bool> results) {
    _blankResults = Map.from(results);
  }

  /// Set the state change callback
  void setStateChangeCallback(VoidCallback? callback) {
    _onStateChanged = callback;
  }
}
