import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'content_interactor.dart';

/// Manages interaction logic for an entire block
/// Coordinates multiple content elements and determines block completion state
class BlockInteractor {
  final Block block;
  final int blockIndex;
  final bool isBlockCompleted;

  // Map of element index to its interactor
  final Map<int, ContentInteractor> _elementInteractors = {};

  // Callback for when block state changes
  VoidCallback? _onStateChanged;

  BlockInteractor({
    required this.block,
    required this.blockIndex,
    this.isBlockCompleted = false,
  }) {
    _initializeInteractors();
  }

  /// Initialize interactors for all content elements in the block
  void _initializeInteractors() {
    for (int i = 0; i < block.elements.length; i++) {
      final element = block.elements[i];
      final interactor = ContentInteractorFactory.createInteractor(
        element.type,
      );
      _elementInteractors[i] = interactor;

      // Connect interactive interactor state changes to block state changes
      if (interactor is MCQInteractor) {
        interactor.setStateChangeCallback(() {
          _onStateChanged?.call();
        });
      } else if (interactor is CodeFillInteractor) {
        interactor.setStateChangeCallback(() {
          _onStateChanged?.call();
        });
      }
    }
  }

  /// Set callback for state changes
  void setStateChangeCallback(VoidCallback callback) {
    _onStateChanged = callback;
  }

  /// Check if the entire block is completed
  bool get isCompleted {
    if (isBlockCompleted) return true;

    // Block is completed if all interactive elements are completed
    final interactiveElements = _elementInteractors.values.where(
      (interactor) =>
          interactor is MCQInteractor || interactor is CodeFillInteractor,
    );

    if (interactiveElements.isEmpty) {
      // No interactive elements, block is always completed
      return true;
    }

    // All interactive elements must be completed
    return interactiveElements.every((interactor) => interactor.isCompleted);
  }

  /// Check if user can proceed from this block (actually move to next block)
  bool get canProceed {
    if (isBlockCompleted) return true;

    // Can proceed if all interactive elements allow it
    final interactiveElements = _elementInteractors.values.where(
      (interactor) =>
          interactor is MCQInteractor || interactor is CodeFillInteractor,
    );

    if (interactiveElements.isEmpty) {
      // No interactive elements, can always proceed
      return true;
    }

    // All interactive elements must allow proceeding
    return interactiveElements.every((interactor) => interactor.canProceed);
  }

  /// Check if the CTA button should be enabled (can click Check/Continue)
  bool get canInteract {
    if (isBlockCompleted) return true;

    // Check if we can interact with any interactive elements
    final interactiveElements = _elementInteractors.values.where(
      (interactor) =>
          interactor is MCQInteractor || interactor is CodeFillInteractor,
    );

    if (interactiveElements.isEmpty) {
      // No interactive elements, can always interact
      return true;
    }

    // Check if any interactive element allows interaction
    for (final interactor in interactiveElements) {
      if (!interactor.isCompleted) {
        if (interactor is MCQInteractor) {
          return interactor.hasSelectedAnswer();
        } else if (interactor is CodeFillInteractor) {
          return interactor.canCheck;
        }
      }
    }

    // All completed, can proceed
    return true;
  }

  /// Get the appropriate CTA text for this block
  String get ctaText {
    // Find interactive elements first
    final interactiveElements = _elementInteractors.entries
        .where(
          (entry) =>
              _elementInteractors[entry.key] is MCQInteractor ||
              _elementInteractors[entry.key] is CodeFillInteractor,
        )
        .map((entry) => entry.value);

    // If no interactive elements, always show Continue
    if (interactiveElements.isEmpty) {
      return 'Continue';
    }

    // For interactive blocks, check each interactor
    for (final interactor in interactiveElements) {
      if (!interactor.isCompleted) {
        return interactor.ctaText;
      }
    }

    // All interactive elements completed
    return 'Continue';
  }

  /// Get the appropriate CTA color for this block
  Color? get ctaColor {
    // Find interactive elements first
    final interactiveElements = _elementInteractors.entries
        .where(
          (entry) =>
              _elementInteractors[entry.key] is MCQInteractor ||
              _elementInteractors[entry.key] is CodeFillInteractor,
        )
        .map((entry) => entry.value);

    // If no interactive elements, no special color
    if (interactiveElements.isEmpty) {
      return null;
    }

    // If all interactive elements are completed, show green
    if (isCompleted) return Colors.green[600];

    // Find the first incomplete interactive element
    for (final interactor in interactiveElements) {
      if (!interactor.isCompleted) {
        return interactor.ctaColor;
      }
    }

    return null;
  }

  /// Handle CTA button press for this block
  void handleCTAPressed() {
    // Find the first incomplete interactive element and handle its CTA
    final interactiveElements = _elementInteractors.entries.where(
      (entry) =>
          _elementInteractors[entry.key] is MCQInteractor ||
          _elementInteractors[entry.key] is CodeFillInteractor,
    );

    for (final entry in interactiveElements) {
      final interactor = entry.value;
      if (!interactor.isCompleted) {
        interactor.handleCTAPressed();
        break; // Only handle the first incomplete element
      }
    }
  }

  /// Get interactor for a specific element
  ContentInteractor? getElementInteractor(int elementIndex) {
    return _elementInteractors[elementIndex];
  }

  /// Check if all MCQs in this block have selected answers
  bool hasAllMCQsSelected() {
    if (isBlockCompleted) return true;

    final mcqInteractors =
        _elementInteractors.values.whereType<MCQInteractor>();

    if (mcqInteractors.isEmpty) return true;

    return mcqInteractors.every((interactor) => interactor.hasSelectedAnswer());
  }

  /// Validate all MCQs in this block
  bool validateAllMCQs() {
    bool allCorrect = true;

    final mcqInteractors = _elementInteractors.entries.where(
      (entry) => entry.value is MCQInteractor,
    );

    for (final entry in mcqInteractors) {
      final interactor = entry.value as MCQInteractor;
      if (interactor.hasSelectedAnswer()) {
        interactor.handleCTAPressed();
        if (!interactor.isCompleted) {
          allCorrect = false;
        }
      } else {
        allCorrect = false;
      }
    }

    return allCorrect;
  }

  /// Reset all interactors in this block
  void reset() {
    for (final interactor in _elementInteractors.values) {
      interactor.reset();
    }
  }

  /// Dispose all interactors
  void dispose() {
    for (final interactor in _elementInteractors.values) {
      interactor.dispose();
    }
    _elementInteractors.clear();
  }
}
