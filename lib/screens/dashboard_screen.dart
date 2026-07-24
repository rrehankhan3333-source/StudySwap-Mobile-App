import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'sell_screen.dart';
import 'orders_screen.dart';
import 'my_listings_screen.dart';
import 'analytics_screen.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  DateTime? _parseOrderDate(String dateStr) {
    try {
      final clean = dateStr.split(',').first.trim(); // E.g. "23 Jul 2026"
      final parts = clean.split(' ');
      if (parts.length >= 3) {
        final day = int.parse(parts[0]);
        final monthStr = parts[1].toLowerCase();
        final year = int.parse(parts[2]);

        final monthsList = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"];
        final month = monthsList.indexOf(monthStr) + 1;
        if (month > 0) {
          return DateTime(year, month, day);
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final curUid = AppState.currentUser?.uid;
    final now = DateTime.now();
    final weekdayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
    final monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    final formattedDate = "${weekdayNames[now.weekday - 1]}, ${monthNames[now.month - 1]} ${now.day}, ${now.year}";

    final hour = now.hour;
    String greeting = "Welcome back";
    if (hour < 12) {
      greeting = "Good morning";
    } else if (hour < 17) {
      greeting = "Good afternoon";
    } else {
      greeting = "Good evening";
    }

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text(
          "Seller Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppTheme.textDark),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppTheme.primary),
            onPressed: () {
              // AppState handles active stream updates automatically, this just plays tactile feedback/trigger refresh
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Dashboard metrics updated in real-time"),
                  duration: Duration(milliseconds: 800),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Product>>(
        valueListenable: AppState.productsNotifier,
        builder: (context, products, child) {
          final sellerProducts = products.where((p) => p.sellerId == curUid).toList();

          return ValueListenableBuilder<List<OrderModel>>(
            valueListenable: AppState.sellerReceivedOrdersNotifier,
            builder: (context, orders, child) {
              // 1. Calculations & Summary
              final int totalProducts = sellerProducts.length;
              final int activeListings = sellerProducts.where((p) => p.status.toLowerCase() == 'active' && !p.isSold).length;
              final int lowStockCount = sellerProducts.where((p) => p.stock <= 5 && p.stock > 0).length;
              final int outOfStockCount = sellerProducts.where((p) => p.stock == 0).length;

              final int totalOrders = orders.length;
              final int pendingOrders = orders.where((o) => o.status.toLowerCase() == 'pending').length;
              final int deliveredOrders = orders.where((o) => o.status.toLowerCase() == 'delivered').length;

              final completedOrders = orders.where((o) => o.status.toLowerCase() == 'delivered').toList(); // Strictly Delivered
              int soldProducts = 0;
              for (var o in completedOrders) {
                soldProducts += o.quantity;
              }

              double totalRevenue = 0.0;
              for (var o in completedOrders) {
                totalRevenue += o.price * o.quantity;
              }

              double todayRevenue = 0.0;
              int todayOrdersCount = 0;
              double monthlyRevenue = 0.0;
              int monthlyOrdersCount = 0;
              double lastMonthRevenue = 0.0;

              for (var order in completedOrders) {
                final oDate = order.completedAt ?? order.createdAt ?? _parseOrderDate(order.date);
                if (oDate != null) {
                  if (oDate.year == now.year && oDate.month == now.month && oDate.day == now.day) {
                    todayRevenue += order.price * order.quantity;
                    todayOrdersCount++;
                  }
                  if (oDate.year == now.year && oDate.month == now.month) {
                    monthlyRevenue += order.price * order.quantity;
                    monthlyOrdersCount++;
                  }
                  final lastMonthDate = DateTime(now.year, now.month - 1, 1);
                  if (oDate.year == lastMonthDate.year && oDate.month == lastMonthDate.month) {
                    lastMonthRevenue += order.price * order.quantity;
                  }
                }
              }

              double growthPercentage = 0.0;
              if (lastMonthRevenue > 0) {
                growthPercentage = ((monthlyRevenue - lastMonthRevenue) / lastMonthRevenue) * 100;
              } else if (monthlyRevenue > 0) {
                growthPercentage = 100.0;
              }

              final recentOrders = orders.take(5).toList();

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Welcome & Seller Profile Header ---
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.borderLight, width: 1.2),
                        boxShadow: AppTheme.shadowSmall,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppTheme.primaryPastel,
                            child: Icon(Icons.storefront_rounded, color: AppTheme.primary, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                ValueListenableBuilder<String>(
                                  valueListenable: AppState.nameNotifier,
                                  builder: (context, name, child) {
                                    return Text(
                                      "$greeting, $name!",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppTheme.textDark,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Revenue Card (Inspired by Amazon/Shopify) ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppTheme.premiumShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "TOTAL REVENUE",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              if (growthPercentage >= 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.trending_up, color: Colors.greenAccent, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        "+${growthPercentage.toStringAsFixed(1)}%",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.trending_down, color: Colors.redAccent, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${growthPercentage.toStringAsFixed(1)}%",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "\$${totalRevenue.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 1.2,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Today's Sales ($todayOrdersCount)",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "\$${todayRevenue.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Monthly Revenue ($monthlyOrdersCount)",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "\$${monthlyRevenue.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- Overview Statistics Section ---
                    Text(
                      "Store Metrics",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 14),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.48,
                      children: [
                        _buildMetricCard(
                          title: "Active Listings",
                          value: "$activeListings",
                          icon: Icons.storefront_rounded,
                          iconColor: AppTheme.primary,
                          detail: "Of $totalProducts listed",
                        ),
                        _buildMetricCard(
                          title: "Orders Received",
                          value: "$totalOrders",
                          icon: Icons.shopping_bag_rounded,
                          iconColor: AppTheme.secondary,
                          detail: "$pendingOrders pending",
                        ),
                        _buildMetricCard(
                          title: "Sold Products",
                          value: "$soldProducts",
                          icon: Icons.check_circle_outline_rounded,
                          iconColor: AppTheme.successColor,
                          detail: "Delivered: $deliveredOrders",
                        ),
                        _buildMetricCard(
                          title: "Low / Out of Stock",
                          value: "${lowStockCount + outOfStockCount}",
                          icon: Icons.warning_amber_rounded,
                          iconColor: AppTheme.errorColor,
                          detail: "$lowStockCount low, $outOfStockCount empty",
                          alertStyle: (lowStockCount + outOfStockCount) > 0,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // --- Quick Actions ---
                    Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                      children: [
                        _buildActionButton(
                          context,
                          label: "Add Product",
                          icon: Icons.add_circle_outline_rounded,
                          color: AppTheme.primary,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SellScreen()),
                            );
                          },
                        ),
                        _buildActionButton(
                          context,
                          label: "View Orders",
                          icon: Icons.receipt_long_rounded,
                          color: AppTheme.secondary,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const OrdersScreen()),
                            );
                          },
                        ),
                        _buildActionButton(
                          context,
                          label: "My Listings",
                          icon: Icons.format_list_bulleted_rounded,
                          color: Colors.blueAccent.shade700,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MyListingsScreen()),
                            );
                          },
                        ),
                        _buildActionButton(
                          context,
                          label: "Analytics",
                          icon: Icons.analytics_outlined,
                          color: AppTheme.successColor,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // --- Recent Orders Section ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recent Sales",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textDark,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (orders.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const OrdersScreen()),
                              );
                            },
                            child: Text(
                              "View All",
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (orders.isEmpty)
                      _buildEmptyStateCard(
                        icon: Icons.receipt_outlined,
                        text: "No recent orders received yet.",
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentOrders.length,
                        itemBuilder: (context, index) {
                          final order = recentOrders[index];
                          final statusColor = _statusColorLookup(order.status);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.bgCard,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppTheme.borderLight, width: 1.2),
                              boxShadow: AppTheme.shadowSmall,
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: AppTheme.buildProductImage(
                                    order.image,
                                    width: 46,
                                    height: 46,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.pTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppTheme.textDark,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            "Buyer: ${order.customer}",
                                            style: TextStyle(
                                              color: AppTheme.textLight,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(Icons.circle, size: 3, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Text(
                                            order.date.split(',').first.trim(),
                                            style: TextStyle(
                                              color: AppTheme.textMuted,
                                              fontSize: 10.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "\$${order.pPrice.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: AppTheme.textDark,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        order.status.toUpperCase(),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 8.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 28),

                    // --- Recent Notifications Section ---
                    Text(
                      "Recent Alerts",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 14),

                    ValueListenableBuilder<List<AppNotification>>(
                      valueListenable: AppState.notificationsNotifier,
                      builder: (context, notifications, _) {
                        final sellerAlerts = notifications
                            .where((n) => n.title.toLowerCase().contains("stock") || n.title.toLowerCase().contains("order") || n.type == "Sales")
                            .take(3)
                            .toList();

                        if (sellerAlerts.isEmpty) {
                          return _buildEmptyStateCard(
                            icon: Icons.notifications_none_rounded,
                            text: "No recent dashboard alerts.",
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: sellerAlerts.length,
                          itemBuilder: (context, index) {
                            final notification = sellerAlerts[index];
                            Color alertColor = AppTheme.primary;
                            IconData alertIcon = Icons.notifications_rounded;

                            if (notification.title.toLowerCase().contains("low")) {
                              alertColor = AppTheme.warningColor;
                              alertIcon = Icons.warning_amber_rounded;
                            } else if (notification.title.toLowerCase().contains("out of stock") || notification.body.toLowerCase().contains("out")) {
                              alertColor = AppTheme.errorColor;
                              alertIcon = Icons.error_outline_rounded;
                            } else if (notification.title.toLowerCase().contains("order") || notification.title.toLowerCase().contains("sale")) {
                              alertColor = AppTheme.successColor;
                              alertIcon = Icons.add_shopping_cart_rounded;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.bgCard,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: notification.isRead ? AppTheme.borderLight : alertColor.withOpacity(0.3),
                                  width: notification.isRead ? 1.2 : 1.5,
                                ),
                                boxShadow: AppTheme.shadowSmall,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: alertColor.withOpacity(0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(alertIcon, color: alertColor, size: 16),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notification.title,
                                          style: TextStyle(
                                            color: AppTheme.textDark,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notification.body,
                                          style: TextStyle(
                                            color: AppTheme.textMedium,
                                            fontSize: 11,
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notification.time,
                                          style: TextStyle(
                                            color: AppTheme.textMuted,
                                            fontSize: 9.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _statusColorLookup(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'shipped':
        return AppTheme.primary;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.textMedium;
    }
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required String detail,
    bool alertStyle = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: alertStyle ? iconColor.withOpacity(0.8) : AppTheme.borderLight,
          width: alertStyle ? 1.5 : 1.2,
        ),
        boxShadow: alertStyle
            ? [
                BoxShadow(
                  color: iconColor.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : AppTheme.shadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              Text(
                value,
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: alertStyle ? iconColor : AppTheme.textMuted,
                  fontSize: 9.5,
                  fontWeight: alertStyle ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight, width: 1.2),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textMuted, size: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard({
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight, width: 1.2),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: AppTheme.textMuted),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textLight,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
