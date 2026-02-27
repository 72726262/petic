import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_spacing.dart';
import 'package:employee_portal/core/router/route_names.dart';
import 'package:employee_portal/core/error_handling/error_handler.dart';
import 'package:employee_portal/core/utils/app_utils.dart';
import 'package:employee_portal/core/utils/app_strings.dart';
import 'package:employee_portal/features/auth/cubit/auth_cubit.dart';
import 'package:employee_portal/features/auth/cubit/auth_state.dart';
import 'package:employee_portal/shared/widgets/app_button.dart';
import 'package:employee_portal/shared/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // ─── Animation Controllers ────────────────────────────────────────
  late AnimationController _logoController;
  late AnimationController _formController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _formSlide;
  late Animation<double> _formOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0, 0.6)),
    );
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));
    _formOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeIn),
    );
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _formController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _logoController.dispose();
    _formController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = AppStrings.of(context);
    final isAr = s.isAr;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(RouteNames.home);
        } else if (state is AuthError) {
          ErrorHandler.showErrorSnackbar(context, state.message);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // ─── Background Gradient ──────────────────────────────────
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? const [
                            Color(0xFF0F1623),
                            Color(0xFF1A2236),
                            Color(0xFF1E3A5F),
                          ]
                        : [
                            const Color(0xFFEEF4FF),
                            AppColors.primaryLight.withOpacity(0.2),
                            const Color(0xFFDCEAFF),
                          ],
                  ),
                ),
              ),
            ),

            // ─── Decorative Circles ───────────────────────────────────
            Positioned(
              top: -80,
              left: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.12),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withOpacity(0.10),
                ),
              ),
            ),
            Positioned(
              top: 200,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withOpacity(0.08),
                ),
              ),
            ),

            // ─── Main Content ─────────────────────────────────────────
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // ─── Logo + Title ─────────────────────────────────
                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoOpacity,
                        child: Column(
                          children: [
                            // App Icon
                            Container(
                              width: 150,
                              height: 150,
                              child: Image.asset(
                                'assets/images/app_logo_final.png',
                                fit: BoxFit.contain,
                              ),
                            ),

                            const SizedBox(height: 20),
                            Text(
                              s.appName,
                              style: AppTypography.headlineMedium.copyWith(
                                color:
                                    isDark ? Colors.white : AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              s.appSubtitle,
                              style: AppTypography.bodyMedium.copyWith(
                                color: isDark
                                    ? Colors.white.withOpacity(0.6)
                                    : AppColors.primary.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // ─── Login Form ────────────────────────────────────
                    SlideTransition(
                      position: _formSlide,
                      child: FadeTransition(
                        opacity: _formOpacity,
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.04)
                                : Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : AppColors.primary.withOpacity(0.12),
                              width: 1,
                            ),
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Welcome text
                                Text(
                                  '${AppUtils.getGreeting(isAr: isAr)} 👋',
                                  style: AppTypography.headlineSmall.copyWith(
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.onSurfaceLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  s.loginSubtitle,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.55)
                                        : AppColors.onSurfaceVariantLight,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // ─── Email Field ───────────────────────
                                _buildDarkTextField(
                                  context: context,
                                  controller: _emailController,
                                  hint: s.emailHint,
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: s.validateEmail,
                                ),

                                const SizedBox(height: 16),

                                // ─── Password Field ────────────────────
                                _buildDarkTextField(
                                  context: context,
                                  controller: _passwordController,
                                  hint: s.passwordHint,
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: _obscurePassword,
                                  validator: s.validatePassword,
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: isDark
                                          ? Colors.white.withOpacity(0.5)
                                          : AppColors.onSurfaceVariantLight,
                                      size: 20,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // ─── Login Button ──────────────────────
                                BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, state) {
                                    final isLoading = state is AuthLoading;
                                    return _LoginButton(
                                      isLoading: isLoading,
                                      onPressed: _onLoginPressed,
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),

                                // ─── Forgot Password ─────────────────────
                                Center(
                                  child: GestureDetector(
                                    onTap: () =>
                                        context.push(RouteNames.forgotPassword),
                                    child: Text(
                                      s.forgotPassword,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.primaryLight,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ─── Footer ────────────────────────────────────────
                    FadeTransition(
                      opacity: _formOpacity,
                      child: Text(
                        s.copyright,
                        style: AppTypography.labelSmall.copyWith(
                          color: isDark
                              ? Colors.white.withOpacity(0.3)
                              : AppColors.onSurfaceVariantLight
                                  .withOpacity(0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final hintColor = isDark
        ? Colors.white.withOpacity(0.4)
        : AppColors.onSurfaceVariantLight.withOpacity(0.6);
    final iconColor = isDark
        ? Colors.white.withOpacity(0.5)
        : AppColors.onSurfaceVariantLight;
    final fillColor =
        isDark ? Colors.white.withOpacity(0.07) : AppColors.surfaceVariantLight;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : AppColors.primary.withOpacity(0.15);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: AppTypography.bodyMedium.copyWith(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyMedium.copyWith(color: hintColor),
        prefixIcon: Icon(icon, color: iconColor, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        errorStyle: AppTypography.labelSmall.copyWith(color: AppColors.error),
      ),
    );
  }
}

/// Login button with gradient and loading state
class _LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _LoginButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: isLoading ? null : AppColors.primaryGradient,
          color: isLoading ? Colors.white.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Builder(builder: (ctx) {
                      final s = AppStrings.of(ctx);
                      return Text(
                        s.login,
                        style: AppTypography.buttonText.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
