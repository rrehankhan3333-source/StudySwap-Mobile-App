import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailAlerts = false;
  bool _darkMode = false;
  String _language = "English";

  @override
  void initState() {
    super.initState();
    _darkMode = AppState.darkModeNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 54,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderMedium, width: 1.5),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 14),
              ),
            ),
          ),
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        shape: Border(bottom: BorderSide(color: AppTheme.borderMedium, width: 1.5)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                "Account & Privacy",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMedium,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderMedium, width: 1.5),
                boxShadow: AppTheme.shadowSmall,
              ),
              child: Column(
                children: [
                   _buildSettingsItem(
                    icon: Icons.lock_outline_rounded,
                    title: "Change Password",
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textMedium),
                    onTap: () => _showChangePasswordDialog(),
                  ),
                  Container(height: 1.5, color: AppTheme.borderMedium),
                  _buildSettingsItem(
                    icon: Icons.shield_outlined,
                    title: "Privacy Settings",
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textMedium),
                    onTap: () => _showDialog(context, "Privacy Settings", "Configure account visibility."),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                "Notifications",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMedium,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderMedium, width: 1.5),
                boxShadow: AppTheme.shadowSmall,
              ),
              child: Column(
                children: [
                  _buildSettingsSwitch(
                    icon: Icons.notifications_none_outlined,
                    title: "Push Notifications",
                    value: _pushNotifications,
                    onChanged: (val) {
                      setState(() {
                        _pushNotifications = val;
                      });
                    },
                  ),
                  Container(height: 1.5, color: AppTheme.borderMedium),
                  _buildSettingsSwitch(
                    icon: Icons.mail_outline_rounded,
                    title: "Email Alerts",
                    value: _emailAlerts,
                    onChanged: (val) {
                      setState(() {
                        _emailAlerts = val;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                "Preferences",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMedium,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderMedium, width: 1.5),
                boxShadow: AppTheme.shadowSmall,
              ),
              child: Column(
                children: [
                  _buildSettingsSwitch(
                    icon: Icons.dark_mode_outlined,
                    title: "Dark Mode",
                    value: _darkMode,
                    onChanged: (val) async {
                      setState(() {
                        _darkMode = val;
                      });
                      await AppState.toggleDarkMode(val);
                    },
                  ),
                  Container(height: 1.5, color: AppTheme.borderMedium),
                  _buildSettingsItem(
                    icon: Icons.translate_rounded,
                    title: "App Language",
                    avatarText: _language,
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textMedium),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => SimpleDialog(
                          backgroundColor: AppTheme.bgCard,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(color: AppTheme.borderMedium, width: 1.5),
                          ),
                          title: Text(
                            "Select Language",
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 18),
                          ),
                          children: ["English", "Spanish", "French", "Urdu"].map((lang) {
                            final isCurrent = _language == lang;
                            return SimpleDialogOption(
                              onPressed: () {
                                setState(() {
                                  _language = lang;
                                });
                                Navigator.pop(ctx);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      lang,
                                      style: TextStyle(
                                        color: isCurrent ? AppTheme.primary : AppTheme.textDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (isCurrent)
                                      Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 18),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                "Help & Information",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMedium,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderMedium, width: 1.5),
                boxShadow: AppTheme.shadowSmall,
              ),
              child: Column(
                children: [
                  _buildSettingsItem(
                    icon: Icons.help_outline_rounded,
                    title: "FAQs",
                    trailing: Icon(Icons.open_in_new_rounded, size: 12, color: AppTheme.textMedium),
                    onTap: () => _showDialog(context, "FAQs", "Frequently Asked Questions catalog."),
                  ),
                  Container(height: 1.5, color: AppTheme.borderMedium),
                  _buildSettingsItem(
                    icon: Icons.info_outline_rounded,
                    title: "About App",
                    trailing: Text(
                      "v1.0.0",
                      style: TextStyle(color: AppTheme.textMedium, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onTap: () => _showDialog(context, "About", "StudySwap v1.0.0. A university exchange app."),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
    String? avatarText,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: AppTheme.primaryPastel,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.borderMedium, width: 1.0),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppTheme.textDark, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.textDark, letterSpacing: -0.2),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (avatarText != null) ...[
            Text(avatarText, style: TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
          ],
          trailing,
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSettingsSwitch({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      secondary: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: AppTheme.primaryPastel,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.borderMedium, width: 1.0),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppTheme.textDark, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.textDark, letterSpacing: -0.2),
      ),
      value: value,
      activeColor: AppTheme.primary,
      activeTrackColor: AppTheme.primary.withOpacity(0.15),
      onChanged: onChanged,
    );
  }

  void _showChangePasswordDialog() {
    final formKey = GlobalKey<FormState>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: AppTheme.premiumShadow,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: AppTheme.borderMedium,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Change Password",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Please verify your current password to continue.",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMedium,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Current Password
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: obscureCurrent,
                        style: TextStyle(color: AppTheme.textDark),
                        decoration: InputDecoration(
                          labelText: "Current Password",
                          prefixIcon: Icon(Icons.lock_rounded, color: AppTheme.primary, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureCurrent ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: AppTheme.textMedium,
                              size: 20,
                            ),
                            onPressed: () {
                              setModalState(() {
                                obscureCurrent = !obscureCurrent;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your current password";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // New Password
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        style: TextStyle(color: AppTheme.textDark),
                        decoration: InputDecoration(
                          labelText: "New Password",
                          prefixIcon: Icon(Icons.lock_outline_rounded, color: AppTheme.secondary, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: AppTheme.textMedium,
                              size: 20,
                            ),
                            onPressed: () {
                              setModalState(() {
                                obscureNew = !obscureNew;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a new password";
                          }
                          if (value.length < 8) {
                            return "Password must be at least 8 characters long";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Confirm Password
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        style: TextStyle(color: AppTheme.textDark),
                        decoration: InputDecoration(
                          labelText: "Confirm New Password",
                          prefixIcon: Icon(Icons.shield_outlined, color: AppTheme.accent, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: AppTheme.textMedium,
                              size: 20,
                            ),
                            onPressed: () {
                              setModalState(() {
                                obscureConfirm = !obscureConfirm;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please confirm your new password";
                          }
                          if (value != newPasswordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Save button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(context);
                            
                            // Show loading indicator
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Text("Updating password...", style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                                backgroundColor: AppTheme.primary,
                                duration: const Duration(minutes: 1),
                              ),
                            );

                            try {
                              final user = AppState.currentUser;
                              if (user == null || user.email == null) {
                                throw "No active authenticated session found.";
                              }
                              
                              // Reauthenticate
                              final credential = EmailAuthProvider.credential(
                                email: user.email!,
                                password: currentPasswordController.text,
                              );
                              
                              await user.reauthenticateWithCredential(credential);
                              await user.updatePassword(newPasswordController.text);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text("Password updated successfully."),
                                    backgroundColor: AppTheme.successColor,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error updating password: $e"),
                                    backgroundColor: Colors.redAccent.shade700,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: const Text(
                          "Update Password",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppTheme.borderMedium, width: 1.5),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark, fontSize: 18),
        ),
        content: Text(
          body,
          style: TextStyle(color: AppTheme.textMedium, fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primary,
            ),
            child: const Text(
              "Ok",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
