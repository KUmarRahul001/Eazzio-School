import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/presentation/auth_controller.dart';
import '../auth/models/auth_user.dart';

/// Animated branded in-app splash screen.
/// Guarantees that users never see a blank or empty screen during cold start,
/// displaying the official portal branding before smoothly navigating to the portal or login.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    // Show branded splash screen for at least 1.8 seconds to establish brand presence
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    final authState = ref.read(authNotifierProvider);

    // If still checking session, wait briefly
    if (authState.status == AuthStatus.initial) {
      await Future.delayed(const Duration(milliseconds: 400));
    }

    if (!mounted) return;

    final currentAuth = ref.read(authNotifierProvider);
    if (currentAuth.status == AuthStatus.authenticated) {
      if (currentAuth.user?.role == UserRole.teacher ||
          currentAuth.user?.role == UserRole.admin ||
          currentAuth.user?.role == UserRole.principal) {
        context.go('/teacher');
      } else {
        context.go('/student');
      }
    } else {
      context.go('/role-selection');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: size.width * 0.75,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Empowering Education Digitally',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black45,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
