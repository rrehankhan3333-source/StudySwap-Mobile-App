import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'edit_listing_screen.dart';
import 'product_details_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

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
          "My Listings",
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
                Tab(text: "Active Listings"),
                Tab(text: "Sold Listings"),
              ],
            ),
          ),
        ),
        shape: Border(bottom: BorderSide(color: AppTheme.borderMedium, width: 1.5)),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where("sellerId", isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "Error reading listings: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final products = docs.map((doc) => Product.fromFirestore(doc.data(), doc.id)).toList();

          final activeListings = products.where((p) => !p.isSold).toList();
          final soldListings = products.where((p) => p.isSold).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildListingsList(activeListings, "You have no active listings."),
              _buildListingsList(soldListings, "You have no sold listings yet."),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListingsList(List<Product> listings, String emptyMessage) {
    if (listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryPastel,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.list_alt_rounded,
                size: 40,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              emptyMessage,
              style: TextStyle(
                color: AppTheme.textMedium,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final product = listings[index];
        return _buildListingCard(context, product);
      },
    );
  }

  Widget _buildListingCard(BuildContext context, Product product) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + Status Badge Overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 90,
                  width: 90,
                  child: AppTheme.buildProductImage(
                    product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: product.isSold ? const Color(0xffEF4444) : AppTheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product.isSold ? "SOLD" : "ACTIVE",
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(product: product),
                      ),
                    );
                  },
                  child: Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.textDark, letterSpacing: -0.2),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "\$${product.price.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
                // Action buttons row
                Row(
                  children: [
                    if (!product.isSold) ...[
                      GestureDetector(
                        onTap: () {
                          AppState.markItemSold(product.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("'${product.title}' marked as sold!"),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPastel,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 1.2),
                          ),
                          child: Text(
                            "Mark Sold",
                            style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditListingScreen(product: product),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppTheme.bgSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderMedium, width: 1.2),
                        ),
                        child: Text(
                          "Edit",
                          style: TextStyle(color: AppTheme.textDark, fontSize: 10, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppTheme.bgCard,
                            surfaceTintColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            title: Text(
                              "Delete Listing",
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 18),
                            ),
                            content: Text(
                              "Are you sure you want to delete '${product.title}'?", 
                              style: TextStyle(color: AppTheme.textMedium, fontSize: 14, height: 1.4)
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text("Cancel", style: TextStyle(color: AppTheme.textMedium, fontWeight: FontWeight.bold)),
                              ),
                              TextButton(
                                onPressed: () {
                                  AppState.deleteProduct(product.id);
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Listing deleted successfully."),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppTheme.isDarkMode ? const Color(0xff4A1C1C) : const Color(0xffFEE2E2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xffFCA5A5), width: 1.2),
                        ),
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
