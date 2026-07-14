import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<String> _popularTags = [
    "Calculus",
    "Notes",
    "Physics",
    "Stationery",
    "Calculator",
    "Engineering"
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: AppTheme.bgCard,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 54,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: AppTheme.bgCard, 
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderMedium, width: 1.5),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 14),
              ),
            ),
          ),
        ),
        titleSpacing: 12,
        title: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderMedium, width: 1.5),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (val) {
              setState(() {
                _searchQuery = val.trim();
              });
            },
            style: TextStyle(fontSize: 14, color: AppTheme.textDark, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: "Search books, notes, stationery...",
              hintStyle: TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.normal),
              prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textMedium, size: 18),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close_rounded, color: AppTheme.textMedium, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = "";
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        shape: Border(bottom: BorderSide(color: AppTheme.borderMedium, width: 1.5)),
      ),
      body: _searchQuery.isEmpty
          ? _buildPopularTagsSection()
          : _buildSearchResultsSection(),
    );
  }

  Widget _buildPopularTagsSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Popular Searches",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark, letterSpacing: -0.5),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _popularTags.map((tag) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = tag;
                  setState(() {
                    _searchQuery = tag;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard, 
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderMedium, width: 1.5),
                    boxShadow: AppTheme.shadowSmall,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up_rounded, color: AppTheme.primary, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        tag,
                        style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsSection() {
    return ValueListenableBuilder<List<Product>>(
      valueListenable: AppState.productsNotifier,
      builder: (context, products, child) {
        final results = products.where((product) {
          final query = _searchQuery.toLowerCase();
          final matchesTitle = product.title.toLowerCase().contains(query);
          final matchesDesc = product.description.toLowerCase().contains(query);
          final matchesCat = product.category.toLowerCase().contains(query);
          return (matchesTitle || matchesDesc || matchesCat) && !product.isSold;
        }).toList();

        if (results.isEmpty) {
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
                    Icons.search_off_rounded,
                    size: 40,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "No items matched your search.",
                  style: TextStyle(color: AppTheme.textMedium, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.68,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final product = results[index];
            return _buildSearchProductCard(product);
          },
        );
      },
    );
  }

  Widget _buildSearchProductCard(Product product) {
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderMedium, width: 1.5),
          boxShadow: AppTheme.shadowSmall,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: AppTheme.buildProductImage(
                    product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                product.category.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: AppTheme.textMedium),
              ),
            ),
            const SizedBox(height: 6),
            // Title
            Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.textDark, letterSpacing: -0.2),
            ),
            const SizedBox(height: 6),
            // Price & Rating Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$${product.price.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      "${product.rating}",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
