import 'dart:async';
import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';
import 'sell_screen.dart';
import 'login_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'product_details_screen.dart';
import 'notifications_screen.dart';
import 'search_screen.dart';
import 'orders_screen.dart';
import 'settings_screen.dart';
import 'wishlist_screen.dart';
import 'my_listings_screen.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _getPage(int index, String role) {
    switch (index) {
      case 0:
        return const HomeContent();
      case 1:
        return const CategoriesScreen();
      case 2:
        return role == "Buyer" ? const CartScreen() : const SellScreen();
      case 3:
        return const MessagesScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const HomeContent();
    }
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? Colors.white
        : Colors.white.withValues(alpha: 0.55);

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      splashColor: Colors.white.withValues(alpha: 0.15),
      highlightColor: Colors.white.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(String role) {
    final isBuyer = role == "Buyer";
    final centerIcon = isBuyer
        ? Icons.shopping_basket_rounded
        : Icons.add_rounded;

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: _buildNavItem(0, Icons.home_rounded, "Home"),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        1,
                        Icons.grid_view_rounded,
                        "Catalog",
                      ),
                    ),
                    const SizedBox(width: 68), // Spacer for center button
                    Expanded(
                      child: _buildNavItem(
                        3,
                        Icons.chat_bubble_rounded,
                        "Messages",
                      ),
                    ),
                    Expanded(
                      child: _buildNavItem(4, Icons.person_rounded, "Profile"),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -18,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = 2;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: AppTheme.primary,
                        width: 4,
                      ),
                    ),
                    child: Icon(centerIcon, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the role-specific navigation drawer
  Widget _buildDrawer(BuildContext context, String role) {
    final isBuyer = role == "Buyer";
    return Drawer(
      backgroundColor: AppTheme.bgLight,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer header with premium gradient and glow
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                gradient: AppTheme.bgHeaderGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<String>(
                    valueListenable: AppState.nameNotifier,
                    builder: (context, name, _) => Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      role,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Drawer items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 10,
                ),
                children: isBuyer
                    ? _buildBuyerDrawerItems(context)
                    : _buildSellerDrawerItems(context),
              ),
            ),

            // Logout at bottom
            Divider(height: 1, color: AppTheme.borderLight),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _drawerItem(
                context,
                icon: Icons.logout_rounded,
                label: "Logout",
                color: Colors.redAccent.shade700,
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await AppState.signOut();
                  } catch (e) {
                    debugPrint("Error signing out: $e");
                  }
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Logged out successfully."),
                        backgroundColor: Colors.redAccent.shade700,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBuyerDrawerItems(BuildContext context) {
    return [
      _drawerItem(
        context,
        icon: Icons.home_rounded,
        label: "Home",
        onTap: () {
          Navigator.pop(context);
          changeTab(0);
        },
      ),
      _drawerItem(
        context,
        icon: Icons.grid_view_rounded,
        label: "Categories",
        onTap: () {
          Navigator.pop(context);
          changeTab(1);
        },
      ),
      _drawerItem(
        context,
        icon: Icons.favorite_rounded,
        label: "Saved Items",
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WishlistScreen()),
          );
        },
      ),
      _drawerItem(
        context,
        icon: Icons.shopping_bag_rounded,
        label: "My Orders",
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrdersScreen()),
          );
        },
      ),
      _drawerItem(
        context,
        icon: Icons.chat_bubble_rounded,
        label: "Messages",
        onTap: () {
          Navigator.pop(context);
          changeTab(3);
        },
      ),
      Divider(
        height: 16,
        indent: 16,
        endIndent: 16,
        color: AppTheme.borderLight,
      ),
      _drawerItem(
        context,
        icon: Icons.help_outline_rounded,
        label: "Help & Support",
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Help & Support coming soon."),
              backgroundColor: AppTheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
      _drawerItem(
        context,
        icon: Icons.settings_rounded,
        label: "Settings",
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
    ];
  }

  List<Widget> _buildSellerDrawerItems(BuildContext context) {
    return [
      _drawerItem(
        context,
        icon: Icons.dashboard_rounded,
        label: "Dashboard",
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SellerDashboardScreen()),
          );
        },
      ),
      _drawerItem(
        context,
        icon: Icons.inventory_2_rounded,
        label: "My Listings",
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyListingsScreen()),
          );
        },
      ),
      _drawerItem(
        context,
        icon: Icons.add_box_rounded,
        label: "Add New Item",
        onTap: () {
          Navigator.pop(context);
          changeTab(2);
        },
      ),
      _drawerItem(
        context,
        icon: Icons.receipt_long_rounded,
        label: "Orders",
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrdersScreen()),
          );
        },
      ),
      _drawerItem(
        context,
        icon: Icons.chat_bubble_rounded,
        label: "Messages",
        onTap: () {
          Navigator.pop(context);
          changeTab(3);
        },
      ),
      _drawerItem(
        context,
        icon: Icons.bar_chart_rounded,
        label: "Analytics",
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
          );
        },
      ),
      Divider(
        height: 16,
        indent: 16,
        endIndent: 16,
        color: AppTheme.borderLight,
      ),
      _drawerItem(
        context,
        icon: Icons.help_outline_rounded,
        label: "Help & Support",
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Help & Support coming soon."),
              backgroundColor: AppTheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
      _drawerItem(
        context,
        icon: Icons.settings_rounded,
        label: "Settings",
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
    ];
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final displayColor = color ?? AppTheme.textMedium;
    return ListTile(
      leading: Icon(icon, color: displayColor, size: 20),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: displayColor,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppState.userRoleNotifier,
      builder: (context, role, child) {
        return Scaffold(
          key: ValueKey(role),
          backgroundColor: AppTheme.bgLight,
          drawer: _buildDrawer(context, role),
          body: _getPage(_currentIndex, role),
          bottomNavigationBar: _buildBottomNavigationBar(role),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME CONTENT
// ─────────────────────────────────────────────────────────────────────────────
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final PageController _bannerController = PageController();
  int _bannerPage = 0;
  Timer? _bannerTimer;

  // Banner data per role
  static final List<Map<String, String>> _buyerBanners = [
    {
      "title": "Exchange.\nSave.\nSucceed.",
      "subtitle": "Find the best study resources near you.",
      "icon": "📚",
    },
    {
      "title": "Buy Smart.\nStudy Better.",
      "subtitle": "Affordable books and notes from fellow students.",
      "icon": "🛒",
    },
    {
      "title": "Your Next\nGreat Find.",
      "subtitle": "Hundreds of study items listed daily.",
      "icon": "🎒",
    },
  ];

  static final List<Map<String, String>> _sellerBanners = [
    {
      "title": "Sell Your\nResources.",
      "subtitle": "Turn unused books and notes into cash.",
      "icon": "💰",
    },
    {
      "title": "List in\nSeconds.",
      "subtitle": "Upload your item and reach thousands of students.",
      "icon": "📝",
    },
    {
      "title": "Earn While\nYou Study.",
      "subtitle": "Your campus marketplace for study materials.",
      "icon": "🎓",
    },
  ];

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final banners = AppState.userRoleNotifier.value == "Buyer"
          ? _buyerBanners
          : _sellerBanners;
      final nextPage = (_bannerPage + 1) % banners.length;
      _bannerController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppState.userRoleNotifier,
      builder: (context, role, _) {
        final banners = role == "Buyer" ? _buyerBanners : _sellerBanners;

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //================ CUSTOM PREMIUM APP BAR =================//
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (ctx) => Container(
                          decoration: BoxDecoration(
                            color: AppTheme.bgCard, 
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.borderLight,
                              width: 1.2,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () => Scaffold.of(ctx).openDrawer(),
                            icon: Icon(
                              Icons.menu_rounded,
                              color: AppTheme.textDark,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        "StudySwap",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                          letterSpacing: -1.0,
                        ),
                      ),
                      ValueListenableBuilder<List<AppNotification>>(
                        valueListenable: AppState.notificationsNotifier,
                        builder: (context, notifs, child) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.bgCard, 
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.borderLight,
                                    width: 1.2,
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const NotificationsScreen(),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.notifications_none_rounded,
                                    color: AppTheme.textDark,
                                    size: 22,
                                  ),
                                ),
                              ),
                              if (notifs.any((n) => !n.isRead))
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.shade700,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  //================ PREMIUM SEARCH BAR =================//
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard, 
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.borderMedium,
                          width: 1.5,
                        ),
                        boxShadow: AppTheme.shadowSmall,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: AppTheme.primary,
                            size: 22,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Search books, course codes, study guides...",
                              style: TextStyle(
                                color: AppTheme.textLight,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.mic_none_rounded,
                            color: AppTheme.textLight,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.tune_rounded,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  //================ AUTO-SLIDING BANNER =================//
                  SizedBox(
                    height: 170,
                    child: PageView.builder(
                      controller: _bannerController,
                      itemCount: banners.length,
                      onPageChanged: (page) {
                        setState(() {
                          _bannerPage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        final banner = banners[index];
                        return _buildBannerSlide(banner);
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  //================ BANNER DOTS INDICATOR =================//
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(banners.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        width: _bannerPage == index ? 22 : 6,
                        decoration: BoxDecoration(
                          color: _bannerPage == index
                              ? AppTheme.primary
                              : AppTheme.borderDark,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 28),

                  //================ CATEGORIES ROW =================//
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final state = context
                              .findAncestorStateOfType<_HomeScreenState>();
                          state?.changeTab(1);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "See All",
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Horizontal Scrolling Row for Categories (styled premium)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _CategoryCard(
                          label: "Books",
                          imagePath: "assets/images/book_cover.jpg",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CategoriesScreen(
                                  initialCategory: "Books",
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _CategoryCard(
                          label: "Notes",
                          imagePath: "assets/images/written_notes.jpg",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CategoriesScreen(
                                  initialCategory: "Notes",
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _CategoryCard(
                          label: "Electronics",
                          imagePath: "assets/images/electronics.jpg",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CategoriesScreen(
                                  initialCategory: "Electronics",
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _CategoryCard(
                          label: "Stationery",
                          imagePath: "assets/images/stationery.jpg",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CategoriesScreen(
                                  initialCategory: "Stationery",
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _CategoryCard(
                          label: "Others",
                          imagePath: "assets/images/others.jpg",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CategoriesScreen(
                                  initialCategory: "Others",
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  //================ RECOMMENDED SECTION =================//
                  ValueListenableBuilder<List<Product>>(
                    valueListenable: AppState.productsNotifier,
                    builder: (context, allProducts, child) {
                      final recommended = allProducts
                          .where((p) => !p.isSold)
                          .take(4)
                          .toList();
                      return _buildProductSection(
                        context,
                        title: "Recommended for you",
                        products: recommended,
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  //================ NEW ARRIVALS SECTION =================//
                  ValueListenableBuilder<List<Product>>(
                    valueListenable: AppState.productsNotifier,
                    builder: (context, allProducts, child) {
                      final newArrivals = allProducts
                          .where((p) => !p.isSold)
                          .toList()
                          .reversed
                          .take(4)
                          .toList();
                      return _buildProductSection(
                        context,
                        title: "New Arrivals",
                        products: newArrivals,
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  //================ POPULAR ITEMS SECTION =================//
                  ValueListenableBuilder<List<Product>>(
                    valueListenable: AppState.productsNotifier,
                    builder: (context, allProducts, child) {
                      final popular = allProducts
                          .where(
                            (p) =>
                                (p.category == "Books" ||
                                    p.category == "Electronics") &&
                                !p.isSold,
                          )
                          .toList();
                      return _buildProductSection(
                        context,
                        title: "Popular Items",
                        products: popular,
                      );
                    },
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBannerSlide(Map<String, String> banner) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Text content
            Positioned(
              left: 24,
              top: 0,
              bottom: 0,
              right: 130,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    banner["title"]!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    banner["subtitle"]!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Emoji illustration on the right
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              width: 110,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    banner["icon"]!,
                    style: const TextStyle(fontSize: 58),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSection(
    BuildContext context, {
    required String title,
    required List<Product> products,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
                letterSpacing: -0.5,
              ),
            ),
            TextButton(
              onPressed: () {
                final state = context
                    .findAncestorStateOfType<_HomeScreenState>();
                state?.changeTab(1);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "See All",
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        products.isEmpty
            ? Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard, 
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Center(
                    child: Text(
                      "No items available here.",
                      style: TextStyle(
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: products.map((product) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _buildProductCard(context, product),
                    );
                  }).toList(),
                ),
              ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 172,
        decoration: BoxDecoration(
          color: AppTheme.bgCard, 
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.borderMedium, width: 1.5),
          boxShadow: AppTheme.shadowSmall,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Category Tag Overlay & Saved Icon Overlay
            Stack(
              children: [
                Container(
                  height: 124,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.bgLight,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AppTheme.buildProductImage(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Category badge overlay
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.textDark.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                // Favorite check button overlay
                Positioned(
                  right: 8,
                  top: 8,
                  child: GestureDetector(
                    onTap: () => AppState.toggleFavorite(product),
                    child: Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard, 
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.shadowSmall,
                      ),
                      child: Icon(
                        product.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 17,
                        color: product.isFavorite
                            ? AppTheme.primary
                            : AppTheme.textMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Product Title
            Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: AppTheme.primary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),

            // Price & condition/trust badge row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$${product.price.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppTheme.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPastel,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "Active",
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final String label;
  final String imagePath;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.label,
    required this.imagePath,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: _isPressed ? 0.94 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(
                      alpha: _isPressed ? 0.08 : 0.16,
                    ),
                    blurRadius: _isPressed ? 6 : 12,
                    offset: Offset(0, _isPressed ? 2 : 5),
                  ),
                ],
                image: DecorationImage(
                  image: AssetImage(widget.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color.fromARGB(255, 12, 31, 169),
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
