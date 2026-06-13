import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/language_provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../widgets/glass.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailOrPhoneController.addListener(_onEmailOrPhoneChanged);
  }

  void _onEmailOrPhoneChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailOrPhoneController.removeListener(_onEmailOrPhoneChanged);
    _emailOrPhoneController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _errorMessage = null;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = context.read<AuthProvider>();
    String? error;

    if (_isSignUp) {
      final input = _emailOrPhoneController.text.trim();
      final isEmail = input.contains('@');

      error = await auth.signUp(
        email: isEmail ? input : null,
        phoneNumber: isEmail ? null : input,
        name: _nameController.text,
        password: _passwordController.text,
      );
    } else {
      error = await auth.signIn(
        emailOrPhone: _emailOrPhoneController.text,
        password: _passwordController.text,
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Decorative emerald glow blobs in the background
          Positioned(
            top: -120,
            right: -100,
            child: _GlowBlob(
              color: AppColors.tealGlow,
              size: 320,
              opacity: context.isDarkMode ? 0.30 : 0.18,
            ),
          ),
          Positioned(
            bottom: -140,
            left: -120,
            child: _GlowBlob(
              color: AppColors.violet,
              size: 300,
              opacity: context.isDarkMode ? 0.22 : 0.12,
            ),
          ),
          SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 32),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  if (_errorMessage != null) _buildErrorCard(),
                  if (_isSignUp) ...[
                    _buildNameField(),
                    const SizedBox(height: 16),
                  ],
                  _buildEmailOrPhoneField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                  _buildToggleLink(),
                ],
              ),
            ),
          ),
        ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: context.glowShadow(AppColors.tealGlow, strength: 1.2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.asset(
            'assets/images/app_logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).scale(
        begin: const Offset(0.8, 0.8),
        duration: 600.ms,
        curve: Curves.elasticOut);
  }

  Widget _buildHeader() {
    return Column(
      children: [
        GradientText(
          _isSignUp ? 'Create Account'.tr(context) : 'Welcome Back'.tr(context),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          _isSignUp
              ? 'Start tracking your daily goals today'.tr(context)
              : 'Sign in to access your habit dashboard'.tr(context),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0, delay: 200.ms, duration: 400.ms);
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    ).animate().shake(duration: 400.ms);
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Full Name'.tr(context),
        prefixIcon: const Icon(Icons.person_outline_rounded,
            color: AppColors.textTertiary),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Please enter your name'.tr(context);
        }
        return null;
      },
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0, duration: 300.ms);
  }

  Widget _buildEmailOrPhoneField() {
    return TextFormField(
      controller: _emailOrPhoneController,
      style: Theme.of(context).textTheme.bodyLarge,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: 'Email or Phone Number'.tr(context),
        prefixIcon: Icon(
          _emailOrPhoneController.text.trim().isNotEmpty &&
                  !_emailOrPhoneController.text.contains('@') &&
                  RegExp(r'^\+?[0-9\s\-()]*$')
                      .hasMatch(_emailOrPhoneController.text.trim())
              ? Icons.phone_iphone_rounded
              : Icons.email_outlined,
          color: AppColors.textTertiary,
        ),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Please enter your email or phone number'.tr(context);
        }
        final trimmed = val.trim();
        if (trimmed.contains('@')) {
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmed)) {
            return 'Please enter a valid email address'.tr(context);
          }
        } else {
          final phoneRegex = RegExp(r'^\+?[0-9\s\-()]{7,15}$');
          if (!phoneRegex.hasMatch(trimmed)) {
            return 'Please enter a valid phone number'.tr(context);
          }
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      style: Theme.of(context).textTheme.bodyLarge,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: 'Password'.tr(context),
        prefixIcon:
            const Icon(Icons.lock_outlined, color: AppColors.textTertiary),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.textTertiary,
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Please enter your password'.tr(context);
        }
        if (val.length < 6) {
          return 'Password must be at least 6 characters'.tr(context);
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: context.accentGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.glowShadow(AppColors.teal, strength: 0.9),
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                _isSignUp ? 'Sign Up'.tr(context) : 'Sign In'.tr(context),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0, delay: 300.ms, duration: 400.ms);
  }

  Widget _buildToggleLink() {
    return GestureDetector(
      onTap: _isLoading ? null : _toggleMode,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isSignUp
                ? 'Already have an account? '.tr(context)
                : 'Don\'t have an account? '.tr(context),
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          Text(
            _isSignUp ? 'Sign In'.tr(context) : 'Sign Up'.tr(context),
            style: const TextStyle(
              color: AppColors.teal,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }
}

/// Soft blurred color blob used as decorative background lighting.
class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _GlowBlob({
    required this.color,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
