import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/app_theme.dart';

class MicButton extends StatelessWidget {
  final bool isTranslating;
  final VoidCallback onPressed;

  const MicButton({
    super.key,
    required this.isTranslating,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isTranslating ? AppTheme.primaryColor : const Color(0xFFCBD5E1),
          boxShadow: [
            BoxShadow(
              color: isTranslating
                  ? AppTheme.primaryColor.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ripple animation for active state
            if (isTranslating)
              const _RippleAnimation(
                color: AppTheme.primaryColor,
                size: 130,
              ),
            
            // Mic icon
            Icon(
              FontAwesomeIcons.microphone,
              size: 56,
              color: isTranslating ? Colors.white : const Color(0xFF475569),
            ),
          ],
        ),
      ),
    );
  }
}

class _RippleAnimation extends StatefulWidget {
  final Color color;
  final double size;

  const _RippleAnimation({
    required this.color,
    required this.size,
  });

  @override
  State<_RippleAnimation> createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<_RippleAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: (1.5 - _animation.value) * 0.5,
          child: Container(
            width: widget.size * _animation.value,
            height: widget.size * _animation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}