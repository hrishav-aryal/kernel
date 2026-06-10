import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kernel/providers/auth_provider.dart';
import 'package:kernel/providers/course_byte_progress_provider.dart';
import 'package:kernel/providers/course_data_provider.dart';
import 'package:kernel/screens/reader/lesson_reader_screen.dart';
import 'package:kernel/repositories/course_repository.dart';
import 'package:kernel/services/home_service.dart';
import 'package:kernel/models/models.dart';
import 'package:kernel/utils/auth_helper.dart';
import 'package:provider/provider.dart';
import 'widgets/course_header.dart';
import 'widgets/unit_section.dart';
import 'course_switch_screen.dart';
import 'widgets/coin_info_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  bool _isReadyToShow = false;
  final Map<String, GlobalKey> _byteKeys = {};
  final Map<String, GlobalKey> _unitKeys = {};
  bool _showScrollToCurrentFAB = false;
  String? _currentLessonId;
  bool _isCurrentLessonAbove = false;
  double? _savedLessonScrollOffset;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHomeData();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHomeData() async {
    setState(() {
      _isReadyToShow = false;
    });

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.isAuthenticated ? authProvider.user?.id : null;

    final courseDataProvider = context.read<CourseDataProvider>();
    await courseDataProvider.loadCourseData();

    if (userId != null) {
      final courseProgressProvider = context.read<CourseByteProgressProvider>();
      await courseProgressProvider.loadProgressForUser(userId);
    }

    // Scroll to current lesson after layout
    if (userId != null && courseDataProvider.courseData != null && mounted) {
      final courseProgressProvider = context.read<CourseByteProgressProvider>();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final currentByteId = _findCurrentLessonId(
          courseDataProvider.courseData!,
          courseProgressProvider,
          userId,
        );

        if (currentByteId != null) {
          setState(() {
            _currentLessonId = currentByteId;
          });

          // Two-step scroll: First approximate, then precise
          _scrollToLessonTwoStep(currentByteId, courseDataProvider.courseData!);
        } else {
          // No current lesson found, show content immediately
          setState(() {
            _isReadyToShow = true;
          });
        }
      });
    } else {
      // Unauthenticated user - set first lesson (no scrolling needed)
      _currentLessonId =
          courseDataProvider.courseData != null
              ? _getFirstLessonId(courseDataProvider.courseData!)
              : null;
      setState(() {
        _isReadyToShow = true;
      });
    }
  }

  String? _findCurrentLessonId(
    CourseData courseData,
    CourseByteProgressProvider progressProvider,
    String userId,
  ) {
    final allBytes = courseData.getAllBytesOrdered();

    // Find the first incomplete lesson
    for (int i = 0; i < allBytes.length; i++) {
      final progress = progressProvider.getProgress(allBytes[i].id, userId);
      if (progress == null || !progress.isCompleted) {
        return allBytes[i].id;
      }
    }

    // If all lessons completed, return last lesson
    return allBytes.isNotEmpty ? allBytes.last.id : null;
  }

  String? _getFirstLessonId(CourseData courseData) {
    final allBytes = courseData.getAllBytesOrdered();
    return allBytes.isNotEmpty ? allBytes.first.id : null;
  }

  void _ensureByteKeysExist(CourseData courseData) {
    final allBytes = courseData.getAllBytesOrdered();
    for (final byte in allBytes) {
      if (!_byteKeys.containsKey(byte.id)) {
        _byteKeys[byte.id] = GlobalKey();
      }
    }

    for (final unit in courseData.units) {
      if (!_unitKeys.containsKey(unit.id)) {
        _unitKeys[unit.id] = GlobalKey();
      }
    }
  }

  void _onScroll() {
    if (_currentLessonId == null || !_scrollController.hasClients) return;

    final key = _byteKeys[_currentLessonId];
    final isVisible = _isWidgetVisible(key);
    final shouldShowFAB = !isVisible;

    // Determine if lesson is above or below viewport
    bool isAbove = false;

    if (key?.currentContext != null) {
      final RenderBox? renderBox =
          key!.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        // Calculate and save scroll offset using RenderAbstractViewport (only if not already saved)
        if (_savedLessonScrollOffset == null) {
          final viewport = RenderAbstractViewport.of(renderBox);
          final alignment = 0.48;
          final revealedOffset = viewport.getOffsetToReveal(
            renderBox,
            alignment,
          );
          _savedLessonScrollOffset = revealedOffset.offset;
        }

        // Determine direction based on widget position
        final widgetPosition = renderBox.localToGlobal(Offset.zero);
        final mediaQuery = MediaQuery.of(context);
        final safeAreaTop = mediaQuery.padding.top;
        final topNavHeight = 60.0;
        final viewportTop = safeAreaTop + topNavHeight;
        isAbove = widgetPosition.dy < viewportTop;
      }
    } else {
      // Widget is disposed - use saved state for direction
      // If we have a saved offset, compare with current scroll to determine direction
      if (_savedLessonScrollOffset != null && _scrollController.hasClients) {
        final currentOffset = _scrollController.offset;
        isAbove = currentOffset > _savedLessonScrollOffset!;
      } else {
        // No saved state yet, keep current state
        isAbove = _isCurrentLessonAbove;
      }
    }

    if (shouldShowFAB != _showScrollToCurrentFAB ||
        isAbove != _isCurrentLessonAbove) {
      setState(() {
        _showScrollToCurrentFAB = shouldShowFAB;
        _isCurrentLessonAbove = isAbove;
      });
    }
  }

  bool _isWidgetVisible(GlobalKey? key) {
    if (key?.currentContext == null) return false;

    final RenderBox? renderBox =
        key!.currentContext!.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return false;

    final offset = renderBox.localToGlobal(Offset.zero);
    final widgetRect = offset & renderBox.size;

    final screenHeight = MediaQuery.of(context).size.height;
    final viewportRect =
        Offset.zero & Size(MediaQuery.of(context).size.width, screenHeight);

    // Check if widget is at least partially visible in viewport
    return viewportRect.overlaps(widgetRect);
  }

  void _scrollToCurrentLesson() {
    if (_currentLessonId == null) return;

    final courseDataProvider = context.read<CourseDataProvider>();
    if (courseDataProvider.courseData == null) return;

    _scrollToLesson(
      _currentLessonId!,
      courseDataProvider.courseData!,
      forceScroll: true,
    );
  }

  double _calculateApproximateScrollOffset(
    String byteId,
    CourseData courseData,
  ) {
    // Approximate heights (can be tuned)
    const courseHeaderHeight = 200.0;
    const topPadding = 20.0;
    const headerSpacing = 32.0;
    const unitHeaderHeight = 80.0;
    const unitContentPadding = 24.0; // top padding
    const byteItemHeight = 90.0;
    const unitBottomMargin = 32.0;
    const unitSpacing = 48.0; // spacing between units

    double offset = topPadding + courseHeaderHeight + headerSpacing;

    final lessonPosition = _findLessonPositionInUnit(byteId, courseData);
    if (lessonPosition == null) return offset;

    final targetUnitId = lessonPosition['unitId'] as String;
    final targetIndexInUnit = lessonPosition['indexInUnit'] as int;

    // Add heights of all units before target unit
    for (final unit in courseData.units) {
      if (unit.id == targetUnitId) break;

      final unitBytes = courseData.getBytesForUnit(unit.id);
      offset += unitHeaderHeight + unitContentPadding;
      offset += unitBytes.length * byteItemHeight;
      offset += unitBottomMargin + unitSpacing;
    }

    // Add target unit header and bytes before target byte
    offset += unitHeaderHeight + unitContentPadding;
    offset += targetIndexInUnit * byteItemHeight;

    return offset;
  }

  void _scrollToLessonTwoStep(String byteId, CourseData courseData) {
    if (!_scrollController.hasClients) {
      // Scroll controller not ready, show content anyway
      setState(() {
        _isReadyToShow = true;
      });
      return;
    }

    // Check if it's first lesson of first unit - don't scroll, just show content
    final lessonPosition = _findLessonPositionInUnit(byteId, courseData);
    if (lessonPosition != null) {
      final unitId = lessonPosition['unitId'] as String;
      final indexInUnit = lessonPosition['indexInUnit'] as int;
      final isFirstUnitFirstLesson =
          unitId == courseData.units.first.id && indexInUnit == 0;

      if (isFirstUnitFirstLesson) {
        // First lesson is at top, no need to scroll
        setState(() {
          _isReadyToShow = true;
        });
        return;
      }
    }

    // Step 1: Scroll to approximate position (brings widget into viewport)
    final approximateOffset = _calculateApproximateScrollOffset(
      byteId,
      courseData,
    );

    _scrollController
        .animateTo(
          approximateOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) {
          // Step 2: Wait for widget to be built, then precise scroll
          if (!mounted) return;

          _waitForWidgetThenScrollPrecise(byteId, courseData);
        });
  }

  void _waitForWidgetThenScrollPrecise(String byteId, CourseData courseData) {
    // Wait for widget to build after approximate scroll, then do precise scroll
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;

      final byteKey = _byteKeys[byteId];
      if (byteKey?.currentContext != null) {
        // Widget is built! Do precise scroll
        _scrollToLesson(byteId, courseData, forceScroll: true);

        // Wait for precise scroll animation, then show content
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) {
            setState(() {
              _isReadyToShow = true;
            });
          }
        });
      } else {
        // Widget not built yet (shouldn't happen, but fallback)
        setState(() {
          _isReadyToShow = true;
        });
      }
    });
  }

  void _scrollToLesson(
    String byteId,
    CourseData courseData, {
    bool forceScroll = false,
  }) {
    final lessonPosition = _findLessonPositionInUnit(byteId, courseData);
    if (lessonPosition == null) return;

    final unitId = lessonPosition['unitId'] as String;
    final indexInUnit = lessonPosition['indexInUnit'] as int;

    // Exception: First lesson of first unit - don't auto-scroll on load, show course header
    // But DO scroll if user explicitly clicked FAB
    final isFirstUnitFirstLesson =
        unitId == courseData.units.first.id && indexInUnit == 0;
    if (isFirstUnitFirstLesson && !forceScroll) return;

    // Strategy:
    // - First lesson of unit (and not forced): Scroll to unit anchor to show unit header at top
    // - Other lessons or forced scroll: Scroll to byte itself with appropriate alignment

    if (indexInUnit == 0 && !forceScroll) {
      final unitKey = _unitKeys[unitId];
      if (unitKey?.currentContext != null) {
        // Context exists - use ensureVisible
        Scrollable.ensureVisible(
          unitKey!.currentContext!,
          duration: const Duration(milliseconds: 300),
          alignment: 0.0,
          curve: Curves.easeInOut,
        );
      }
      // If context is null, we can't scroll to unit header (rare case)
    } else {
      // Always scroll to the byte itself when forced or not first lesson
      final byteKey = _byteKeys[byteId];

      if (byteKey?.currentContext != null) {
        // Context exists - use ensureVisible
        final double alignment = 0.48;
        Scrollable.ensureVisible(
          byteKey!.currentContext!,
          duration: const Duration(milliseconds: 300),
          alignment: alignment,
          curve: Curves.easeInOut,
        );
      } else if (_savedLessonScrollOffset != null &&
          _scrollController.hasClients) {
        // Context is null (widget disposed) - use saved scroll offset
        _scrollController.animateTo(
          _savedLessonScrollOffset!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Map<String, dynamic>? _findLessonPositionInUnit(
    String byteId,
    CourseData courseData,
  ) {
    for (final unit in courseData.units) {
      final bytes = courseData.getBytesForUnit(unit.id);
      final indexInUnit = bytes.indexWhere((b) => b.id == byteId);

      if (indexInUnit != -1) {
        return {'unitId': unit.id, 'indexInUnit': indexInUnit};
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopNavBar(context),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
      floatingActionButton:
          _showScrollToCurrentFAB
              ? FloatingActionButton(
                onPressed: _scrollToCurrentLesson,
                backgroundColor: Colors.transparent,
                foregroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.5),
                    width: 3,
                  ),
                ),
                child: Icon(
                  _isCurrentLessonAbove
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 30,
                ),
              )
              : null,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Consumer<CourseDataProvider>(
      builder: (context, courseDataProvider, child) {
        if (courseDataProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (courseDataProvider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/icon/error.png', width: 100, height: 100),
                  const SizedBox(height: 24),
                  Text(
                    'Apologies!',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Something went sideways while loading the course. Give it another shot?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border(
                        bottom: BorderSide(
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context).colorScheme.secondary
                                  : Colors.black,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _loadHomeData,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              'Try Again',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (courseDataProvider.courseData == null) {
          return const Center(child: Text('No course available'));
        }

        final courseData = courseDataProvider.courseData!;
        final homeData = HomeData(courseData: courseData);

        _ensureByteKeysExist(courseData);
        final screenHeight = MediaQuery.of(context).size.height;

        return Stack(
          children: [
            Opacity(
              opacity: _isReadyToShow ? 1.0 : 0.0,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Top padding
                  const SliverPadding(padding: EdgeInsets.only(top: 20)),

                  // Course Header
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverToBoxAdapter(
                      child: CourseHeader(courseData: courseData),
                    ),
                  ),

                  // Spacing after header
                  const SliverPadding(padding: EdgeInsets.only(top: 32)),

                  // Unit sections with sticky headers
                  ...courseData.units.asMap().entries.map((entry) {
                    final unitIndex = entry.key;
                    final unit = entry.value;
                    final bytes = courseData.getBytesForUnit(unit.id);
                    return UnitSection(
                      unit: unit,
                      bytes: bytes,
                      unitIndex: unitIndex,
                      homeData: homeData,
                      onBytePressed: _onBytePressed,
                      getGlobalByteIndex: _getGlobalByteIndex,
                      byteKeys: _byteKeys,
                      unitKeys: _unitKeys,
                    );
                  }).toList(),

                  // Spacing before end section
                  const SliverPadding(padding: EdgeInsets.only(top: 48)),

                  // End of Course section
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverToBoxAdapter(
                      child: _buildEndOfCourseSection(context, screenHeight),
                    ),
                  ),
                ],
              ),
            ),
            if (!_isReadyToShow)
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTopNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        // boxShadow: [
        //   BoxShadow(
        //     color: Theme.of(context).shadowColor,
        //     blurRadius: 20,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              CourseSwitchBottomSheet.show(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Image.asset(
                    'assets/images/python.png',
                    fit: BoxFit.cover,
                    height: 24,
                    width: 24,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              CoinInfoBottomSheet.show(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.infinity,
                    size: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 6),
                  Image.asset('assets/icon/coin2.png', width: 24, height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getGlobalByteIndex(int unitIndex, int byteIndex) {
    final courseDataProvider = context.read<CourseDataProvider>();
    if (courseDataProvider.courseData == null) return 0;

    final courseData = courseDataProvider.courseData!;
    int globalIndex = 0;

    for (int i = 0; i < unitIndex; i++) {
      if (i < courseData.units.length) {
        final unitBytes = courseData.getBytesForUnit(courseData.units[i].id);
        globalIndex += unitBytes.length;
      }
    }

    globalIndex += byteIndex;

    return globalIndex;
  }

  Widget _buildEndOfCourseSection(BuildContext context, double screenHeight) {
    return Container(
      height: screenHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icon/goal.png', // Ensure you have such an image asset in your assets/icon directory
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 36),
          Text(
            'End of Course',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Well, that\'s all we\'ve got... for now 👀',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _onBytePressed(CourseByte courseByte) async {
    // Check if user is authenticated
    final authProvider = context.read<AuthProvider>();
    final isAuthenticated =
        authProvider.isAuthenticated && authProvider.user != null;

    if (!isAuthenticated) {
      // Show login screen if not authenticated
      await AuthHelper.showLoginScreen(context);
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonReaderScreen(courseByte: courseByte),
      ),
    );

    // Update current lesson after returning from lesson reader
    if (mounted) {
      _updateCurrentLesson();
    }
  }

  void _updateCurrentLesson() {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.isAuthenticated ? authProvider.user?.id : null;

    if (userId == null) return;

    final courseDataProvider = context.read<CourseDataProvider>();
    if (courseDataProvider.courseData == null) return;

    final courseProgressProvider = context.read<CourseByteProgressProvider>();

    final newCurrentByteId = _findCurrentLessonId(
      courseDataProvider.courseData!,
      courseProgressProvider,
      userId,
    );

    if (newCurrentByteId != null && newCurrentByteId != _currentLessonId) {
      setState(() {
        _currentLessonId = newCurrentByteId;
        _savedLessonScrollOffset = null; // Clear saved offset for new lesson
      });

      // Trigger scroll check to update FAB visibility for new current lesson
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _onScroll();
        }
      });
    }
  }
}

enum ByteStatus { completed, current, locked }
