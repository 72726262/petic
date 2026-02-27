import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/features/auth/cubit/auth_cubit.dart';
import 'package:employee_portal/features/auth/cubit/auth_state.dart';
import 'package:employee_portal/features/notifications/cubit/notification_overlay_cubit.dart';
import 'package:employee_portal/features/notifications/models/notification_overlay_model.dart';

/// Wraps any widget tree and shows beautiful real-time notification toasts
/// when new content is published to any table in Supabase.
class NotificationOverlayWrapper extends StatelessWidget {
  final Widget child;
  const NotificationOverlayWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationOverlayCubit(),
      child: _OverlayGate(child: child),
    );
  }
}

class _OverlayGate extends StatefulWidget {
  final Widget child;
  const _OverlayGate({required this.child});

  @override
  State<_OverlayGate> createState() => _OverlayGateState();
}

class _OverlayGateState extends State<_OverlayGate> {
  final _overlayKey = GlobalKey<OverlayState>();
  bool _listening = false;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Start / stop realtime subscription with auth state
        BlocListener<AuthCubit, AuthState>(
          listener: (context, authState) {
            final cubit = context.read<NotificationOverlayCubit>();
            if (authState is AuthAuthenticated && !_listening) {
              cubit.startListening();
              _listening = true;
            } else if (authState is AuthUnauthenticated && _listening) {
              _listening = false;
            }
          },
        ),
        // Show toast when a notification arrives
        BlocListener<NotificationOverlayCubit, NotificationOverlayState>(
          listener: (context, state) {
            if (state is NotificationOverlayReceived) {
              _showToast(state.notification);
            }
          },
        ),
      ],
      child: Overlay(
        key: _overlayKey,
        initialEntries: [
          OverlayEntry(builder: (_) => widget.child),
        ],
      ),
    );
  }

  void _showToast(NotificationOverlayModel notif) {
    final overlayState = _overlayKey.currentState;
    if (overlayState == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _InAppToast(
        notification: notif,
        onDismiss: () => entry.remove(),
        onTap: () {
          entry.remove();
          if (notif.navigateTo != null) {
            // Use the GoRouter's context from the outer widget
            GoRouter.of(context).push(notif.navigateTo!);
          }
        },
      ),
    );

    overlayState.insert(entry);
  }
}


// ─── The actual toast widget ─────────────────────────────────────────────────

class _InAppToast extends StatefulWidget {
  final NotificationOverlayModel notification;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _InAppToast({
    required this.notification,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  State<_InAppToast> createState() => _InAppToastState();
}

class _InAppToastState extends State<_InAppToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.4)),
    );

    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );

    _ctrl.forward();

    // Auto dismiss after 4.5 seconds
    Future.delayed(const Duration(milliseconds: 4500), _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    if (_ctrl.status == AnimationStatus.reverse ||
        _ctrl.status == AnimationStatus.dismissed) return;
    await _ctrl.reverse();
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notification;
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Positioned(
      top: MediaQuery.of(context).viewPadding.top + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: GestureDetector(
              onTap: widget.onTap,
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity!.abs() > 300) {
                  _dismiss();
                }
              },
              child: _ToastCard(notification: n, isDark: isDark),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastCard extends StatelessWidget {
  final NotificationOverlayModel notification;
  final bool isDark;

  const _ToastCard({required this.notification, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final n = notification;

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: n.color.withOpacity(0.25),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.45 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background blur card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A2236).withOpacity(0.97)
                    : Colors.white.withOpacity(0.98),
                border: Border.all(
                  color: n.color.withOpacity(0.25),
                  width: 1.2,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gradient icon bubble
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: n.gradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: n.color.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(n.icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          n.title,
                          style: AppTypography.titleSmall.copyWith(
                            color: isDark
                                ? AppColors.onSurfaceDark
                                : AppColors.onSurfaceLight,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          n.body,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.onSurfaceVariantDark
                                : AppColors.onSurfaceVariantLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Arrow hint
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: n.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 14,
                      color: n.color,
                    ),
                  ),
                ],
              ),
            ),
            // Colored left accent bar
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: n.gradient,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
            ),
            // Subtle shimmer overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      n.color.withOpacity(isDark ? 0.04 : 0.02),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
