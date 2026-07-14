import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'my_listings_screen.dart';
import 'wishlist_screen.dart';
import 'messages_screen.dart';
import 'settings_screen.dart';
import 'sell_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _editNameController = TextEditingController();
  final TextEditingController _editPhoneController = TextEditingController();

  void _showEditProfileDialog(BuildContext context) {
    _editNameController.text = AppState.nameNotifier.value;
    _editPhoneController.text = AppState.phoneNotifier.value;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _editNameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                labelStyle: TextStyle(color: AppTheme.textMedium, fontWeight: FontWeight.normal, fontSize: 13),
                floatingLabelStyle: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 14),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.borderMedium, width: 1.5)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primary, width: 2)),
              ),
              style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _editPhoneController,
              decoration: InputDecoration(
                labelText: "Phone Number",
                labelStyle: TextStyle(color: AppTheme.textMedium, fontWeight: FontWeight.normal, fontSize: 13),
                floatingLabelStyle: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 14),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.borderMedium, width: 1.5)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primary, width: 2)),
              ),
              style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: AppTheme.textMedium),
            child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              AppState.nameNotifier.value = _editNameController.text;
              AppState.phoneNotifier.value = _editPhoneController.text;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Profile updated successfully!"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppState.userRoleNotifier,
      key: ValueKey(AppState.userRoleNotifier.value),
      builder: (context, role, child) {
        final isBuyer = role == "Buyer";

        return Scaffold(
          backgroundColor: const Color(0xffF8FAFC),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Premium Cover-Styled Header with Gradient Background
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 50, bottom: 35, left: 24, right: 24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.bgHeaderGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Top Settings & Title Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Opacity(
                            opacity: 0,
                            child: IconButton(
                              onPressed: null,
                              icon: Icon(Icons.settings, size: 26),
                            ),
                          ),
                          const Text(
                            "Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              letterSpacing: -0.5,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Profile Avatar Stack
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.bgCard, 
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: AppTheme.bgCard,
                              backgroundImage: NetworkImage(
                                "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200",
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _showEditProfileDialog(context),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.bgCard, 
                                  shape: BoxShape.circle,
                                  boxShadow: AppTheme.shadowSmall,
                                ),
                                child: Icon(Icons.edit_rounded, color: AppTheme.primary, size: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Text Notifiers
                      ValueListenableBuilder<String>(
                        valueListenable: AppState.nameNotifier,
                        builder: (context, name, child) {
                          return Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          );
                        }
                      ),
                      const SizedBox(height: 5),
                      ValueListenableBuilder<String>(
                        valueListenable: AppState.emailNotifier,
                        builder: (context, email, child) {
                          return Text(
                            email,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }
                      ),
                      const SizedBox(height: 4),
                      ValueListenableBuilder<String>(
                        valueListenable: AppState.phoneNotifier,
                        builder: (context, phone, child) {
                          return Text(
                            phone,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                      ),
                      const SizedBox(height: 24),
                      // Statistics Panels
                      _buildStatisticsPanel(isBuyer),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Profile Options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard, 
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.borderMedium, width: 1.5),
                      boxShadow: AppTheme.shadowSmall,
                    ),
                    child: Column(
                      children: isBuyer
                          ? _buildBuyerOptions(context)
                          : _buildSellerOptions(context),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsPanel(bool isBuyer) {
    if (isBuyer) {
      return ValueListenableBuilder<List<Product>>(
        valueListenable: AppState.wishlistNotifier,
        builder: (context, wishlist, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatCard("Total Orders", "3", Icons.shopping_bag_rounded),
              const SizedBox(width: 16),
              _buildStatCard("Saved Items", wishlist.length.toString(), Icons.favorite_rounded),
            ],
          );
        },
      );
    } else {
      return ValueListenableBuilder<List<Product>>(
        valueListenable: AppState.productsNotifier,
        builder: (context, products, child) {
          final sellerName = AppState.nameNotifier.value;
          final myListings = products.where((p) => p.sellerName == sellerName).toList();
          final activeCount = myListings.where((p) => !p.isSold).length;
          final soldCount = myListings.where((p) => p.isSold).length;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatCard("Active Items", activeCount.toString(), Icons.check_circle_rounded),
              const SizedBox(width: 16),
              _buildStatCard("Items Sold", soldCount.toString(), Icons.monetization_on_rounded),
            ],
          );
        },
      );
    }
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.16), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBuyerOptions(BuildContext context) {
    return [
      _buildProfileTile(
        icon: Icons.shopping_bag_outlined,
        title: "My Orders",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrdersScreen()),
          );
        },
      ),
      Divider(height: 1, indent: 56, endIndent: 20, color: AppTheme.borderMedium),
      _buildProfileTile(
        icon: Icons.favorite_border_rounded,
        title: "Saved Items",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WishlistScreen()),
          );
        },
      ),
      Divider(height: 1, indent: 56, endIndent: 20, color: AppTheme.borderMedium),
      _buildProfileTile(
        icon: Icons.chat_bubble_outline_rounded,
        title: "Messages",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MessagesScreen()),
          );
        },
      ),
      Divider(height: 1, indent: 56, endIndent: 20, color: AppTheme.borderMedium),
      _buildProfileTile(
        icon: Icons.location_on_outlined,
        title: "Address",
        onTap: () => _showMockMessage(context, "Address Management UI"),
      ),
      Divider(height: 1, indent: 56, endIndent: 20, color: AppTheme.borderMedium),
      _buildProfileTile(
        icon: Icons.payment_outlined,
        title: "Payment Methods",
        onTap: () => _showMockMessage(context, "Payment Cards UI"),
      ),
      Divider(height: 1, indent: 56, endIndent: 20, color: AppTheme.borderMedium),
      _buildProfileTile(
        icon: Icons.help_outline_rounded,
        title: "Help & Support",
        onTap: () => _showMockMessage(context, "Support Tickets UI"),
      ),
      Divider(height: 1, indent: 56, endIndent: 20, color: AppTheme.borderMedium),
      _buildProfileTile(
        icon: Icons.logout_rounded,
        title: "Logout",
        textColor: Colors.redAccent,
        iconColor: Colors.redAccent,
        onTap: () => _performLogout(context),
      ),
    ];
  }

  List<Widget> _buildSellerOptions(BuildContext context) {
    return [
      _buildProfileTile(
        icon: Icons.list_alt_rounded,
        title: "My Listings",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyListingsScreen()),
          );
        },
      ),
      Divider(height: 1, indent: 56, endIndent: 20, color: AppTheme.borderMedium),
      _buildProfileTile(
        icon: Icons.publish_rounded,
        title: "Upload Product",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Scaffold(body: SellScreen())),
          );
        },
      ),
      Divider(height: 1, indent: 56, endIndent: 20, color: AppTheme.borderMedium),
      _buildProfileTile(
        icon: Icons.analytics_outlined,
        title: "Sales Report",
        onTap: () => _showMockMessage(context, "Sales Analytics UI"),
      ),
      Divider(height: 1, indent: 56, endIndent: 20, color: AppTheme.borderMedium),
      _buildProfileTile(
        icon: Icons.shopping_bag_outlined,
        title: "Orders Received",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrdersScreen(initialIndex: 1)),
          );
        },
      ),
      Divider(height: 1, indent: 56, endIndent: 20, color: AppTheme.borderMedium),
      _buildProfileTile(
        icon: Icons.chat_bubble_outline_rounded,
        title: "Messages",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Scaffold(body: MessagesScreen())),
          );
        },
      ),
      Divider(height: 1, indent: 56, endIndent: 20, color: AppTheme.borderMedium),
      _buildProfileTile(
        icon: Icons.settings_outlined,
        title: "Settings",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        },
      ),
      Divider(height: 1, indent: 56, endIndent: 20, color: AppTheme.borderMedium),
      _buildProfileTile(
        icon: Icons.logout_rounded,
        title: "Logout",
        textColor: Colors.redAccent,
        iconColor: Colors.redAccent,
        onTap: () => _performLogout(context),
      ),
    ];
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final displayIconColor = iconColor ?? AppTheme.primary;
    final displayTextColor = textColor ?? AppTheme.textDark;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: displayIconColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: displayIconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: displayTextColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textLight),
      onTap: onTap,
    );
  }

  void _showMockMessage(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        content: Text("This is a dummy action representing feature integration.", style: TextStyle(color: AppTheme.textMedium, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Ok", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        content: Text("Are you sure you want to logout?", style: TextStyle(color: AppTheme.textMedium, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: AppTheme.textMedium, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // pop dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
