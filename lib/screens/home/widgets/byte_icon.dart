import 'package:flutter/material.dart';
import '../home_screen.dart';

class ByteIcon extends StatelessWidget {
  final ByteStatus status;
  final Color unitColor;

  const ByteIcon({super.key, required this.status, required this.unitColor});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ByteStatus.completed:
        return Container(
          width: 64,
          height: 60,
          decoration: BoxDecoration(
            color: unitColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border(
              bottom: BorderSide(color: unitColor, width: 6),
              top: BorderSide(color: unitColor, width: 0.8),
              left: BorderSide(color: unitColor, width: 1),
              right: BorderSide(color: unitColor, width: 1),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [Icon(Icons.check, color: unitColor, size: 28)],
          ),
        );

      case ByteStatus.current:
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 64,
              height: 60,
              decoration: BoxDecoration(
                // color: unitColor.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border(
                  bottom: BorderSide(color: unitColor, width: 6),
                  top: BorderSide(color: unitColor, width: 0.8),
                  left: BorderSide(color: unitColor, width: 1),
                  right: BorderSide(color: unitColor, width: 1),
                ),
              ),
            ),
            _AnimatedPlayButton(unitColor: unitColor),
          ],
        );

      case ByteStatus.locked:
        final borderColor = Theme.of(context).colorScheme.outline;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 64,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 6),
                  top: BorderSide(color: borderColor, width: 0.8),
                  left: BorderSide(color: borderColor, width: 1),
                  right: BorderSide(color: borderColor, width: 1),
                ),
              ),
            ),
            Icon(
              Icons.lock,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              size: 24,
            ),
          ],
        );
    }
  }
}

class _AnimatedPlayButton extends StatefulWidget {
  final Color unitColor;

  const _AnimatedPlayButton({required this.unitColor});

  @override
  State<_AnimatedPlayButton> createState() => _AnimatedPlayButtonState();
}

class _AnimatedPlayButtonState extends State<_AnimatedPlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.5, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Icon(Icons.play_arrow, color: widget.unitColor, size: 24),
        );
      },
    );
  }
}
