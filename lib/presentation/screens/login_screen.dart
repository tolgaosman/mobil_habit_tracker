import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
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
      error = await auth.signUp(
        email: _emailController.text,
        name: _nameController.text,
        password: _passwordController.text,
      );
    } else {
      error = await auth.signIn(
        email: _emailController.text,
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
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                  _buildEmailField(),
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
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 90,
      width: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.teal, AppColors.violet],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: const Icon(
        Icons.check_circle_outline_rounded,
        size: 50,
        color: Colors.white,
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.elasticOut);
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          _isSignUp ? 'Create Account' : 'Welcome Back',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          _isSignUp
              ? 'Start tracking your daily goals today'
              : 'Sign in to access your habit dashboard',
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
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
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
      decoration: const InputDecoration(
        hintText: 'Full Name',
        prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.textTertiary),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0, duration: 300.ms);
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      style: Theme.of(context).textTheme.bodyLarge,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        hintText: 'Email Address',
        prefixIcon: Icon(Icons.email_outlined, color: AppColors.textTertiary),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
          return 'Please enter a valid email address';
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
        hintText: 'Password',
        prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.textTertiary),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textTertiary,
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Please enter your password';
        }
        if (val.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.black,
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
                  color: Colors.black,
                ),
              )
            : Text(
                _isSignUp ? 'Sign Up' : 'Sign In',
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
            _isSignUp ? 'Already have an account? ' : 'Don\'t have an account? ',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          Text(
            _isSignUp ? 'Sign In' : 'Sign Up',
            style: const TextStyle(
              color: AppColors.teal,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 400.ms);
  }
}
