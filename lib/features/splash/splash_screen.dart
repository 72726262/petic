import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:employee_portal/core/router/route_names.dart';
import 'package:employee_portal/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ──────────────────────────────────────────────── Animation Controllers
  late final AnimationController _logoController;
  late final AnimationController _shimmerController;
  late final AnimationController _particleController;
  late final AnimationController _pulseController;

  // ──────────────────────────────────────────────── Animations
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoBounce;
  late final Animation<double> _nameOpacity;
  late final Animation<Offset> _nameSlide;
  late final Animation<double> _subtitleOpacity;
  late final Animation<double> _shimmer;
  late final Animation<double> _particle;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    // Logo entrance: 0→1200 ms
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Shimmer sweep over the name: loops
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Orbit particles: loops
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Glow pulse on logo: loops
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // ── Logo ──
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.12)
              .chain(CurveTween(curve: Curves.easeOutBack)),
          weight: 70),
      TweenSequenceItem(
          tween: Tween(begin: 1.12, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 30),
    ]).animate(_logoController);

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: const Interval(0.0, 0.5, curve: Curves.easeIn)))
        .animate(_logoController);

    _logoBounce = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // ── Name label ──
    _nameOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: const Interval(0.6, 1.0, curve: Curves.easeIn)))
        .animate(_logoController);

    _nameSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .chain(CurveTween(curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic)))
        .animate(_logoController);

    // ── Subtitle ──
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: const Interval(0.8, 1.0, curve: Curves.easeIn)))
        .animate(_logoController);

    _shimmer = Tween<double>(begin: -2.0, end: 3.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _particle = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ── Start sequence ──
    _logoController.forward().then((_) {
      _shimmerController.repeat();
      _particleController.repeat();
      _pulseController.repeat(reverse: true);
    });

    // ── Navigate after 3 seconds ──
    Future.delayed(const Duration(milliseconds: 3100), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final session = Supabase.instance.client.auth.currentSession;
    context.go(session != null ? RouteNames.home : RouteNames.login);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _shimmerController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B0E1A),
              Color(0xFF101428),
              Color(0xFF1A2040),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Glowing blobs ──
            Positioned(
              top: -80,
              left: -60,
              child: _GlowBlob(color: AppColors.primary.withOpacity(0.25), size: 280),
            ),
            Positioned(
              bottom: -60,
              right: -40,
              child: _GlowBlob(color: const Color(0xFFF97316).withOpacity(0.18), size: 220),
            ),

            // ── Orbiting particles ──
            AnimatedBuilder(
              animation: _particle,
              builder: (_, __) => CustomPaint(
                size: const Size(260, 260),
                painter: _ParticlePainter(_particle.value),
              ),
            ),

            // ── Main content ──
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                AnimatedBuilder(
                  animation: Listenable.merge([_logoController, _pulseController]),
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _logoBounce.value),
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoOpacity,
                        child: ScaleTransition(
                          scale: _pulse,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.5),
                                  blurRadius: 40,
                                  spreadRadius: 8,
                                ),
                                BoxShadow(
                                  color: const Color(0xFFF97316).withOpacity(0.25),
                                  blurRadius: 60,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                'assets/images/app_logo.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // App name with shimmer
                SlideTransition(
                  position: _nameSlide,
                  child: FadeTransition(
                    opacity: _nameOpacity,
                    child: AnimatedBuilder(
                      animation: _shimmer,
                      builder: (_, child) => ShaderMask(
                        shaderCallback: (rect) => LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: const [
                            Colors.white,
                            Colors.white,
                            Color(0xFFABCDFF),
                            Colors.white,
                            Colors.white,
                          ],
                          stops: [
                            0.0,
                            (_shimmer.value - 0.3).clamp(0.0, 1.0),
                            _shimmer.value.clamp(0.0, 1.0),
                            (_shimmer.value + 0.3).clamp(0.0, 1.0),
                            1.0,
                          ],
                        ).createShader(rect),
                        child: child,
                      ),
                      child: const Text(
                        'Petic',
                        style: TextStyle(
                          fontSize: 46,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 3.0,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Tagline
                FadeTransition(
                  opacity: _subtitleOpacity,
                  child: Text(
                    'Your Smart Workplace',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.45),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),

            // ── Loading dots at bottom ──
            Positioned(
              bottom: 60,
              child: FadeTransition(
                opacity: _subtitleOpacity,
                child: _PulsingDots(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// GLOW BLOB
// ════════════════════════════════════════════════════════════════════
class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.2, 1.0],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// ORBITING PARTICLE PAINTER
// ════════════════════════════════════════════════════════════════════
class _ParticlePainter extends CustomPainter {
  final double progress;
  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final particles = [
      _ParticleConfig(radius: 110, size: 4, speed: 1.0, color: AppColors.primary.withOpacity(0.7)),
      _ParticleConfig(radius: 130, size: 2.5, speed: -0.6, color: const Color(0xFFF97316).withOpacity(0.5)),
      _ParticleConfig(radius: 95, size: 3, speed: 0.4, color: Colors.white.withOpacity(0.4)),
      _ParticleConfig(radius: 145, size: 2, speed: -0.9, color: AppColors.primaryLight.withOpacity(0.5)),
      _ParticleConfig(radius: 75, size: 2, speed: 1.3, color: const Color(0xFF8B5CF6).withOpacity(0.4)),
    ];

    for (var p in particles) {
      final angle = 2 * math.pi * progress * p.speed;
      final x = center.dx + p.radius * math.cos(angle);
      final y = center.dy + p.radius * math.sin(angle);
      canvas.drawCircle(
        Offset(x, y),
        p.size,
        Paint()
          ..color = p.color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _ParticleConfig {
  final double radius;
  final double size;
  final double speed;
  final Color color;
  const _ParticleConfig({
    required this.radius,
    required this.size,
    required this.speed,
    required this.color,
  });
}

// ════════════════════════════════════════════════════════════════════
// PULSING DOTS LOADER
// ════════════════════════════════════════════════════════════════════
class _PulsingDots extends StatefulWidget {
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3.0;
            final val = ((_c.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale = 0.6 + 0.4 * math.sin(val * math.pi);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.4 + 0.5 * scale),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
