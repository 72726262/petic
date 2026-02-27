import 'package:flutter/material.dart';

/// Page transition animations for GoRouter
class AppPageTransitions {
  AppPageTransitions._();

  // ─── Fade Transition ──────────────────────────────────────────────
  static Widget fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: child,
    );
  }

  // ─── Slide From Right ─────────────────────────────────────────────
  static Widget slideFromRight(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    final tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: Curves.easeInOutCubic),
    );
    return SlideTransition(position: animation.drive(tween), child: child);
  }

  // ─── Slide From Bottom ────────────────────────────────────────────
  static Widget slideFromBottom(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    final tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: Curves.easeInOutCubic),
    );
    return SlideTransition(position: animation.drive(tween), child: child);
  }

  // ─── Fade + Slide Up ──────────────────────────────────────────────
  static Widget fadeSlideUp(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const slideBegin = Offset(0.0, 0.05);
    const slideEnd = Offset.zero;
    final slideTween = Tween(begin: slideBegin, end: slideEnd)
        .chain(CurveTween(curve: Curves.easeOutCubic));
    final fadeTween =
        Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn));
    return FadeTransition(
      opacity: animation.drive(fadeTween),
      child: SlideTransition(
        position: animation.drive(slideTween),
        child: child,
      ),
    );
  }

  // ─── Scale + Fade ─────────────────────────────────────────────────
  static Widget scaleFade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final scaleTween = Tween<double>(begin: 0.92, end: 1.0)
        .chain(CurveTween(curve: Curves.easeOutCubic));
    final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeIn));
    return FadeTransition(
      opacity: animation.drive(fadeTween),
      child: ScaleTransition(
        scale: animation.drive(scaleTween),
        child: child,
      ),
    );
  }
}

/// Staggered list item animation wrapper
class StaggeredListItem extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration initialDelay;

  const StaggeredListItem({
    super.key,
    required this.index,
    required this.child,
    this.initialDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Animated press effect wrapper
class PressEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;

  const PressEffect({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.96,
  });

  @override
  State<PressEffect> createState() => _PressEffectState();
}

class _PressEffectState extends State<PressEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale =
        Tween<double>(begin: 1.0, end: widget.scaleDown).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

/// Fade-in animation wrapper
class FadeInWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const FadeInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + delay,
      curve: Interval(
        delay.inMilliseconds / (duration + delay).inMilliseconds,
        1.0,
        curve: Curves.easeOut,
      ),
      builder: (_, value, child) => Opacity(opacity: value, child: child),
      child: child,
    );
  }
}

/// Fade + slide up animation wrapper (commonly used in content sections)
class FadeSlideUp extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double slideOffset;

  const FadeSlideUp({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.slideOffset = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, slideOffset * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

