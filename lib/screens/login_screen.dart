import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _selectedRole = "Buyer";
  final TextEditingController _emailController = TextEditingController(text: "rehan.khan@example.com");
  final TextEditingController _passwordController = TextEditingController(text: "password123");
  bool _rememberMe = true;
  bool _obscurePassword = true;

  // Validation States
  String? _emailError;
  bool _isEmailValid = true; // Pre-filled value is valid initially

  String? _passwordError;
  bool _isPasswordValid = true; // Pre-filled value is valid initially

  String? _roleError;

  void _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _emailError = "Please enter a valid email address.";
        _isEmailValid = false;
      });
      return;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmed) || !trimmed.contains('@') || trimmed.split('@').last.isEmpty) {
      setState(() {
        _emailError = "Please enter a valid email address.";
        _isEmailValid = false;
      });
    } else {
      setState(() {
        _emailError = null;
        _isEmailValid = true;
      });
    }
  }

  void _validatePassword(String value) {
    if (value.isEmpty) {
      setState(() {
        _passwordError = "Password cannot be empty.";
        _isPasswordValid = false;
      });
    } else {
      setState(() {
        _passwordError = null;
        _isPasswordValid = true;
      });
    }
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    required String? errorText,
    required bool isValid,
    Widget? suffixIcon,
  }) {
    final hasError = errorText != null;

    final borderSide = hasError
        ? BorderSide(color: AppTheme.errorColor, width: 1.5)
        : (isValid
            ? const BorderSide(color: Colors.green, width: 1.5)
            : BorderSide(color: AppTheme.borderLight, width: 1.5));

    final focusedBorderSide = hasError
        ? BorderSide(color: AppTheme.errorColor, width: 2.0)
        : (isValid
            ? const BorderSide(color: Colors.green, width: 2.0)
            : BorderSide(color: AppTheme.primary, width: 2.0));

    Widget? finalSuffix;
    if (suffixIcon != null) {
      finalSuffix = Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (hasError)
              Icon(Icons.error_outline_rounded, color: AppTheme.errorColor, size: 20)
            else if (isValid)
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
            suffixIcon,
          ],
        ),
      );
    } else {
      if (hasError) {
        finalSuffix = Icon(Icons.error_outline_rounded, color: AppTheme.errorColor, size: 20);
      } else if (isValid) {
        finalSuffix = const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20);
      }
    }

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, size: 20, color: AppTheme.textLight),
      suffixIcon: finalSuffix,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: borderSide,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: focusedBorderSide,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // Modern Branding Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: AppTheme.buttonShadow,
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Sign in to access your StudySwap marketplace",
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Email Input field
                TextField(
                  controller: _emailController,
                  onChanged: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark),
                  decoration: _buildInputDecoration(
                    labelText: "Email / Username",
                    hintText: "Enter your email address",
                    prefixIcon: Icons.email_outlined,
                    errorText: _emailError,
                    isValid: _isEmailValid,
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: _emailError != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 6, left: 16),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline_rounded, color: AppTheme.errorColor, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                _emailError!,
                                style: TextStyle(
                                  color: AppTheme.errorColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),

                // Password Input field
                TextField(
                  controller: _passwordController,
                  onChanged: _validatePassword,
                  obscureText: _obscurePassword,
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark),
                  decoration: _buildInputDecoration(
                    labelText: "Password",
                    hintText: "Enter your password",
                    prefixIcon: Icons.lock_outline_rounded,
                    errorText: _passwordError,
                    isValid: _isPasswordValid,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20,
                        color: AppTheme.textLight,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: _passwordError != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 6, left: 16),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline_rounded, color: AppTheme.errorColor, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                _passwordError!,
                                style: TextStyle(
                                  color: AppTheme.errorColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),

                // Remember Me & Forgot Password Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            onChanged: (val) {
                              setState(() {
                                _rememberMe = val ?? true;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Keep me logged in",
                          style: TextStyle(
                            color: AppTheme.textMedium,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Role Header
                Text(
                  "Choose your account type",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Select how you want to use StudySwap.",
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Redesigned Role Selection Cards Row
                Row(
                  children: [
                    _buildRoleCard(
                      roleName: "Buyer",
                      title: "📚 Buyer",
                      description: "Purchase books, notes and study resources.",
                      icon: Icons.shopping_bag_rounded,
                      isSelected: _selectedRole == "Buyer",
                      onTap: () {
                        setState(() {
                          _selectedRole = "Buyer";
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildRoleCard(
                      roleName: "Seller",
                      title: "🏪 Seller",
                      description: "Upload and sell study materials to other students.",
                      icon: Icons.storefront_rounded,
                      isSelected: _selectedRole == "Seller",
                      onTap: () {
                        setState(() {
                          _selectedRole = "Seller";
                        });
                      },
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: _roleError != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 6, left: 16),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline_rounded, color: AppTheme.errorColor, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                _roleError!,
                                style: TextStyle(
                                  color: AppTheme.errorColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 36),

                // Modern Elevated Primary CTA Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.buttonShadow,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        _validateEmail(_emailController.text);
                        _validatePassword(_passwordController.text);

                        if (_selectedRole.isEmpty) {
                          setState(() {
                            _roleError = "Please select Buyer or Seller.";
                          });
                        } else {
                          setState(() {
                            _roleError = null;
                          });
                        }

                        if (_emailError != null || _passwordError != null || _roleError != null) {
                          return;
                        }

                        // Apply Selected Role and fields to State
                        AppState.userRoleNotifier.value = _selectedRole;
                        if (_selectedRole == "Buyer") {
                          AppState.nameNotifier.value = "Rehan Khan";
                          AppState.emailNotifier.value = _emailController.text.isNotEmpty 
                              ? _emailController.text 
                              : "rehan.khan@example.com";
                        } else {
                          AppState.nameNotifier.value = "John Seller";
                          AppState.emailNotifier.value = _emailController.text.isNotEmpty 
                              ? _emailController.text 
                              : "john.seller@example.com";
                        }
                        
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: AppTheme.primary,
                        elevation: 0,
                      ),
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Footer sign up router (centered directly below sign in)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account yet? ",
                      style: TextStyle(color: AppTheme.textMedium, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const RegisterScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return SlideTransition(
                                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
                                  CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
                                ),
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Create Account",
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Interactive Premium Selection Card
  Widget _buildRoleCard({
    required String roleName,
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: AnimatedScale(
        scale: isSelected ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary.withValues(alpha: 0.06) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.borderLight,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected ? AppTheme.premiumShadow : AppTheme.shadowSmall,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              splashColor: AppTheme.primary.withValues(alpha: 0.1),
              highlightColor: AppTheme.primary.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Larger Filled / Unfilled Icon Circle Container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary : AppTheme.bgSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? Colors.white : AppTheme.textLight,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title Text
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Description
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? AppTheme.textMedium : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
