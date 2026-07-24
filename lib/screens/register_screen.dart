import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool agree = false;
  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;
  String accountType = "Buyer";
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Validation States
  String? _nameError;
  bool _isNameValid = false;

  String? _emailError;
  bool _isEmailValid = false;

  String? _phoneError;
  bool _isPhoneValid = false;

  String? _passwordError;
  bool _isPasswordValid = false;

  String? _confirmPasswordError;
  bool _isConfirmPasswordValid = false;

  String? _termsError;
  String? _roleError;

  bool _submitted = false;
  bool _isLoading = false;

  void _validateName(String value) {
    if (value.isEmpty) {
      setState(() {
        _nameError = "Please enter a valid name using letters only.";
        _isNameValid = false;
      });
      return;
    }
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    final trimmed = value.trim();
    if (trimmed.length < 3 || trimmed.length > 50 || !nameRegex.hasMatch(value)) {
      setState(() {
        _nameError = "Please enter a valid name using letters only.";
        _isNameValid = false;
      });
    } else {
      setState(() {
        _nameError = null;
        _isNameValid = true;
      });
    }
  }

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

  void _validatePhone(String value) {
    if (value.isEmpty) {
      setState(() {
        _phoneError = "Please enter a valid mobile number.";
        _isPhoneValid = false;
      });
      return;
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      setState(() {
        _phoneError = "Please enter a valid mobile number.";
        _isPhoneValid = false;
      });
    } else {
      setState(() {
        _phoneError = null;
        _isPhoneValid = true;
      });
    }
  }

  void _validatePassword(String value) {
    if (value.isEmpty) {
      setState(() {
        _passwordError = "Password must be at least 8 characters and include uppercase, lowercase, number, and special character.";
        _isPasswordValid = false;
      });
      return;
    }
    bool hasMinLength = value.length >= 8;
    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = value.contains(RegExp(r'[a-z]'));
    bool hasDigits = value.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = value.contains(RegExp(r'[!@#\$%^&\*]'));

    if (!hasMinLength || !hasUppercase || !hasLowercase || !hasDigits || !hasSpecialCharacters) {
      setState(() {
        _passwordError = "Password must be at least 8 characters and include uppercase, lowercase, number, and special character.";
        _isPasswordValid = false;
      });
    } else {
      setState(() {
        _passwordError = null;
        _isPasswordValid = true;
      });
    }

    if (_confirmPasswordController.text.isNotEmpty) {
      _validateConfirmPassword(_confirmPasswordController.text);
    }
  }

  void _validateConfirmPassword(String value) {
    if (value.isEmpty) {
      setState(() {
        _confirmPasswordError = "Passwords do not match.";
        _isConfirmPasswordValid = false;
      });
      return;
    }
    if (value != _passwordController.text) {
      setState(() {
        _confirmPasswordError = "Passwords do not match.";
        _isConfirmPasswordValid = false;
      });
    } else {
      setState(() {
        _confirmPasswordError = null;
        _isConfirmPasswordValid = true;
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Styled Back Button
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgCard, 
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.borderLight, width: 1.5),
                  boxShadow: AppTheme.shadowSmall,
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.textDark),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Join the StudySwap student marketplace",
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // Full Name field
              TextField(
                controller: _nameController,
                onChanged: _validateName,
                style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark),
                decoration: _buildInputDecoration(
                  labelText: "Full Name",
                  hintText: "Enter your full name",
                  prefixIcon: Icons.person_outline_rounded,
                  errorText: _nameError,
                  isValid: _isNameValid,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _nameError != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 6, left: 16),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded, color: AppTheme.errorColor, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              _nameError!,
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

              // Email field
              TextField(
                controller: _emailController,
                onChanged: _validateEmail,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark),
                decoration: _buildInputDecoration(
                  labelText: "University Email",
                  hintText: "e.g., student@cui.edu",
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

              // Mobile Number field
              TextField(
                controller: _phoneController,
                onChanged: _validatePhone,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                ],
                style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark),
                decoration: _buildInputDecoration(
                  labelText: "Mobile Number",
                  hintText: "Enter mobile number",
                  prefixIcon: Icons.phone_outlined,
                  errorText: _phoneError,
                  isValid: _isPhoneValid,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _phoneError != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 6, left: 16),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded, color: AppTheme.errorColor, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              _phoneError!,
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

              // Password field
              TextField(
                controller: _passwordController,
                onChanged: _validatePassword,
                obscureText: isPasswordHidden,
                style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark),
                decoration: _buildInputDecoration(
                  labelText: "Password",
                  hintText: "Create password",
                  prefixIcon: Icons.lock_outline_rounded,
                  errorText: _passwordError,
                  isValid: _isPasswordValid,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: AppTheme.textLight,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordHidden = !isPasswordHidden;
                      });
                    },
                  ),
                ),
              ),
              // Hint shown when empty, error shown when invalid
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6, left: 16, right: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _passwordError != null ? Icons.error_outline_rounded : Icons.info_outline_rounded,
                        color: _passwordError != null ? AppTheme.errorColor : AppTheme.textLight,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _passwordError ?? "Password must be at least 8 characters and include uppercase, lowercase, number, and special character.",
                          style: TextStyle(
                            color: _passwordError != null ? AppTheme.errorColor : AppTheme.textLight,
                            fontSize: 12,
                            fontWeight: _passwordError != null ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Confirm Password field
              TextField(
                controller: _confirmPasswordController,
                onChanged: _validateConfirmPassword,
                obscureText: isConfirmPasswordHidden,
                style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark),
                decoration: _buildInputDecoration(
                  labelText: "Confirm Password",
                  hintText: "Re-type password",
                  prefixIcon: Icons.lock_outline_rounded,
                  errorText: _confirmPasswordError,
                  isValid: _isConfirmPasswordValid,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isConfirmPasswordHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: AppTheme.textLight,
                    ),
                    onPressed: () {
                      setState(() {
                        isConfirmPasswordHidden = !isConfirmPasswordHidden;
                      });
                    },
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _confirmPasswordError != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 6, left: 16),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded, color: AppTheme.errorColor, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              _confirmPasswordError!,
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
              const SizedBox(height: 32),

              // Role Selection Section
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

              // Unified Card selectors
              Row(
                children: [
                  _buildRoleCard(
                    roleName: "Buyer",
                    title: "📚 Buyer",
                    description: "Purchase books, notes and study resources.",
                    icon: Icons.shopping_bag_rounded,
                    isSelected: accountType == "Buyer",
                    onTap: () {
                      setState(() {
                        accountType = "Buyer";
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildRoleCard(
                    roleName: "Seller",
                    title: "🏪 Seller",
                    description: "Upload and sell study materials to other students.",
                    icon: Icons.storefront_rounded,
                    isSelected: accountType == "Seller",
                    onTap: () {
                      setState(() {
                        accountType = "Seller";
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Terms Agreement Custom Widget
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard, 
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _termsError != null ? AppTheme.errorColor : AppTheme.borderLight,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: agree,
                        activeColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        onChanged: (bool? value) {
                          setState(() {
                            agree = value ?? false;
                            if (agree) {
                              _termsError = null;
                            } else if (_submitted) {
                              _termsError = "Please accept the Terms and Conditions.";
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "I agree to the StudySwap Honor Policy, terms & conditions & privacy rules.",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMedium,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _termsError != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 6, left: 16),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded, color: AppTheme.errorColor, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              _termsError!,
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
              const SizedBox(height: 32),

              // Create Account CTA Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.buttonShadow,
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      setState(() {
                        _submitted = true;
                      });

                      // Real-time validations run on submit
                      _validateName(_nameController.text);
                      _validateEmail(_emailController.text);
                      _validatePhone(_phoneController.text);
                      _validatePassword(_passwordController.text);
                      _validateConfirmPassword(_confirmPasswordController.text);

                      if (!agree) {
                        setState(() {
                          _termsError = "Please accept the Terms and Conditions.";
                        });
                      } else {
                        setState(() {
                          _termsError = null;
                        });
                      }

                      if (accountType.isEmpty) {
                        setState(() {
                          _roleError = "Please select Buyer or Seller.";
                        });
                      } else {
                        setState(() {
                          _roleError = null;
                        });
                      }

                      // Check validation results
                      if (_nameError != null ||
                          _emailError != null ||
                          _phoneError != null ||
                          _passwordError != null ||
                          _confirmPasswordError != null ||
                          _termsError != null ||
                          _roleError != null) {
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                        );
                        final user = credential.user;
                        if (user != null) {
                          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                            'uid': user.uid,
                            'fullName': _nameController.text.trim(),
                            'email': _emailController.text.trim(),
                            'phone': _phoneController.text.trim(),
                            'accountType': accountType,
                            'profileImage': '',
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          await AppState.addNotification(
                            "Welcome to StudySwap!",
                            "Exchange your books, notes, and study guidelines today.",
                            type: "System",
                          );

                          if (mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 500),
                              ),
                              (route) => false,
                            );
                          }
                        }
                      } on FirebaseAuthException catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.message ?? "Registration failed. Please try again."),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error: ${e.toString()}"),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: AppTheme.primary,
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.2,
                            ),
                          )
                        : const Text(
                            "Create Profile",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Already have an account menu redirection
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(color: AppTheme.textMedium, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
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
