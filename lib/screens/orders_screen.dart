import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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

  // Mock Purchase orders
  final List<Map<String, dynamic>> _mockPurchases = [
    {
      "orderId": "ORD-92837",
      "pTitle": "Calculus Textbook (Stewart)",
      "pPrice": 45.00,
      "date": "July 08, 2026",
      "status": "Delivered",
      "image": "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500",
    },
    {
      "orderId": "ORD-20394",
      "pTitle": "Scientific Calculator (Casio)",
      "pPrice": 22.00,
      "date": "July 07, 2026",
      "status": "Shipped",
      "image": "https://images.unsplash.com/photo-1574607383476-f517f220d398?w=500",
    },
    {
      "orderId": "ORD-11029",
      "pTitle": "Inorganic Chemistry Notes",
      "pPrice": 12.00,
      "date": "July 05, 2026",
      "status": "Delivered",
      "image": "https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=500",
    }
  ];

  // Mock Sales orders received
  final List<Map<String, dynamic>> _mockSales = [
    {
      "orderId": "ORD-88129",
      "pTitle": "Engineering Graph Book",
      "pPrice": 8.00,
      "customer": "Sarah Ahmed",
      "date": "July 09, 2026",
      "status": "Processing",
      "image": "https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=500",
    },
    {
      "orderId": "ORD-87723",
      "pTitle": "Medical Lab Coat (L size)",
      "pPrice": 25.00,
      "customer": "Usman Ali",
      "date": "July 04, 2026",
      "status": "Completed",
      "image": "https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=500",
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: AppTheme.bgCard,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark),
        ),
        title: Text(
          "My Orders",
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderLight, width: 1),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textMedium,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.shadowSmall,
              ),
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(text: "Purchases"),
                Tab(text: "Sales Received"),
              ],
            ),
          ),
        ),
        shape: Border(bottom: BorderSide(color: AppTheme.borderMedium, width: 1.5)),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPurchasesTab(),
          _buildSalesTab(),
        ],
      ),
    );
  }

  Widget _buildPurchasesTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: _mockPurchases.length,
      itemBuilder: (context, index) {
        final order = _mockPurchases[index];
        final isDelivered = order["status"] == "Delivered";

        Color statusTextColor;
        Color statusBgColor;
        if (isDelivered) {
          statusTextColor = const Color(0xff10B981);
          statusBgColor = const Color(0xffECFDF5);
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
                  child: AppTheme.buildProductImage(order["image"]),
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
                          order["orderId"],
                          style: TextStyle(color: AppTheme.textLight, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            order["status"].toUpperCase(),
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
                      order["pTitle"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.textDark, letterSpacing: -0.2),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "\$${order["pPrice"].toStringAsFixed(2)}",
                          style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primary, fontSize: 14),
                        ),
                        Text(
                          order["date"],
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
  }

  Widget _buildSalesTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: _mockSales.length,
      itemBuilder: (context, index) {
        final order = _mockSales[index];
        final isCompleted = order["status"] == "Completed";

        Color statusTextColor;
        Color statusBgColor;
        if (isCompleted) {
          statusTextColor = const Color(0xff10B981);
          statusBgColor = const Color(0xffECFDF5);
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
                  child: AppTheme.buildProductImage(order["image"]),
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
                          order["orderId"],
                          style: TextStyle(color: AppTheme.textLight, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            order["status"].toUpperCase(),
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
                      order["pTitle"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.textDark, letterSpacing: -0.2),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Buyer: ${order["customer"]}",
                      style: TextStyle(color: AppTheme.textMedium, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "\$${order["pPrice"].toStringAsFixed(2)}",
                          style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primary, fontSize: 14),
                        ),
                        Text(
                          order["date"],
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
  }
}

