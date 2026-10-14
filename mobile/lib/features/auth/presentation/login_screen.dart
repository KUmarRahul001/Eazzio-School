import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eazzio_school/core/theme/app_theme.dart';
import 'package:eazzio_school/core/theme/app_icons.dart';
import '../models/auth_user.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isTeacher = authState.selectedPortal == UserRole.teacher;

    return Scaffold(
      body: Stack(
        children: [
          // Background soft gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Security Badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_outline,
                                size: 14, color: AppTheme.successGreen),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '256-bit Encrypted Session',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // App Logo & Header
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 54,
                        width: 54,
                        errorBuilder: (_, __, ___) => const Icon(Icons.school,
                            size: 48, color: AppTheme.primaryBlue),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Eazzio-School',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Campus Management System',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // MANDATORY PRODUCT REQUIREMENT:
                    // Shared login screen with TWO portal choices side by side
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Student Portal Card
                          Expanded(
                            child: _PortalChoiceCard(
                              title: 'Student Portal',
                              subtitle: 'ID or Roll No.',
                              icon: Icons.school_outlined,
                              customIcon: AppIcons.studentPortal,
                              isSelected: !isTeacher,
                              activeColor: AppTheme.studentAccent,
                              onTap: () {
                                ref
                                    .read(authNotifierProvider.notifier)
                                    .selectPortal(UserRole.student);
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Teacher Portal Card
                          Expanded(
                            child: _PortalChoiceCard(
                              title: 'Teacher Portal',
                              subtitle: 'Faculty & Staff',
                              icon: Icons.menu_book_rounded,
                              customIcon: AppIcons.teacherPortal,
                              isSelected: isTeacher,
                              activeColor: AppTheme.teacherAccent,
                              onTap: () {
                                ref
                                    .read(authNotifierProvider.notifier)
                                    .selectPortal(UserRole.teacher);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: (isTeacher
                                            ? AppTheme.teacherAccent
                                            : AppTheme.studentAccent)
                                        .withValues(alpha: 0.12),
                                    child: AppIcons.render(
                                      isTeacher
                                          ? AppIcons.teacherPortal
                                          : AppIcons.studentPortal,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      isTeacher
                                          ? 'Teacher Sign In'
                                          : 'Student Sign In',
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textDark,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Error Alert if any
                              if (authState.errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.errorRed
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: AppTheme.errorRed
                                            .withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.error_outline,
                                          size: 18, color: AppTheme.errorRed),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          authState.errorMessage!,
                                          style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: AppTheme.errorRed,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Identifier Field
                              Text(
                                isTeacher
                                    ? 'Employee ID or Faculty Email'
                                    : 'Student ID (e.g., STU001)',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _loginIdController,
                                keyboardType: isTeacher
                                    ? TextInputType.emailAddress
                                    : TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: isTeacher
                                      ? 'teacher1@demo.com or EMP001'
                                      : 'STU001',
                                  prefixIcon: const Icon(Icons.badge_outlined,
                                      size: 20),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return isTeacher
                                        ? 'Please enter Employee ID or Email'
                                        : 'Please enter Student ID';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password Field
                              Text(
                                'Password',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  prefixIcon:
                                      const Icon(Icons.lock_outline, size: 20),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
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

                              // Submit Button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isTeacher
                                      ? AppTheme.teacherAccent
                                      : AppTheme.studentAccent,
                                ),
                                onPressed:
                                    authState.status == AuthStatus.loading
                                        ? null
                                        : _submitLogin,
                                child: authState.status == AuthStatus.loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              isTeacher
                                                  ? 'Enter Teacher Portal'
                                                  : 'Enter Student Portal',
                                              style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 18),
                                        ],
                                      ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quick Demo Login (Tap to fill):',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        ActionChip(
                                          avatar: const Icon(Icons.school,
                                              size: 14),
                                          label: const Text('Student (STU001)',
                                              style: TextStyle(fontSize: 12)),
                                          onPressed: () {
                                            if (isTeacher) {
                                              ref
                                                  .read(authNotifierProvider
                                                      .notifier)
                                                  .selectPortal(
                                                      UserRole.student);
                                            }
                                            _loginIdController.text = 'STU001';
                                            _passwordController.text =
                                                'password123';
                                          },
                                        ),
                                        ActionChip(
                                          avatar: const Icon(Icons.person,
                                              size: 14),
                                          label: const Text(
                                              'Teacher (teacher1)',
                                              style: TextStyle(fontSize: 12)),
                                          onPressed: () {
                                            if (!isTeacher) {
                                              ref
                                                  .read(authNotifierProvider
                                                      .notifier)
                                                  .selectPortal(
                                                      UserRole.teacher);
                                            }
                                            _loginIdController.text =
                                                'teacher1@demo.com';
                                            _passwordController.text =
                                                'password123';
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'One app, shared login, role-governed security.',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortalChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? customIcon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _PortalChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.customIcon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            if (customIcon != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: AppIcons.render(customIcon!, size: 36),
              )
            else
              Icon(
                icon,
                size: 28,
                color: isSelected ? activeColor : AppTheme.textMuted,
              ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? activeColor : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: isSelected
                    ? activeColor.withValues(alpha: 0.8)
                    : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
