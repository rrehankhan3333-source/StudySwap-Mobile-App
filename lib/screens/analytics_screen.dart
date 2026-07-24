import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  String _selectedFilter = "Last 7 Days"; // "Today", "Last 7 Days", "Last 30 Days", "This Month", "Custom"
  DateTimeRange? _customDateRange;
  String _activeTrendToggle = "Revenue"; // "Revenue" or "Orders"
  
  late AnimationController _chartAnimController;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _chartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartAnimController,
      curve: Curves.fastOutSlowIn,
    );
    _chartAnimController.forward();
  }

  @override
  void dispose() {
    _chartAnimController.dispose();
    super.dispose();
  }

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

  bool _isWithinFilter(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_selectedFilter == "Today") {
      return date.year == now.year && date.month == now.month && date.day == now.day;
    } else if (_selectedFilter == "Last 7 Days") {
      final weekAgo = today.subtract(const Duration(days: 7));
      return date.isAfter(weekAgo) || date.isAtSameMomentAs(weekAgo);
    } else if (_selectedFilter == "Last 30 Days") {
      final monthAgo = today.subtract(const Duration(days: 30));
      return date.isAfter(monthAgo) || date.isAtSameMomentAs(monthAgo);
    } else if (_selectedFilter == "This Month") {
      return date.year == now.year && date.month == now.month;
    } else if (_selectedFilter == "Custom" && _customDateRange != null) {
      final start = DateTime(_customDateRange!.start.year, _customDateRange!.start.month, _customDateRange!.start.day);
      final end = DateTime(_customDateRange!.end.year, _customDateRange!.end.month, _customDateRange!.end.day, 23, 59, 59);
      return date.isAfter(start) && date.isBefore(end);
    }
    return true;
  }

  void _changeFilter(String filter) async {
    if (filter == "Custom") {
      final pickerRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2025),
        lastDate: DateTime.now().add(const Duration(days: 1)),
        initialDateRange: _customDateRange ?? DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        ),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppTheme.primary,
                onPrimary: Colors.white,
                surface: AppTheme.bgCard,
                onSurface: AppTheme.textDark,
              ),
            ),
            child: child!,
          );
        },
      );
      if (pickerRange != null) {
        setState(() {
          _selectedFilter = "Custom";
          _customDateRange = pickerRange;
        });
        _chartAnimController.reset();
        _chartAnimController.forward();
      }
    } else {
      setState(() {
        _selectedFilter = filter;
      });
      _chartAnimController.reset();
      _chartAnimController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final curUid = AppState.currentUser?.uid;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text(
          "Seller Analytics",
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
      ),
      body: ValueListenableBuilder<List<Product>>(
        valueListenable: AppState.productsNotifier,
        builder: (context, products, _) {
          final sellerProducts = products.where((p) => p.sellerId == curUid).toList();

          return ValueListenableBuilder<List<OrderModel>>(
            valueListenable: AppState.sellerReceivedOrdersNotifier,
            builder: (context, orders, child) {
              // 1. Gather all received orders matching the date filter
              final filteredOrders = orders.where((order) {
                final date = order.completedAt ?? order.createdAt ?? _parseOrderDate(order.date);
                if (date == null) return false;
                return _isWithinFilter(date);
              }).toList();

              // 2. Compute Revenues (Excluding Cancelled Orders)
              double totalRevenue = 0.0;
              double monthlyRevenue = 0.0;
              double weeklyRevenue = 0.0;
              double dailyRevenue = 0.0;

              for (var o in filteredOrders) {
                if (o.status.toLowerCase() != 'cancelled') {
                  totalRevenue += o.price * o.quantity;
                  final oDate = o.completedAt ?? o.createdAt ?? _parseOrderDate(o.date);
                  if (oDate != null) {
                    if (oDate.year == now.year && oDate.month == now.month) {
                      monthlyRevenue += o.price * o.quantity;
                    }
                    final weekAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
                    if (oDate.isAfter(weekAgo) || oDate.isAtSameMomentAs(weekAgo)) {
                      weeklyRevenue += o.price * o.quantity;
                    }
                    if (oDate.year == now.year && oDate.month == now.month && oDate.day == now.day) {
                      dailyRevenue += o.price * o.quantity;
                    }
                  }
                }
              }

              // 3. Customer analytics
              final Map<String, List<OrderModel>> buyerCompletedOrders = {};
              for (var o in orders) {
                if (o.status.toLowerCase() != 'cancelled') {
                  buyerCompletedOrders.putIfAbsent(o.buyerId, () => []).add(o);
                }
              }

              int totalCustomers = 0;
              int returningCustomers = 0;
              int newCustomers = 0;

              for (var buyerId in buyerCompletedOrders.keys) {
                final buyerOrders = buyerCompletedOrders[buyerId]!;
                
                final hasOrderInRange = buyerOrders.any((o) {
                  final oDate = o.completedAt ?? o.createdAt ?? _parseOrderDate(o.date);
                  return oDate != null && _isWithinFilter(oDate);
                });

                if (hasOrderInRange) {
                  totalCustomers++;
                  
                  if (buyerOrders.length > 1) {
                    returningCustomers++;
                  } else {
                    final oDate = buyerOrders.first.completedAt ?? buyerOrders.first.createdAt ?? _parseOrderDate(buyerOrders.first.date);
                    if (oDate != null && _isWithinFilter(oDate)) {
                      newCustomers++;
                    }
                  }
                }
              }

              // 4. Product Insights
              final Map<String, int> productSalesCounts = {};
              final Map<String, double> productRevenues = {};
              final Map<String, String> productImages = {};
              final Map<String, String> productTitles = {};

              for (var o in filteredOrders) {
                if (o.status.toLowerCase() != 'cancelled') {
                  productSalesCounts[o.productId] = (productSalesCounts[o.productId] ?? 0) + o.quantity;
                  productRevenues[o.productId] = (productRevenues[o.productId] ?? 0.0) + (o.price * o.quantity);
                  productImages[o.productId] = o.image;
                  productTitles[o.productId] = o.pTitle;
                }
              }

              final List<_ProductAnalyticData> topSelling = [];
              for (var id in productSalesCounts.keys) {
                topSelling.add(_ProductAnalyticData(
                  title: productTitles[id] ?? "Unknown",
                  imageUrl: productImages[id] ?? "",
                  salesCount: productSalesCounts[id] ?? 0,
                  revenue: productRevenues[id] ?? 0.0,
                ));
              }
              topSelling.sort((a, b) => b.salesCount.compareTo(a.salesCount));
              final top3Products = topSelling.take(3).toList();

              // Lowest Selling Products (owned by the seller, sorted by active orders sales count ascending)
              final List<_ProductAnalyticData> lowestSelling = [];
              for (var p in sellerProducts) {
                final sales = productSalesCounts[p.id] ?? 0;
                final rev = productRevenues[p.id] ?? 0.0;
                lowestSelling.add(_ProductAnalyticData(
                  title: p.title,
                  imageUrl: p.imageUrl,
                  salesCount: sales,
                  revenue: rev,
                ));
              }
              lowestSelling.sort((a, b) => a.salesCount.compareTo(b.salesCount));
              final lowest3Products = lowestSelling.take(3).toList();

              // Stock Status Lists
              final lowStockProducts = sellerProducts.where((p) => p.stock <= 5 && p.stock > 0).toList();
              final outOfStockProducts = sellerProducts.where((p) => p.stock == 0).toList();

              // 5. Order Status Breakdown
              final int pendingCount = filteredOrders.where((o) => o.status.toLowerCase() == 'pending').length;
              final int processingCount = filteredOrders.where((o) => o.status.toLowerCase() == 'processing').length;
              final int shippedCount = filteredOrders.where((o) => o.status.toLowerCase() == 'shipped').length;
              final int deliveredCount = filteredOrders.where((o) => o.status.toLowerCase() == 'delivered' || o.status.toLowerCase() == 'completed').length;
              final int cancelledCount = filteredOrders.where((o) => o.status.toLowerCase() == 'cancelled').length;
              final int totalStatused = filteredOrders.length;

              return RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 600));
                },
                color: AppTheme.primary,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Dynamic Date Filters Chips ---
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildFilterChip("Today"),
                            _buildFilterChip("Last 7 Days"),
                            _buildFilterChip("Last 30 Days"),
                            _buildFilterChip("This Month"),
                            _buildFilterChip("Custom"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Revenue Cards Grid ---
                      Text(
                        "Revenue Breakdown",
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
                          _buildRevenueCard("Total Revenue", "\$${totalRevenue.toStringAsFixed(2)}", Icons.account_balance_wallet_rounded, AppTheme.primary),
                          _buildRevenueCard("Monthly Revenue", "\$${monthlyRevenue.toStringAsFixed(2)}", Icons.calendar_month_rounded, AppTheme.secondary),
                          _buildRevenueCard("Weekly Sales", "\$${weeklyRevenue.toStringAsFixed(2)}", Icons.view_week_rounded, Colors.blueAccent.shade700),
                          _buildRevenueCard("Today's Sales", "\$${dailyRevenue.toStringAsFixed(2)}", Icons.today_rounded, AppTheme.successColor),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // --- Professional Graph Section ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppTheme.borderLight, width: 1.2),
                          boxShadow: AppTheme.shadowMedium,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Trend Visuals",
                                      style: TextStyle(
                                        color: AppTheme.textDark,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _selectedFilter == "Custom" && _customDateRange != null
                                          ? "${_customDateRange!.start.day}/${_customDateRange!.start.month} - ${_customDateRange!.end.day}/${_customDateRange!.end.month}"
                                          : "Period: $_selectedFilter",
                                      style: TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                // Toggle buttons for Revenue vs Orders Trends
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.bgLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildTrendToggleButton("Revenue", "Revenue"),
                                      _buildTrendToggleButton("Orders", "Orders"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // Dynamic Chart
                            SizedBox(
                              height: 180,
                              width: double.infinity,
                              child: AnimatedBuilder(
                                animation: _chartAnimation,
                                builder: (context, child) {
                                  return CustomPaint(
                                    painter: FlexibleChartPainter(
                                      orders: filteredOrders,
                                      filterType: _selectedFilter,
                                      customRange: _customDateRange,
                                      animationProgress: _chartAnimation.value,
                                      themeColor: _activeTrendToggle == "Revenue" ? AppTheme.primary : AppTheme.secondary,
                                      textColor: AppTheme.textMedium,
                                      parseDateHelper: _parseOrderDate,
                                      renderMode: _activeTrendToggle,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // --- Product Performance Section ---
                      Text(
                        "Product Performance",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Top / Lowest Selling Products tabs view (built dynamically inside cards)
                      _buildTitledContainer(
                        title: "🔥 Top Selling Products",
                        child: top3Products.isEmpty
                            ? _buildEmptyPerformanceState("No transaction data available.")
                            : Column(
                                children: top3Products.map((p) => _buildProductRow(p)).toList(),
                              ),
                      ),
                      const SizedBox(height: 16),
                      _buildTitledContainer(
                        title: "📉 Lowest Selling Products",
                        child: lowest3Products.isEmpty
                            ? _buildEmptyPerformanceState("No listing data available.")
                            : Column(
                                children: lowest3Products.map((p) => _buildProductRow(p, isLowPerformer: true)).toList(),
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Inventory stock alerts tables
                      _buildTitledContainer(
                        title: "⚠️ Inventory Alert status",
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Low Stock Products (count <= 5)",
                              style: TextStyle(color: AppTheme.textDark, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            if (lowStockProducts.isEmpty)
                              _buildEmptyPerformanceState("No products are currently low on stock.")
                            else
                              Column(
                                children: lowStockProducts.map((p) => _buildStockAlertRow(p.title, p.imageUrl, p.stock, AppTheme.warningColor)).toList(),
                              ),
                            const SizedBox(height: 18),
                            Text(
                              "Out of Stock Products (empty)",
                              style: TextStyle(color: AppTheme.textDark, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            if (outOfStockProducts.isEmpty)
                              _buildEmptyPerformanceState("No listings are currently out of stock.")
                            else
                              Column(
                                children: outOfStockProducts.map((p) => _buildStockAlertRow(p.title, p.imageUrl, p.stock, AppTheme.errorColor)).toList(),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // --- Customer Insights Section ---
                      Text(
                        "Customer Profiles",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.borderLight, width: 1.2),
                          boxShadow: AppTheme.shadowSmall,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildCustomerInsightElement("Total Customers", "$totalCustomers", Icons.people_alt_rounded, AppTheme.primary),
                                _buildCustomerInsightElement("Returning Buyers", "$returningCustomers", Icons.cached_rounded, AppTheme.secondary),
                                _buildCustomerInsightElement("New Buyers", "$newCustomers", Icons.person_add_rounded, AppTheme.successColor),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Container(
                              height: 1,
                              color: AppTheme.borderLight,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              "A customer is counted as 'Returning' if they have purchased more than one unique product listing from your catalog.",
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 10.5, height: 1.4),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // --- Order Status breakdown Section ---
                      Text(
                        "Fulfillment & Order Status",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.borderLight, width: 1.2),
                          boxShadow: AppTheme.shadowSmall,
                        ),
                        child: Column(
                          children: [
                            _buildStatusProgressBar("Pending Orders", pendingCount, totalStatused, AppTheme.warningColor),
                            const SizedBox(height: 14),
                            _buildStatusProgressBar("Processing Orders", processingCount, totalStatused, AppTheme.secondary),
                            const SizedBox(height: 14),
                            _buildStatusProgressBar("Shipped Orders", shippedCount, totalStatused, AppTheme.primary),
                            const SizedBox(height: 14),
                            _buildStatusProgressBar("Delivered Orders", deliveredCount, totalStatused, AppTheme.successColor),
                            const SizedBox(height: 14),
                            _buildStatusProgressBar("Cancelled Orders", cancelledCount, totalStatused, AppTheme.errorColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _changeFilter(label),
        selectedColor: AppTheme.primary,
        backgroundColor: AppTheme.bgCard,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textMedium,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 12.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppTheme.primary : AppTheme.borderLight,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildTrendToggleButton(String label, String actionVal) {
    final isActive = _activeTrendToggle == actionVal;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTrendToggle = actionVal;
        });
        _chartAnimController.reset();
        _chartAnimController.forward();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppTheme.textMedium,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight, width: 1.2),
        boxShadow: AppTheme.shadowSmall,
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
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Icon(Icons.show_chart_rounded, color: Colors.greenAccent, size: 16),
            ],
          ),
          const SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitledContainer({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight, width: 1.2),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildProductRow(_ProductAnalyticData data, {bool isLowPerformer = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AppTheme.buildProductImage(
              data.imageUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppTheme.textDark, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  "${data.salesCount} purchases",
                  style: TextStyle(color: AppTheme.textLight, fontSize: 10.5),
                ),
              ],
            ),
          ),
          Text(
            isLowPerformer ? "${data.salesCount} sold" : "\$${data.revenue.toStringAsFixed(2)}",
            style: TextStyle(
              color: isLowPerformer ? AppTheme.textDark : AppTheme.successColor,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockAlertRow(String title, String image, int stock, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AppTheme.buildProductImage(
              image,
              width: 34,
              height: 34,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppTheme.textDark, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              stock == 0 ? "OUT OF STOCK" : "$stock LEFT",
              style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInsightElement(String label, String count, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: TextStyle(color: AppTheme.textDark, fontSize: 16.5, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatusProgressBar(String label, int count, int total, Color color) {
    final double fraction = total == 0 ? 0.0 : count / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(color: AppTheme.textDark, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              "$count ($total orders)",
              style: TextStyle(color: AppTheme.textMedium, fontSize: 11.5, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: AppTheme.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPerformanceState(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _ProductAnalyticData {
  final String title;
  final String imageUrl;
  final int salesCount;
  final double revenue;

  _ProductAnalyticData({
    required this.title,
    required this.imageUrl,
    required this.salesCount,
    required this.revenue,
  });
}

class FlexibleChartPainter extends CustomPainter {
  final List<OrderModel> orders;
  final String filterType;
  final DateTimeRange? customRange;
  final double animationProgress;
  final Color themeColor;
  final Color textColor;
  final DateTime? Function(String) parseDateHelper;
  final String renderMode; // "Revenue" or "Orders"

  FlexibleChartPainter({
    required this.orders,
    required this.filterType,
    required this.customRange,
    required this.animationProgress,
    required this.themeColor,
    required this.textColor,
    required this.parseDateHelper,
    required this.renderMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final DateTime now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    List<DateTime> slots = [];
    List<String> labels = [];

    if (filterType == "Today") {
      for (int i = 0; i < 4; i++) {
        slots.add(today.add(Duration(hours: i * 6)));
        labels.add("${i * 6}h");
      }
    } else if (filterType == "Last 7 Days") {
      for (int i = 6; i >= 0; i--) {
        final d = today.subtract(Duration(days: i));
        slots.add(d);
        final dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
        labels.add(dayNames[d.weekday - 1]);
      }
    } else if (filterType == "Last 30 Days") {
      for (int i = 4; i >= 0; i--) {
        final d = today.subtract(Duration(days: i * 7));
        slots.add(d);
        labels.add("${d.day}/${d.month}");
      }
    } else if (filterType == "This Month") {
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      for (int i = 0; i < 4; i++) {
        final day = ((i * (daysInMonth - 1)) / 3).round() + 1;
        slots.add(DateTime(now.year, now.month, day));
        labels.add("W${i+1}");
      }
    } else if (filterType == "Custom" && customRange != null) {
      final daysDiff = customRange!.end.difference(customRange!.start).inDays;
      final step = math.max(1, (daysDiff / 4).round());
      for (int i = 0; i < 5; i++) {
        final d = customRange!.start.add(Duration(days: i * step));
        if (d.isBefore(customRange!.end) || d.isAtSameMomentAs(customRange!.end)) {
          slots.add(d);
          labels.add("${d.day}/${d.month}");
        }
      }
    } else {
      for (int i = 4; i >= 0; i--) {
        final d = today.subtract(Duration(days: i * 7));
        slots.add(d);
        labels.add("${d.day}/${d.month}");
      }
    }

    if (slots.isEmpty) return;

    // Aggregate values
    List<double> slotValues = List.generate(slots.length, (_) => 0.0);
    for (var o in orders) {
      final oDate = o.completedAt ?? o.createdAt ?? parseDateHelper(o.date);
      if (oDate != null) {
        int bestSlot = 0;
        int minDiff = 99999999;
        for (int i = 0; i < slots.length; i++) {
          final diff = (oDate.millisecondsSinceEpoch - slots[i].millisecondsSinceEpoch).abs();
          if (diff < minDiff) {
            minDiff = diff;
            bestSlot = i;
          }
        }
        if (renderMode == "Revenue") {
          if (o.status.toLowerCase() == 'delivered' || o.status.toLowerCase() == 'completed') {
            slotValues[bestSlot] += o.price * o.quantity;
          }
        } else {
          if (o.status.toLowerCase() != 'cancelled') {
            slotValues[bestSlot] += 1.0;
          }
        }
      }
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final paintLine = Paint()
      ..color = textColor.withOpacity(0.12)
      ..strokeWidth = 1.0;

    final double paddingLeft = 32.0;
    final double paddingBottom = 20.0;
    final double chartWidth = size.width - paddingLeft;
    final double chartHeight = size.height - paddingBottom;

    canvas.drawLine(
      Offset(paddingLeft, chartHeight),
      Offset(size.width, chartHeight),
      paintLine,
    );

    final double maxVal = slotValues.reduce(math.max);
    final double maxCeiling = maxVal == 0
        ? (renderMode == "Revenue" ? 100 : 5)
        : (renderMode == "Revenue"
            ? ((maxVal / 50).ceil() * 50).toDouble()
            : ((maxVal / 2).ceil() * 2).toDouble());

    for (int i = 1; i <= 3; i++) {
      final double y = chartHeight - (chartHeight * (i / 3));
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(size.width, y),
        paintLine,
      );

      final valLabelText = renderMode == "Revenue"
          ? "\$${(maxCeiling * (i / 3)).toInt()}"
          : (maxCeiling * (i / 3)).toStringAsFixed(1);

      textPainter.text = TextSpan(
        text: valLabelText,
        style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(2, y - 6));
    }

    textPainter.text = TextSpan(
      text: renderMode == "Revenue" ? "\$0" : "0",
      style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(2, chartHeight - 6));

    List<Offset> points = [];
    final double slotWidth = slots.length <= 1 ? chartWidth : chartWidth / (slots.length - 1);
    for (int i = 0; i < slots.length; i++) {
      final double x = paddingLeft + (i * slotWidth);
      final double valRatio = slotValues[i] / maxCeiling;
      final double y = chartHeight - (chartHeight * valRatio * animationProgress);
      points.add(Offset(x, y));

      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(color: textColor, fontSize: 9, fontWeight: FontWeight.w700),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), size.height - 14));
    }

    if (renderMode == "Revenue") {
      // Line Chart Render
      final linePaint = Paint()
        ..color = themeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;

      final fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [themeColor.withOpacity(0.35), themeColor.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(paddingLeft, 0, chartWidth, chartHeight))
        ..style = PaintingStyle.fill;

      if (points.isNotEmpty) {
        final Path path = Path();
        path.moveTo(points[0].dx, points[0].dy);

        for (int i = 0; i < points.length - 1; i++) {
          final p0 = points[i];
          final p1 = points[i + 1];
          final controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
          final controlY1 = p0.dy;
          final controlX2 = p0.dx + (p1.dx - p0.dx) / 2;
          final controlY2 = p1.dy;
          path.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
        }

        final fillPath = Path.from(path);
        fillPath.lineTo(points.last.dx, chartHeight);
        fillPath.lineTo(points.first.dx, chartHeight);
        fillPath.close();
        canvas.drawPath(fillPath, fillPaint);
        canvas.drawPath(path, linePaint);

        final dotStrokePaint = Paint()..color = Colors.white;
        final dotPaint = Paint()
          ..color = themeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;

        for (var pt in points) {
          canvas.drawCircle(pt, 4.5, dotStrokePaint);
          canvas.drawCircle(pt, 4.5, dotPaint);
        }
      }
    } else {
      // Bar Chart Render for Orders
      final barPaint = Paint()
        ..color = themeColor
        ..style = PaintingStyle.fill;

      final double barWidth = math.max(6.0, slotWidth * 0.25);
      for (var pt in points) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(pt.dx - (barWidth / 2), pt.dy, barWidth, chartHeight - pt.dy),
            const Radius.circular(4),
          ),
          barPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant FlexibleChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.orders != orders ||
        oldDelegate.filterType != filterType ||
        oldDelegate.customRange != customRange ||
        oldDelegate.renderMode != renderMode;
  }
}
