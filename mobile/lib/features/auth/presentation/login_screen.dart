import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:eazzio_school/core/config/app_config.dart';
import '../models/auth_user.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _loginIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutQuad));
    _animController.forward();
  }

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref.read(authNotifierProvider.notifier).login(
          loginId: _loginIdController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  void _showApiSettingsDialog() {
    final controller = TextEditingController(text: AppConfig.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'API Server Settings',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set backend base URL (e.g. http://100.124.111.44:5000/api):',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Base URL',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF008080),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              AppConfig.setBaseUrl(controller.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('API URL updated: ${AppConfig.baseUrl}')),
              );
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isTeacher = authState.selectedPortal == UserRole.teacher;

    final theme = isTeacher
        ? const _RoleVisual(
            portalTag: 'Teacher Portal',
            welcomeTitle: 'Welcome, Teacher!',
            welcomeSubtitle: 'Sign in to manage classes and students',
            accentColor: Color(0xFF008080),
            bgColor: Color(0xFFE6F5F5),
            icon: Icons.groups_rounded,
          )
        : const _RoleVisual(
            portalTag: 'Student Portal',
            welcomeTitle: 'Welcome Back!',
            welcomeSubtitle: 'Sign in to access your classes and grades',
            accentColor: Color(0xFF2563EB),
            bgColor: Color(0xFFEFF6FF),
            icon: Icons.school_rounded,
          );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Header Bar: Back button, Logo, and Settings button
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.bgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.accentColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: theme.accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _showApiSettingsDialog,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.settings_outlined,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Login Form Card with Slide & Fade Animation
                  SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFE4E4EC),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 24,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Portal Badge Tag
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.bgColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(theme.icon,
                                        size: 13, color: theme.accentColor),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        theme.portalTag,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: theme.accentColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Welcome Title & Subtitle
                              Text(
                                theme.welcomeTitle,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF000000),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                theme.welcomeSubtitle,
                                style: GoogleFonts.inter(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 22),

                              // Error Alert if any
                              if (authState.errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE5484D).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.error_outline,
                                          size: 18, color: Color(0xFFE5484D)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          authState.errorMessage!,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: const Color(0xFFE5484D),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Identifier Field
                              Text(
                                isTeacher ? 'Email Address' : 'Student ID',
                                style: GoogleFonts.inter(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _loginIdController,
                                keyboardType: isTeacher
                                    ? TextInputType.emailAddress
                                    : TextInputType.text,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: isTeacher
                                      ? 'name@school.com'
                                      : 'e.g. STU001 or SCH001-ST0001',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.black.withValues(alpha: 0.4),
                                  ),
                                  prefixIcon: Icon(
                                    isTeacher
                                        ? Icons.mail_outline_rounded
                                        : Icons.badge_outlined,
                                    color: Colors.black.withValues(alpha: 0.4),
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE4E4EC), width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE4E4EC), width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF008080), width: 2),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return isTeacher
                                        ? 'Please enter your email'
                                        : 'Please enter your Student ID';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password Field
                              Text(
                                'Password',
                                style: GoogleFonts.inter(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.black.withValues(alpha: 0.4),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: Colors.black.withValues(alpha: 0.4),
                                    size: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.black.withValues(alpha: 0.4),
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE4E4EC), width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE4E4EC), width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF008080), width: 2),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Submit Primary Button (Teal CTA like Eazzio Payroll)
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF008080),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: authState.status == AuthStatus.loading
                                      ? null
                                      : _submitLogin,
                                  child: authState.status == AuthStatus.loading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          'Sign In',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Footer
                  Text(
                    'v1.0.3 · Powered by Eazzio Technologies Pvt Ltd',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleVisual {
  final String portalTag;
  final String welcomeTitle;
  final String welcomeSubtitle;
  final Color accentColor;
  final Color bgColor;
  final IconData icon;

  const _RoleVisual({
    required this.portalTag,
    required this.welcomeTitle,
    required this.welcomeSubtitle,
    required this.accentColor,
    required this.bgColor,
    required this.icon,
  });
}
