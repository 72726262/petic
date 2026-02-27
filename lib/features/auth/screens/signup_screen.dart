import 'package:employee_portal/core/animations/app_animations.dart';
import 'package:employee_portal/core/theme/app_radius.dart';
import 'package:employee_portal/core/theme/app_shadows.dart';
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
import 'package:employee_portal/shared/widgets/app_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Role selection
  String _selectedRole = 'user';

  List<Map<String, String>> _getRoles(AppStrings s, bool isAdmin) {
    if (isAdmin) {
      return [
        {'value': 'user', 'label': s.roleUser},
        {'value': 'admin', 'label': s.roleAdmin},
        {'value': 'hr', 'label': s.roleHR},
        {'value': 'it', 'label': s.roleIT},
      ];
    }
    return [
      {'value': 'user', 'label': s.roleUser},
    ];
  }

  // Animation Controllers
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _logoController.dispose();
    _formController.dispose();
    super.dispose();
  }

  void _onSignupPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signUp(
            email: _emailController.text,
            password: _passwordController.text,
            fullName: _nameController.text,
            role: _selectedRole,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = AppStrings.of(context);
    final authState = context.read<AuthCubit>().state;
    final isAdmin = authState is AuthAuthenticated && authState.user.isAdmin;
    final isHR = authState is AuthAuthenticated && authState.user.isHR;
    
    final roles = _getRoles(s, isAdmin);
    
    // Guard: only admin or HR can access this screen
    if (!isAdmin && !isHR) {
      return Scaffold(
        appBar: AppBar(title: Text(s.createAccount)),
        body: Center(
          child: Text('${s.accessDenied}\n${s.adminOnlyPage}'),
        ),
      );
    }
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(s.accountCreatedSuccess),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is AuthError) {
          ErrorHandler.showErrorSnackbar(context, state.message);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background Gradient
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

            // Decorative Circles
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

            // Main Content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Logo + Title
                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoOpacity,
                        child: Column(
                          children: [
                            Container(
                              width: 130,
                              height: 130,
                              child: Image.asset(
                                'assets/images/app_logo_final.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              s.createAccount,
                              style: AppTypography.headlineMedium.copyWith(
                                color:
                                    isDark ? Colors.white : AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              s.createAccountSubtitle,
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

                    const SizedBox(height: 40),

                    // Signup Form
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
                                // Name Field
                                _buildDarkTextField(
                                  context: context,
                                  controller: _nameController,
                                  hint: s.fullName,
                                  icon: Icons.person_outline_rounded,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return s.nameRequired;
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Email Field
                                _buildDarkTextField(
                                  context: context,
                                  controller: _emailController,
                                  hint: s.emailHint,
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: s.validateEmail,
                                ),

                                const SizedBox(height: 16),

                                // Password Field
                                _buildDarkTextField(
                                  context: context,
                                  controller: _passwordController,
                                  hint: s.passwordHint,
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: _obscurePassword,
                                  validator: AppUtils.validatePassword,
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

                                const SizedBox(height: 16),

                                // Confirm Password Field
                                _buildDarkTextField(
                                  context: context,
                                  controller: _confirmPasswordController,
                                  hint: s.confirmPassword,
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: _obscureConfirmPassword,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return s.confirmPasswordRequired;
                                    }
                                    if (value != _passwordController.text) {
                                      return s.passwordsDoNotMatch;
                                    }
                                    return null;
                                  },
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() =>
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword),
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: isDark
                                          ? Colors.white.withOpacity(0.5)
                                          : AppColors.onSurfaceVariantLight,
                                      size: 20,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Role Selection
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.07)
                                        : AppColors.surfaceVariantLight,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.1)
                                          : AppColors.primary.withOpacity(0.15),
                                      width: 1,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedRole,
                                      isExpanded: true,
                                      dropdownColor: isDark
                                          ? const Color(0xFF1A2236)
                                          : AppColors.surfaceLight,
                                      icon: Icon(
                                        Icons.arrow_drop_down_circle_outlined,
                                        color: isDark
                                            ? Colors.white.withOpacity(0.5)
                                            : AppColors.onSurfaceVariantLight,
                                      ),
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.onSurfaceLight,
                                      ),
                                      items: roles.map((role) {
                                        return DropdownMenuItem<String>(
                                          value: role['value'],
                                          child: Row(
                                            children: [
                                              Icon(
                                                _getRoleIcon(role['value']!),
                                                color: isDark
                                                    ? Colors.white
                                                        .withOpacity(0.7)
                                                    : AppColors
                                                        .onSurfaceVariantLight,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                role['label']!,
                                                style: AppTypography.bodyMedium
                                                    .copyWith(
                                                  color: isDark
                                                      ? Colors.white
                                                      : AppColors
                                                          .onSurfaceLight,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            _selectedRole = value;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Signup Button
                                BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, state) {
                                    final isLoading = state is AuthLoading;
                                    return _SignupButton(
                                      isLoading: isLoading,
                                      onPressed: _onSignupPressed,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login Link
                    FadeTransition(
                      opacity: _formOpacity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            s.haveAccount,
                            style: AppTypography.bodyMedium.copyWith(
                              color: isDark
                                  ? Colors.white.withOpacity(0.6)
                                  : AppColors.onSurfaceVariantLight,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push(RouteNames.login),
                            child: Text(
                              s.signIn,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ─── Professional Back Button ──────────────────────────────────
            Positioned(
              top: MediaQuery.paddingOf(context).top + 16,
              right: 20,
              child: FadeSlideUp(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                        ),
                        boxShadow:
                            isDark ? AppShadows.softDark : AppShadows.soft,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: isDark ? Colors.white : AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
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

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings_outlined;
      case 'hr':
        return Icons.people_outline;
      case 'it':
        return Icons.computer_outlined;
      default:
        return Icons.person_outline;
    }
  }
}

/// Signup button with gradient and loading state
class _SignupButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SignupButton({
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
                        s.createAccount,
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
