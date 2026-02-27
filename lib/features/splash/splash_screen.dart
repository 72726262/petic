import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:employee_portal/core/router/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Initial pop and slight overshoot
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeInOutSine)), weight: 40),
    ]).animate(_controller);

    // 3D Flip rotation
    _rotationAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: math.pi / 2, end: -0.1).chain(CurveTween(curve: Curves.easeOutBack)), weight: 70),
      TweenSequenceItem(tween: Tween<double>(begin: -0.1, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
    ]).animate(_controller);

    // Dynamic shadow corresponding to scale/depth
    _shadowAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 40.0).chain(CurveTween(curve: Curves.easeOut)), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 40.0, end: 20.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 40),
    ]).animate(_controller);

    _controller.forward();

    // ── Navigate after 3 seconds ──
    Future.delayed(const Duration(milliseconds: 3000), _navigate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // This ensures the animation plays instantly whenever you save the file (Hot Reload)
  @override
  void reassemble() {
    super.reassemble();
    _controller.forward(from: 0.0);
  }

  void _navigate() {
    if (!mounted) return;
    final session = Supabase.instance.client.auth.currentSession;
    context.go(session != null ? RouteNames.home : RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Minimalist background with just the logo doing 3D magic
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform(
              alignment: FractionalOffset.center,
              // Apply perspective and 3D rotation around Y and X axis dynamically
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015) // perspective magic
                // Add a slight tilt on X axis based on the rotation value as well to make it wobble
                ..rotateX(_rotationAnimation.value * 0.3)
                ..rotateY(_rotationAnimation.value)
                ..scale(_scaleAnimation.value),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: _shadowAnimation.value,
                      spreadRadius: _shadowAnimation.value * 0.2,
                      offset: Offset(0, _shadowAnimation.value * 0.5),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: _shadowAnimation.value * 0.5,
                      spreadRadius: -5,
                      offset: Offset(0, -(_shadowAnimation.value * 0.2)),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/app_logo_final.png',
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
