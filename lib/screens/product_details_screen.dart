import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'edit_listing_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Generate dummy alternative images for slider based on product image
    final String primaryImg = widget.product.imageUrl;
    final String catImg = widget.product.imageUrl.startsWith('assets/')
        ? widget.product.imageUrl
        : (widget.product.category == "Books" ? "assets/images/book_cover.jpg" :
           widget.product.category == "Notes" ? "assets/images/written_notes.jpg" :
           widget.product.category == "Electronics" ? "assets/images/electronics.jpg" :
           widget.product.category == "Stationery" ? "assets/images/stationery.jpg" :
           "assets/images/others.jpg");

    final List<String> dummyImages = [
      primaryImg,
      catImg,
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgCard,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Custom App Bar / Image Slider region
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        // Image PageView (with subtle gradient overlay)
                        SizedBox(
                          height: 390,
                          width: double.infinity,
                          child: PageView.builder(
                            itemCount: dummyImages.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return AppTheme.buildProductImage(
                                dummyImages[index],
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        // Dark bottom gradient overlay on image for contrast
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, Colors.black.withOpacity(0.35)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // App Bar overlay buttons
                        Positioned(
                          top: 48,
                          left: 16,
                          right: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 42,
                                width: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.borderMedium, width: 1.5),
                                  boxShadow: AppTheme.shadowMedium,
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 16),
                                ),
                              ),
                              Row(
                                  children: [
                                    Container(
                                      height: 42,
                                      width: 42,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppTheme.borderMedium, width: 1.5),
                                        boxShadow: AppTheme.shadowMedium,
                                      ),
                                      child: ValueListenableBuilder<List<Product>>(
                                        valueListenable: AppState.productsNotifier,
                                        builder: (context, items, child) {
                                          return IconButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              setState(() {
                                                AppState.toggleFavorite(widget.product);
                                              });
                                            },
                                            icon: Icon(
                                              widget.product.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                              color: widget.product.isFavorite ? AppTheme.primary : AppTheme.textDark,
                                              size: 18,
                                            ),
                                          );
                                        }
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      height: 42,
                                      width: 42,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppTheme.borderMedium, width: 1.5),
                                        boxShadow: AppTheme.shadowMedium,
                                      ),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text("Link copied! Share it with friends."),
                                              behavior: SnackBarBehavior.floating,
                                              backgroundColor: AppTheme.primary,
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.share_outlined, color: AppTheme.textDark, size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        // Page Count indicator
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.textDark.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
                            ),
                            child: Text(
                              "${_currentImageIndex + 1}/${dummyImages.length}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Product Information Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category badge and state badge row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryPastel,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  widget.product.category.toUpperCase(),
                                  style: TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xffEFFDF4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  widget.product.condition.toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xff16A34A),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Display Title
                          Text(
                            widget.product.title,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 10),
                          
                          // Price label
                          Text(
                            "\$${widget.product.price.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Seller Profile Card (Refined verified details)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xffF9FAFB),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.borderMedium, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                                  child: Text(
                                    widget.product.sellerName.isNotEmpty ? widget.product.sellerName[0].toUpperCase() : "U",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            widget.product.sellerName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.textDark,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(Icons.verified_rounded, color: AppTheme.secondary, size: 16),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Verified Campus Student",
                                        style: TextStyle(
                                          color: AppTheme.textMedium,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Rating
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${widget.product.rating}",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${widget.product.reviewsCount} reviews",
                                      style: TextStyle(color: AppTheme.textLight, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Description section
                          Text(
                            "About Resource",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.product.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textMedium,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Trust Guarantee and attributes listing
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPastel.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.primary.withOpacity(0.12), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.shield_rounded, color: AppTheme.primary, size: 20),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "StudySwap Protection: Verify the resource fully before payment on meeting.",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Attributes (Condition, Category) Detail Cards
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppTheme.bgLight,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppTheme.borderMedium, width: 1.5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Condition", style: TextStyle(color: AppTheme.textMedium, fontSize: 11, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.product.condition,
                                        style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textDark, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppTheme.bgLight,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppTheme.borderMedium, width: 1.5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Availability", style: TextStyle(color: AppTheme.textMedium, fontSize: 11, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(
                                        "In Stock",
                                        style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textDark, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Action Area
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: AppTheme.bgCard, 
                border: Border(
                  top: BorderSide(color: AppTheme.borderMedium, width: 1.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, -6),
                  )
                ],
              ),
              child: ValueListenableBuilder<String>(
                valueListenable: AppState.userRoleNotifier,
                builder: (context, role, child) {
                  final isBuyer = role == "Buyer";

                  if (isBuyer) {
                    return Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: OutlinedButton(
                              onPressed: () {
                                AppState.addToCart(widget.product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("${widget.product.title} added to cart!"),
                                    duration: const Duration(seconds: 2),
                                    action: SnackBarAction(
                                      label: "UNDO",
                                      textColor: AppTheme.secondary,
                                      onPressed: () => AppState.removeFromCart(widget.product),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppTheme.primary, width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text(
                                "Add to Cart",
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                AppState.addToCart(widget.product);
                                // Directly trigger checkout simulation
                                AppState.checkout();
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: AppTheme.bgCard,
                                    surfaceTintColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                    title: Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 56),
                                    content: Text(
                                      "Purchase Successful!\nYour order has been placed.",
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
                                            Navigator.pop(context); // pop details
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
                                "Buy Now",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Seller Options: Edit / Delete
                    return Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: OutlinedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: AppTheme.bgCard,
                                    surfaceTintColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                    title: Text("Delete Listing", style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                                    content: Text("Are you sure you want to delete '${widget.product.title}'?", style: TextStyle(color: AppTheme.textMedium)),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: Text("Cancel", style: TextStyle(color: AppTheme.textMedium, fontWeight: FontWeight.w600)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          AppState.deleteProduct(widget.product.id);
                                          Navigator.pop(ctx); // pop dialog
                                          Navigator.pop(context); // pop details
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Listing deleted successfully."),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                        child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red, width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text(
                                "Delete Listing",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditListingScreen(product: widget.product),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: const Text(
                                "Edit Listing",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
}
