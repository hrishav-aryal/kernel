import 'package:flutter/material.dart';

class LessonProgressBar extends StatelessWidget {
  final int currentBlock;
  final int totalBlocks;
  final VoidCallback onBackPressed;

  const LessonProgressBar({
    super.key,
    required this.currentBlock,
    required this.totalBlocks,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Extend to top of screen including status bar area
      padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        // boxShadow: [
        //   BoxShadow(
        //     color: Theme.of(context).shadowColor,
        //     blurRadius: 10,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackPressed,
            icon: const Icon(Icons.close, size: 18),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(27),
                    value: (currentBlock + 1) / totalBlocks,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
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
}
