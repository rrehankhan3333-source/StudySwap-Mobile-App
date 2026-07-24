import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class OrdersScreen extends StatefulWidget {
  final int initialIndex;
  const OrdersScreen({super.key, this.initialIndex = 0});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final role = AppState.userRoleNotifier.value;
    final isBuyer = role == "Buyer";

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCard,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark),
        ),
        title: Text(
          isBuyer ? "My Purchases" : "Sales Received",
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
      body: isBuyer ? _buildPurchasesTab() : _buildSalesTab(),
    );
  }

  Widget _buildPurchasesTab() {
    return ValueListenableBuilder<List<OrderModel>>(
      valueListenable: AppState.buyerOrdersNotifier,
      builder: (context, orders, child) {
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.borderMedium, width: 1.5),
                  ),
                  child: Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.textMedium),
                ),
                const SizedBox(height: 24),
                Text(
                  "No Purchases Yet",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  "Items you buy will appear here.",
                  style: TextStyle(color: AppTheme.textMedium, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          physics: const BouncingScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final isDelivered = order.status.toLowerCase() == "delivered";
            final isCancelled = order.status.toLowerCase() == "cancelled";

            Color statusTextColor;
            Color statusBgColor;
            if (isDelivered) {
              statusTextColor = const Color(0xff10B981);
              statusBgColor = const Color(0xffECFDF5);
            } else if (isCancelled) {
              statusTextColor = const Color(0xffEF4444);
              statusBgColor = const Color(0xffFEF2F2);
            } else {
              statusTextColor = const Color(0xffD97706);
              statusBgColor = const Color(0xffFEF3C7);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.bgCard, 
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderMedium, width: 1.5),
                boxShadow: AppTheme.shadowSmall,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 80,
                      width: 80,
                      child: AppTheme.buildProductImage(order.image),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.orderId,
                              style: TextStyle(color: AppTheme.textLight, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order.status.toUpperCase(),
                                style: TextStyle(
                                  color: statusTextColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 9,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          order.pTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.textDark, letterSpacing: -0.2),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "\$${order.pPrice.toStringAsFixed(2)}",
                              style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primary, fontSize: 14),
                            ),
                            Text(
                              order.date,
                              style: TextStyle(color: AppTheme.textLight, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
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
    );
  }

  Widget _buildSalesTab() {
    return ValueListenableBuilder<List<OrderModel>>(
      valueListenable: AppState.sellerReceivedOrdersNotifier,
      builder: (context, orders, child) {
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.borderMedium, width: 1.5),
                  ),
                  child: Icon(Icons.assignment_outlined, size: 64, color: AppTheme.textMedium),
                ),
                const SizedBox(height: 24),
                Text(
                  "No Sales Yet",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  "Orders you receive will show up here.",
                  style: TextStyle(color: AppTheme.textMedium, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          physics: const BouncingScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final isCompleted = order.status.toLowerCase() == "completed" || order.status.toLowerCase() == "delivered";
            final isCancelled = order.status.toLowerCase() == "cancelled";

            Color statusTextColor;
            Color statusBgColor;
            if (isCompleted) {
              statusTextColor = const Color(0xff10B981);
              statusBgColor = const Color(0xffECFDF5);
            } else if (isCancelled) {
              statusTextColor = const Color(0xffEF4444);
              statusBgColor = const Color(0xffFEF2F2);
            } else {
              statusTextColor = AppTheme.primary;
              statusBgColor = AppTheme.primaryPastel;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.bgCard, 
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderMedium, width: 1.5),
                boxShadow: AppTheme.shadowSmall,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 80,
                      width: 80,
                      child: AppTheme.buildProductImage(order.image),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.orderId,
                              style: TextStyle(color: AppTheme.textLight, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (String newStatus) async {
                                try {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Updating status to $newStatus..."),
                                      backgroundColor: AppTheme.primary,
                                      duration: const Duration(milliseconds: 600),
                                    ),
                                  );
                                  await AppState.updateOrderStatus(order.id, newStatus);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Failed to update status: $e"),
                                        backgroundColor: Colors.redAccent.shade700,
                                      ),
                                    );
                                  }
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'Pending',
                                  child: Text('Pending'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'Shipped',
                                  child: Text('Shipped'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'Delivered',
                                  child: Text('Delivered'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'Cancelled',
                                  child: Text('Cancelled'),
                                ),
                              ],
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusBgColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      order.status.toUpperCase(),
                                      style: TextStyle(
                                        color: statusTextColor,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 9,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: statusTextColor,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          order.pTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.textDark, letterSpacing: -0.2),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Buyer: ${order.customer}",
                          style: TextStyle(color: AppTheme.textMedium, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "\$${order.pPrice.toStringAsFixed(2)}",
                              style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primary, fontSize: 14),
                            ),
                            Text(
                              order.date,
                              style: TextStyle(color: AppTheme.textLight, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
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
    );
  }
}

