import 'package:flutter/material.dart';

class RotatingLogoLoader extends StatefulWidget {
  final double size;
  final String? logoPath;
  final double borderRadius;

  const RotatingLogoLoader({
    super.key,
    this.size = 60,
    this.logoPath,
    this.borderRadius = 16,
  });

  @override
  State<RotatingLogoLoader> createState() => _RotatingLogoLoaderState();
}

class _RotatingLogoLoaderState extends State<RotatingLogoLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Smooth easing animation
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Image.asset(
            widget.logoPath ?? 'assets/logoDashboard.png',
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
