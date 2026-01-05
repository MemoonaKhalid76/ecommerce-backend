import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/cart_provider.dart';
import 'category_product_screen.dart';
import 'cart_screen.dart';
import 'search_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int selectedIndex = 0;
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final selectedCategory = categoriesData[selectedIndex];
    final cart = Provider.of<CartProvider>(context);

    // Using MediaQuery instead of SafeArea for specific top padding
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ================= CUSTOM HEADER =================
          Container(
            padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
               children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: searchController,
                      onSubmitted: (query) {
                        if (query.trim().isEmpty) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SearchResultsScreen(searchQuery: query),
                          ),
                        );
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                         hintText: 'Search Categories...',
                        border: InputBorder.none,
                         contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                 Stack(
                   clipBehavior: Clip.none,
                   children: [
                     InkWell(
                       onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                       },
                       child: const Icon(Icons.shopping_bag_outlined, size: 28),
                     ),
                     if (cart.itemCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text('${cart.itemCount}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ),
                   ],
                 ),
               ],
            ),
          ),

          // ================= MAIN CONTENT =================
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ----- LEFT NAVIGATION -----
                Container(
                  width: 110,
                  color: Colors.grey[50], // Slightly darker than white
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: categoriesData.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 0),
                    itemBuilder: (context, index) {
                      final category = categoriesData[index];
                      final isSelected = selectedIndex == index;

                      return InkWell(
                        onTap: () => setState(() => selectedIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            border: isSelected 
                              ? const Border(left: BorderSide(color: Colors.black, width: 4))
                              : Border(bottom: BorderSide(color: Colors.grey.shade200)),
                          ),
                          child: Column(
                            children: [
                              // Optional: Add Icons to CategoryModel for better visuals
                              Text(
                                category.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.black : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ----- RIGHT CONTENT (SUB-CATEGORIES) -----
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Header
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Text(
                                selectedCategory.name.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
                              ),
                              const Spacer(),
                              Text(
                                '${selectedCategory.subCategories.length} items',
                                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        
                        // Grid
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: selectedCategory.subCategories.length,
                            itemBuilder: (_, index) {
                              final sub = selectedCategory.subCategories[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => CategoryProductsScreen(category: selectedCategory.name, subCategory: sub)),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                       BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                                    ],
                                    border: Border.all(color: Colors.grey.shade100),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Placeholder Icon - In real app, map category to image/icon
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.auto_stories, color: Colors.blueGrey[300], size: 28),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        sub,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
