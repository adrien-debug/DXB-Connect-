import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/error_banner.dart';

enum _AuthMode { landing, emailAuth }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  _AuthMode _mode = _AuthMode.landing;
  bool _isRegistering = false;
  bool _isLoading = false;
  String? _errorMessage;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOut,
      ),
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final emailOk =
        _emailController.text.isNotEmpty && _emailController.text.contains('@');
    final passwordOk = _passwordController.text.length >= 8;
    if (_isRegistering) {
      return emailOk && passwordOk && _nameController.text.isNotEmpty;
    }
    return emailOk && passwordOk;
  }

  void _switchMode(_AuthMode mode) {
    _slideController.reset();
    setState(() {
      _mode = mode;
      _errorMessage = null;
    });
    _slideController.forward();
  }

  void _toggleRegister() {
    _slideController.reset();
    setState(() {
      _isRegistering = !_isRegistering;
      _errorMessage = null;
    });
    _slideController.forward();
  }

  void _goBackToLanding() {
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _switchMode(_AuthMode.landing);
  }


  Future<void> _submitAuth() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifier = ref.read(authProvider.notifier);
      if (_isRegistering) {
        await notifier.signUp(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
      } else {
        await notifier.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      final authState = ref.read(authProvider);
      if (authState.error != null) {
        setState(() => _errorMessage = authState.error);
      }
    } catch (e) {
      setState(() {
        _errorMessage = _isRegistering
            ? 'Registration failed. Please try again.'
            : 'Invalid email or password.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IgnorePointer(child: _buildBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: constraints.maxHeight * 0.12,
                          ),
                          const AuthLogo(),
                          SizedBox(
                            height: constraints.maxHeight * 0.08,
                          ),
                          SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: _mode == _AuthMode.landing
                                  ? _buildLandingContent()
                                  : _buildEmailAuthContent(),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.accent.withValues(alpha: 0.06),
                AppColors.background,
                AppColors.background,
              ],
              stops: const [0.0, 0.35, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -60,
          right: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -60,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.02),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandingContent() {
    return Column(
      children: [
        const Text(
          'Welcome',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sign in to access your premium eSIMs',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        _buildEmailButton(),
        const SizedBox(height: 24),
        _buildTermsText(),
      ],
    );
  }


  Widget _buildEmailButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          _switchMode(_AuthMode.emailAuth);
          setState(() => _isRegistering = false);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          side: const BorderSide(
            color: AppColors.surfaceBorder,
            width: 0.5,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.email_rounded, size: 18),
            SizedBox(width: 10),
            Text(
              'Continue with Email',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textTertiary,
        ),
        children: [
          const TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(
              color: AppColors.accent.withValues(alpha: 0.8),
              decoration: TextDecoration.underline,
            ),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: AppColors.accent.withValues(alpha: 0.8),
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailAuthContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBackButton(),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              Text(
                _isRegistering ? 'Create Account' : 'Sign In',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isRegistering
                    ? 'Enter your details to get started'
                    : 'Enter your credentials',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        if (_isRegistering) ...[
          AuthTextField(
            label: 'NAME',
            placeholder: 'Your name',
            controller: _nameController,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
        ],
        AuthTextField(
          label: 'EMAIL',
          placeholder: 'your@email.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        AuthTextField(
          label: 'PASSWORD',
          placeholder: 'Min. 8 characters',
          controller: _passwordController,
          isSecure: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (_isFormValid) _submitAuth();
          },
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 20),
          ErrorBanner(
            message: _errorMessage!,
            onDismiss: () => setState(() => _errorMessage = null),
          ),
        ],
        const SizedBox(height: 28),
        _buildSubmitButton(),
        const SizedBox(height: 20),
        _buildToggleAuthMode(),
      ],
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: _goBackToLanding,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chevron_left_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 4),
          Text(
            'Back',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isFormValid ? 1.0 : 0.5,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: ElevatedButton(
            onPressed: _isFormValid ? _submitAuth : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
              disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.3),
              disabledForegroundColor: Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(
              _isRegistering ? 'Create Account' : 'Sign In',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleAuthMode() {
    return Center(
      child: GestureDetector(
        onTap: _toggleRegister,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isRegistering
                  ? "Already have an account? "
                  : "Don't have an account? ",
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              _isRegistering ? 'Sign In' : 'Sign Up',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    String message;
    if (_mode == _AuthMode.landing) {
      message = 'Signing in...';
    } else {
      message = _isRegistering ? 'Creating account...' : 'Signing in...';
    }

    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 36,
                vertical: 28,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.accent,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
