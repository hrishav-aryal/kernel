import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import '../../models/models.dart';
import '../../config/supabase_config.dart';
import '../../services/image_preloader_service.dart';
import 'block_interactor.dart';
import 'content_interactor.dart';
import 'mcq_interactor_widget.dart';
import 'code_fill_interactor_widget.dart';
import 'utils.dart';
import 'code_output_widget.dart';

/// Interface for block widgets that use interactors
abstract class BlockInteractorInterface {
  bool get isCompleted;
  bool get canProceed;
  bool get canInteract;
  String get ctaText;
  Color? get ctaColor;
  void handleCTAPressed();
  bool validateAllMCQs();
  bool hasAllMCQsSelected();
}

/// New block widget that uses the interactor pattern
/// Maintains identical functionality to the original LessonBlockWidget
class LessonBlockInteractorWidget extends StatefulWidget {
  final Block block;
  final int blockIndex;
  final bool isBlockCompleted;
  final VoidCallback? onStateChanged;

  const LessonBlockInteractorWidget({
    super.key,
    required this.block,
    required this.blockIndex,
    this.isBlockCompleted = false,
    this.onStateChanged,
  });

  @override
  State<LessonBlockInteractorWidget> createState() =>
      _LessonBlockInteractorWidgetState();
}

class _LessonBlockInteractorWidgetState
    extends State<LessonBlockInteractorWidget>
    implements BlockInteractorInterface {
  late BlockInteractor _blockInteractor;
  final Map<int, GlobalKey> _mcqWidgetKeys = {};
  final Map<int, GlobalKey> _codeFillWidgetKeys = {};
  final Set<int> _codeOutputVisible = {}; // Track which code blocks show output

  @override
  void initState() {
    super.initState();
    _blockInteractor = BlockInteractor(
      block: widget.block,
      blockIndex: widget.blockIndex,
      isBlockCompleted: widget.isBlockCompleted,
    );

    _blockInteractor.setStateChangeCallback(() {
      if (mounted) {
        setState(() {});
        widget.onStateChanged?.call();
      }
    });

    // Initialize widget keys for interactive elements
    for (int i = 0; i < widget.block.elements.length; i++) {
      final elementType = widget.block.elements[i].type;
      if (elementType == ContentElementType.mcq) {
        _mcqWidgetKeys[i] = GlobalKey();
      } else if (elementType == ContentElementType.code_fill) {
        _codeFillWidgetKeys[i] = GlobalKey();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            widget.block.elements
                .asMap()
                .entries
                .map(
                  (entry) =>
                      _buildContentElement(context, entry.value, entry.key),
                )
                .toList(),
      ),
    );
  }

  Widget _buildContentElement(
    BuildContext context,
    ContentElement element,
    int elementIndex,
  ) {
    switch (element.type) {
      case ContentElementType.heading:
        return _buildHeadingElement(context, element);
      case ContentElementType.text:
        return _buildTextElement(context, element);
      case ContentElementType.image:
        return _buildImageElement(context, element);
      case ContentElementType.code:
        return _buildCodeElement(context, element, elementIndex);
      case ContentElementType.list:
        return _buildListElement(context, element);
      case ContentElementType.spacer:
        return _buildSpacerElement(element);
      case ContentElementType.mcq:
        return _buildMCQElement(context, element, elementIndex);
      case ContentElementType.code_fill:
        return _buildCodeFillElement(context, element, elementIndex);
    }
  }

  Widget _buildMCQElement(
    BuildContext context,
    ContentElement element,
    int elementIndex,
  ) {
    final interactor =
        _blockInteractor.getElementInteractor(elementIndex) as MCQInteractor?;
    if (interactor == null) return const SizedBox.shrink();

    final key = _mcqWidgetKeys[elementIndex]!;
    interactor.setWidgetKey(key);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: MCQInteractorWidget(
        key: key,
        element: element,
        interactor: interactor,
        isBlockCompleted: widget.isBlockCompleted,
      ),
    );
  }

  Widget _buildCodeFillElement(
    BuildContext context,
    ContentElement element,
    int elementIndex,
  ) {
    final interactor =
        _blockInteractor.getElementInteractor(elementIndex)
            as CodeFillInteractor?;
    if (interactor == null) return const SizedBox.shrink();

    final key = _codeFillWidgetKeys[elementIndex]!;
    interactor.setWidgetKey(key);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CodeFillInteractorWidget(
        key: key,
        element: element,
        interactor: interactor,
        isBlockCompleted: widget.isBlockCompleted,
      ),
    );
  }

  // All the existing content element builders remain the same
  Widget _buildHeadingElement(BuildContext context, ContentElement element) {
    final level = element.headingLevel ?? 1;
    final (fontSize, fontWeight) = switch (level) {
      1 => (26.0, FontWeight.w900),
      2 => (20.0, FontWeight.w700),
      3 => (18.0, FontWeight.w600),
      4 => (16.0, FontWeight.w600),
      5 => (14.0, FontWeight.w500),
      _ => (12.0, FontWeight.w400),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 8),
      child: buildRichText(
        element.content,
        Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        context,
      ),
    );
  }

  Widget _buildTextElement(BuildContext context, ContentElement element) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: buildRichText(
        element.content,
        Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
        context,
      ),
    );
  }

  Widget _buildImageElement(BuildContext context, ContentElement element) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: _buildImage(context, element),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeElement(
    BuildContext context,
    ContentElement element,
    int elementIndex,
  ) {
    final language = element.language ?? 'python';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final hasOutput = element.output != null && element.output!.isNotEmpty;
    final showOutput = _codeOutputVisible.contains(elementIndex);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Theme.of(context).colorScheme.surface.withOpacity(0.5)
                      : Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Code header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.3),
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
                      // Play/Hide icon (only show if output exists)
                      if (hasOutput)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (showOutput) {
                                _codeOutputVisible.remove(elementIndex);
                              } else {
                                _codeOutputVisible.add(elementIndex);
                              }
                            });
                          },
                          child: Icon(
                            showOutput
                                ? Icons.visibility_off
                                : Icons.play_arrow,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),

                // Code content
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
                      child: HighlightView(
                        element.content,
                        language: language,
                        theme:
                            isDarkMode ? atomOneDarkTheme : atomOneLightTheme,
                        padding: EdgeInsets.zero,
                        textStyle: GoogleFonts.sourceCodePro(
                          fontSize: 13,
                          height: 1.4,
                          letterSpacing: -0.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Caption
          if (element.caption != null && element.caption!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              element.caption!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 8),

          // Output widget
          if (hasOutput && showOutput)
            CodeOutputWidget(output: element.output!, show: true),
        ],
      ),
    );
  }

  Widget _buildListElement(BuildContext context, ContentElement element) {
    final items = element.items ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (element.content.isNotEmpty) ...[
            buildRichText(
              element.content,
              Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
              context,
            ),
            const SizedBox(height: 12),
          ],
          ...List.generate(
            items.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    // width: 12,
                    margin: const EdgeInsets.only(right: 12, top: 2),
                    child: Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: buildRichText(
                      items[index],
                      Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.4,
                      ),
                      context,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpacerElement(ContentElement element) {
    final height = element.spacerHeight ?? 20.0;
    return SizedBox(height: height);
  }

  Widget _buildImage(BuildContext context, ContentElement element) {
    if (element.imageUrl == null || element.imageUrl!.isEmpty) {
      return _buildImagePlaceholder(context);
    }

    final imageUrl = SupabaseConfig.getContentUrl(element.imageUrl!);
    final imagePreloader = ImagePreloaderService();
    final isPreloaded = imagePreloader.isImagePreloaded(imageUrl);
    final isFailed = imagePreloader.isImageFailed(imageUrl);
    final imageProvider = imagePreloader.getImageProvider(imageUrl);

    if (isFailed) {
      debugPrint('Image failed to preload: $imageUrl');
      return _buildImageError(context);
    }

    if (!isPreloaded || imageProvider == null) {
      debugPrint('Image not preloaded, falling back to direct load: $imageUrl');
      return _buildImageError(context);
    }

    Widget imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image(
        image: imageProvider,
        width: double.infinity,
        fit: BoxFit.fitWidth,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error displaying preloaded image: $error');
          return _buildImageError(context);
        },
      ),
    );

    if (element.aspectRatio != null) {
      imageWidget = AspectRatio(
        aspectRatio: element.aspectRatio!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 40,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }

  Widget _buildImageError(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: 40,
              color: Theme.of(context).iconTheme.color,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load image',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Public interface methods for compatibility with existing code
  bool validateAllMCQs() {
    return _blockInteractor.validateAllMCQs();
  }

  bool hasAllMCQsSelected() {
    return _blockInteractor.hasAllMCQsSelected();
  }

  bool get isCompleted => _blockInteractor.isCompleted;
  bool get canProceed => _blockInteractor.canProceed;
  bool get canInteract => _blockInteractor.canInteract;
  String get ctaText => _blockInteractor.ctaText;
  Color? get ctaColor => _blockInteractor.ctaColor;

  void handleCTAPressed() {
    _blockInteractor.handleCTAPressed();
  }

  @override
  void dispose() {
    _blockInteractor.dispose();
    super.dispose();
  }
}
