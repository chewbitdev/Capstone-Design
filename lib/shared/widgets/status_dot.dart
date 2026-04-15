import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum StatusLevel { normal, warning, danger, offline }

class StatusDot extends StatefulWidget {
  const StatusDot({super.key, required this.status, this.size = 12});

  final StatusLevel status;
  final double size;

  @override
  State<StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<StatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.status == StatusLevel.danger) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _color => switch (widget.status) {
        StatusLevel.normal => AppColors.statusNormal,
        StatusLevel.warning => AppColors.statusWarning,
        StatusLevel.danger => AppColors.statusDanger,
        StatusLevel.offline => AppColors.statusOffline,
      };

  @override
  Widget build(BuildContext context) {
    if (widget.status == StatusLevel.danger) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => _dot(_animation.value),
      );
    }
    return _dot(1.0);
  }

  Widget _dot(double opacity) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _color.withValues(alpha: opacity),
          shape: BoxShape.circle,
          boxShadow: widget.status == StatusLevel.danger
              ? [BoxShadow(color: _color.withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 2)]
              : null,
        ),
      );
}
