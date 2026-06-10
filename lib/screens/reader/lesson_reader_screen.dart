import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import 'lesson_progress_bar.dart';
import 'lesson_block_interactor_widget.dart'
    show LessonBlockInteractorWidget, BlockInteractorInterface;
import 'lesson_completion_screen.dart';
import 'lesson_completion_error_screen.dart';
import '../../services/image_preloader_service.dart';
import '../../services/progress_handler_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_byte_progress_provider.dart';
import '../../providers/course_data_provider.dart';
import '../../repositories/byte_repository.dart';

class LessonReaderScreen extends StatefulWidget {
  final CourseByte courseByte;

  const LessonReaderScreen({super.key, required this.courseByte});

  @override
  State<LessonReaderScreen> createState() => _LessonReaderScreenState();
}

class _LessonReaderScreenState extends State<LessonReaderScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final ByteRepository _byteRepository = ByteRepository();
  final ImagePreloaderService _imagePreloader = ImagePreloaderService();

  int _currentBlock = 0;
  int _maxVisitedBlock = 0;
  List<Block> _blocks = [];
  List<GlobalKey> _blockKeys = [];
  List<GlobalKey<State<LessonBlockInteractorWidget>>> _blockInteractorKeys = [];
  bool _isLoading = true;
  String? _error;
  bool _showContinueButton = true;

  // Progress handler for this byte type
  ProgressHandler? _progressHandler;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _loadByteContent();
  }

  void _onScroll() {
    if (!mounted ||
        _blockKeys.isEmpty ||
        _maxVisitedBlock >= _blockKeys.length) {
      return;
    }

    // Get the position of the most recent (current) block
    final mostRecentBlockKey = _blockKeys[_maxVisitedBlock];
    final mostRecentBlockContext = mostRecentBlockKey.currentContext;

    if (mostRecentBlockContext != null) {
      final RenderBox renderBox =
          mostRecentBlockContext.findRenderObject() as RenderBox;

      // blockPosition: Y-coordinate of the block's top edge on screen
      // Negative = block is above viewport, Positive = visible/below
      final blockPosition = renderBox.localToGlobal(Offset.zero).dy;
      final screenHeight = MediaQuery.of(context).size.height;

      // VISIBILITY LOGIC:
      // Show button when the most recent block is in the lower portion of screen
      //
      // Adjust this threshold (0.0 to 1.0):
      // - 0.5 = show when block is in bottom half of screen
      // - 0.7 = show when block is in bottom 70% of screen (current)
      // - 1.0 = show only when block is at very bottom
      final visibilityThreshold = 0.5;

      final shouldShow = blockPosition < screenHeight * visibilityThreshold;

      if (_showContinueButton != shouldShow) {
        setState(() {
          _showContinueButton = shouldShow;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize progress handler for course bytes
    final courseByteProgressProvider =
        context.read<CourseByteProgressProvider>();
    _progressHandler = CourseByteProgressHandler(courseByteProgressProvider);
  }

  Future<void> _loadByteContent() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get course to determine loading strategy (local vs Supabase)
      final courseDataProvider = context.read<CourseDataProvider>();
      final course = courseDataProvider.courseData?.course;

      if (course == null) {
        throw Exception('Course data not available');
      }

      // ByteRepository checks course.useLocalContent flag and loads accordingly
      final blocks = await _byteRepository.loadCourseByteContent(
        courseByte: widget.courseByte,
        course: course,
      );

      // Preload images in the background
      if (mounted) {
        final imageUrls = _imagePreloader.extractImageUrls(blocks);
        if (imageUrls.isNotEmpty) {
          _imagePreloader.preloadImages(context, imageUrls).then((result) {
            if (result.hasFailures) {
              debugPrint(
                'Some images failed to preload: ${result.failedImages.length}',
              );
            }
          });
        }
      }

      // Display content immediately
      if (mounted) {
        setState(() {
          _blocks = blocks;
          _blockKeys = List.generate(blocks.length, (index) => GlobalKey());
          _blockInteractorKeys = List.generate(
            blocks.length,
            (index) => GlobalKey<State<LessonBlockInteractorWidget>>(),
          );
          _isLoading = false;
        });

        // If we have existing progress, scroll to the current block
        if (_currentBlock > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToCurrentBlock();
          });
        }

        // Ensure button state is calculated after widgets are built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              // This will recalculate the continue button state
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _handleContinuePressed() {
    final blockWidget = _blockInteractorKeys[_currentBlock].currentState;
    if (blockWidget != null) {
      final interactorWidget = blockWidget as BlockInteractorInterface;
      if (interactorWidget.isCompleted) {
        // Block is completed, proceed to next
        _goToNextBlock();
      } else {
        // Handle CTA press (validate, show feedback, etc.)
        interactorWidget.handleCTAPressed();
      }
    } else {
      // Fallback to old logic if interactor widget not available
      _goToNextBlock();
    }
  }

  void _goToNextBlock() {
    if (_maxVisitedBlock < _blocks.length - 1) {
      setState(() {
        _maxVisitedBlock++; // Add one more block to the scrollable area
        _currentBlock++;
      });

      // Scroll to the new block after it's been built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentBlock();

        // Trigger a state update to recalculate button state for new block
        if (mounted) {
          setState(() {
            // This will recalculate the continue button state
          });
        }
      });

      // Save progress with debouncing
      // _scheduleProgressSave();
    }
  }

  String _getContinueButtonText() {
    final blockWidget = _blockInteractorKeys[_currentBlock].currentState;
    if (blockWidget != null) {
      final interactorWidget = blockWidget as BlockInteractorInterface;
      return interactorWidget.ctaText;
    }

    return 'Continue';
  }

  bool _isContinueButtonEnabled() {
    if (_currentBlock >= _blocks.length - 1) return true;

    final blockWidget = _blockInteractorKeys[_currentBlock].currentState;
    if (blockWidget != null) {
      final interactorWidget = blockWidget as BlockInteractorInterface;
      return interactorWidget.canInteract;
    }

    return true;
  }

  void _scrollToCurrentBlock() {
    final context = _blockKeys[_currentBlock].currentContext;
    if (context != null) {
      // Use Flutter's built-in method to scroll the new block to the top
      Scrollable.ensureVisible(
        context,
        alignment: 0.0, // 0.0 = top of screen, 1.0 = bottom of screen
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Attempt to complete the lesson and return success status
  Future<bool> _attemptCompleteLesson() async {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isAuthenticated ||
        authProvider.user == null ||
        _progressHandler == null) {
      return false;
    }

    try {
      // Mark as completed using appropriate handler
      await _progressHandler!.markAsCompleted(
        authProvider.user!.id,
        widget.courseByte.id,
      );
      return true;
    } catch (e) {
      debugPrint('Error completing lesson: $e');
      return false;
    }
  }

  /// Navigate to completion screen
  void _navigateToCompletionScreen() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (context) => LessonCompletionScreen(
              lessonTitle: widget.courseByte.title,
              onContinue: () {
                // Pop twice: completion screen and reader screen
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
      ),
    );
  }

  /// Navigate to error screen
  void _navigateToErrorScreen() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (context) => LessonCompletionErrorScreen(
              lessonTitle: widget.courseByte.title,
              courseByteId: widget.courseByte.id,
              onGoHome: () {
                // Navigate back to home
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
      ),
    );
  }

  Future<void> _completeLesson() async {
    final success = await _attemptCompleteLesson();

    if (!mounted) return;

    if (success) {
      // Navigate to completion screen
      _navigateToCompletionScreen();
    } else {
      // Navigate to error screen
      _navigateToErrorScreen();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // No progress saving needed - users must complete lessons in one session
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.surface,
          title: Text(widget.courseByte.title),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Theme.of(context).colorScheme.surface,
        //   surfaceTintColor: Theme.of(context).colorScheme.surface,
        //   title: Text(widget.byte.title),
        // ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load content',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadByteContent,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pop(context),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          child: const Icon(Icons.close),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Progress bar extends to top of screen (including status bar)
                LessonProgressBar(
                  currentBlock: _currentBlock,
                  totalBlocks: _blocks.length,
                  onBackPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true, // Always show scrollbar
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          // Render all visited blocks
                          ..._blocks
                              .take(
                                _maxVisitedBlock + 1,
                              ) // Only show visited blocks
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                                final index = entry.key;
                                final block = entry.value;

                                final isCurrentBlock = index == _currentBlock;

                                return Container(
                                  key:
                                      _blockKeys[index], // Add key for precise scrolling
                                  width: double.infinity,
                                  // Current block takes full screen height, others use natural height
                                  constraints:
                                      isCurrentBlock
                                          ? BoxConstraints(
                                            minHeight:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height -
                                                250,
                                          )
                                          : null,
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    10,
                                    0,
                                    5,
                                  ),
                                  // Align content to top-left for current block
                                  alignment:
                                      isCurrentBlock ? Alignment.topLeft : null,
                                  child: LessonBlockInteractorWidget(
                                    key: _blockInteractorKeys[index],
                                    block: block,
                                    blockIndex: index,
                                    isBlockCompleted: index < _currentBlock,
                                    onStateChanged: () {
                                      // Trigger rebuild when block state changes
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                  ),
                                );
                              }),
                          // Bottom padding so content doesn't get hidden behind floating button
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Floating continue button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildContinueButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final isEnabled = _isContinueButtonEnabled();
    final buttonText = _getContinueButtonText();

    // Get button color from current block interactor
    Color? buttonColor;
    Color? textColor;
    final blockWidget = _blockInteractorKeys[_currentBlock].currentState;
    if (blockWidget != null) {
      final interactorWidget = blockWidget as BlockInteractorInterface;
      if (interactorWidget.ctaColor != null) {
        buttonColor = interactorWidget.ctaColor;
        textColor = Colors.white;
      }
    }

    // Border color using theme colors (adapts to user's theme preference)
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        !isEnabled
            ? (isDarkTheme
                ? Theme.of(context)
                    .colorScheme
                    .surfaceVariant // Grey[800] for dark
                : Colors.grey[400]!) // Darker grey for light
            : (buttonColor != null
                ? Color.lerp(
                  buttonColor,
                  Colors.black,
                  0.3,
                )! // Darker shade of accent color (e.g., green)
                : (isDarkTheme
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.black)); // Full black for light theme

    return AnimatedOpacity(
      opacity: _showContinueButton ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 100),
      child: IgnorePointer(
        ignoring: !_showContinueButton,
        child: Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color:
                  !isEnabled
                      ? Theme.of(context).colorScheme.outline
                      : buttonColor ?? Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
              border: Border(bottom: BorderSide(color: borderColor, width: 4)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap:
                    isEnabled
                        ? (_currentBlock < _blocks.length - 1
                            ? () => _handleContinuePressed()
                            : () => _completeLesson())
                        : null,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color:
                            !isEnabled
                                ? Theme.of(context).disabledColor
                                : textColor ??
                                    Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();

    // Clear image cache to free memory if needed
    if (_blocks.isNotEmpty) {
      _imagePreloader.clearCache();
    }

    super.dispose();
  }
}
