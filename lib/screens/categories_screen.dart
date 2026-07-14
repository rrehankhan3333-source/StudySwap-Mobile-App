import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final String? initialCategory;
  const CategoriesScreen({super.key, this.initialCategory});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late String _selectedCategory;

  final List<String> _categories = [
    "All",
    "Books",
    "Notes",
    "Electronics",
    "Stationery",
    "Others"
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? "All";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCard,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 64,
        leading: Navigator.canPop(context)
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard, 
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.borderLight, width: 1.2),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 16),
                    ),
                  ),
                ),
              )
            : null,
        title: Text(
          "All Categories",
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<List<CartItem>>(
            valueListenable: AppState.cartNotifier,
            builder: (context, cart, child) {
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard, 
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.borderLight, width: 1.2),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CategoriesCartWrapperScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.shopping_cart_rounded, color: AppTheme.textDark, size: 20),
                    ),
                  ),
                  if (cart.isNotEmpty)
                    Positioned(
                      right: 12,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          "${cart.fold<int>(0, (sum, item) => sum + item.quantity)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            }
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Sidebar menu (styled premium and modern)
          Container(
            width: 108,
            decoration: BoxDecoration(
              color: Color(0xffF5F4F9),
              border: Border(
                right: BorderSide(color: AppTheme.borderMedium, width: 1.5),
              ),
            ),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected ? AppTheme.shadowSmall : null,
                      border: isSelected
                          ? Border(
                              left: BorderSide(color: AppTheme.primary, width: 4),
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        category,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? AppTheme.primary : AppTheme.textMedium,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Right Grid View of products
          Expanded(
            child: ValueListenableBuilder<List<Product>>(
              valueListenable: AppState.productsNotifier,
              builder: (context, products, child) {
                // Filter by category
                final filteredProducts = _selectedCategory == "All"
                    ? products.where((p) => !p.isSold).toList()
                    : products.where((p) => p.category == _selectedCategory && !p.isSold).toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category_outlined, size: 52, color: AppTheme.textLight.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        Text(
                          "No products found",
                          style: TextStyle(color: AppTheme.textMedium, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.70,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return _buildCategoryProductCard(context, product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryProductCard(BuildContext context, Product product) {
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
        decoration: BoxDecoration(
          color: AppTheme.bgCard, 
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.borderMedium, width: 1.5),
          boxShadow: AppTheme.shadowSmall,
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with rounded corners and overlays
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.bgLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AppTheme.buildProductImage(
                        product.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Saved Heart marker
                  Positioned(
                    right: 6,
                    top: 6,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          AppState.toggleFavorite(product);
                        });
                      },
                      child: Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard, 
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.shadowSmall,
                        ),
                        child: Icon(
                          product.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: product.isFavorite ? AppTheme.primary : AppTheme.textMedium,
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Title
            Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            // Price & condition tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$${product.price.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppTheme.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPastel,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Mint",
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 9,
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

// Simple wrapper screen to allow clicking Cart Icon from Categories and going back
class CategoriesCartWrapperScreen extends StatelessWidget {
  const CategoriesCartWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCard,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 64,
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: AppTheme.bgCard, 
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderLight, width: 1.2),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 16),
              ),
            ),
          ),
        ),
        title: Text("My Cart", style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
        centerTitle: true,
      ),
      body: const CartScreen(isStandalone: true),
    );
  }
}
