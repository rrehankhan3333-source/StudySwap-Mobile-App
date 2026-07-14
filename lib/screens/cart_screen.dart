import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'product_details_screen.dart';

class CartScreen extends StatelessWidget {
  final bool isStandalone;
  const CartScreen({super.key, this.isStandalone = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: isStandalone
          ? null // Parent wrapper has its own AppBar
          : AppBar(
              backgroundColor: AppTheme.bgLight,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(
                "My Cart",
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: true,
            ),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: AppState.cartNotifier,
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPastel,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.shopping_basket_rounded, size: 54, color: AppTheme.primary),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        "Your Cart is Empty",
                        style: TextStyle(
                          fontSize: 22,
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Looks like you haven't added any study resources to your library yet.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMedium,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: 160,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Start Exploring",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Calculate fees
          final double subtotal = cart.fold<double>(0, (sum, item) => sum + (item.product.price * item.quantity));
          const double platformFee = 3.00;
          final double total = subtotal + platformFee;

          return Column(
            children: [
              // Items List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: cart.length,
                  itemBuilder: (context, index) {
                    final item = cart[index];
                    return _buildCartItemCard(context, item);
                  },
                ),
              ),
              // Checklist / Pricing Summary Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard, 
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                  border: Border(
                    top: BorderSide(color: AppTheme.borderMedium, width: 1.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 16,
                      offset: const Offset(0, -6),
                    )
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Subtotal", style: TextStyle(color: AppTheme.textMedium, fontSize: 14, fontWeight: FontWeight.bold)),
                          Text(
                            "\$${subtotal.toStringAsFixed(2)}",
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.textDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Platform Fee", style: TextStyle(color: AppTheme.textMedium, fontSize: 14, fontWeight: FontWeight.bold)),
                          Text(
                            "\$${platformFee.toStringAsFixed(2)}",
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.textDark),
                          ),
                        ],
                      ),
                      Divider(height: 32, thickness: 1.5, color: AppTheme.borderMedium),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Amount",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppTheme.textDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            "\$${total.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: AppTheme.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            AppState.checkout();
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppTheme.bgCard,
                                surfaceTintColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                title: Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 56),
                                content: Text(
                                  "Checkout Complete!\nYour order has been placed.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textDark, fontSize: 16),
                                ),
                                actionsAlignment: MainAxisAlignment.center,
                                actions: [
                                  SizedBox(
                                    width: 130,
                                    height: 44,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context); // pop dialog
                                        if (isStandalone) {
                                          Navigator.pop(context); // pop standalone categories page
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primary,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Proceed to Checkout",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: item.product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.bgCard, 
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.borderMedium, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            Container(
              height: 84,
              width: 84,
              decoration: BoxDecoration(
                color: AppTheme.bgLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AppTheme.buildProductImage(
                  item.product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.product.category,
                    style: TextStyle(color: AppTheme.textMedium, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Quantity controller
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppTheme.bgSurface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildQuantityButton(
                              icon: Icons.remove_rounded,
                              onTap: () {
                                AppState.decrementCartItem(item.product);
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "${item.quantity}",
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.textDark),
                              ),
                            ),
                            _buildQuantityButton(
                              icon: Icons.add_rounded,
                              onTap: () {
                                AppState.incrementCartItem(item.product);
                              },
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "\$${(item.product.price * item.quantity).toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Trash Button
            Container(
              decoration: BoxDecoration(
                color: AppTheme.isDarkMode ? const Color(0xff2A1C1C) : const Color(0xffFEF2F2),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.isDarkMode ? const Color(0xff4A1C1C) : const Color(0xffFEE2E2), width: 1.2),
              ),
              child: IconButton(
                onPressed: () {
                  AppState.removeFromCart(item.product);
                },
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xffEF4444), size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 24,
        width: 24,
        decoration: BoxDecoration(
          color: AppTheme.bgCard, 
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 1),
            )
          ],
        ),
        child: Icon(icon, size: 14, color: AppTheme.textDark),
      ),
    );
  }
}
