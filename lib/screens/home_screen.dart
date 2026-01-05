import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';
import '../models/banner_model.dart';
import '../providers/cart_provider.dart';
import 'categories_screen.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'discount_screen.dart';
import 'search_screen.dart';
import '../widgets/skeletons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> normalProducts = [];
  List<Product> discountProducts = [];
  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

  final PageController _pageController = PageController();
  Timer? _timer;
  int currentBanner = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_pageController.hasClients) {
        currentBanner = (currentBanner + 1) % bannerItems.length;
        _pageController.animateToPage(
          currentBanner,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _loadProducts() async {
    final products = await ApiService.fetchProducts();
    setState(() {
      normalProducts = products.where((p) => p.discount == 0).toList();
      discountProducts = products.where((p) => p.discount > 0).toList();
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,

      // ================= APP BAR =================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                // 🔍 SEARCH BAR
                Expanded(
                  child: Container(
                    height: 48,
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
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        hintText: 'Search books, authors...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // 🛒 CART ICON + BADGE
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    InkWell(
                      onTap: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 24),
                      ),
                    ),
                    if (cart.itemCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Center(
                            child: Text(
                              '${cart.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            
            // ---------- BANNER ----------
            SizedBox(
              height: 180,
              child: isLoading
                  ? const BannerSkeleton()
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: bannerItems.length,
                      onPageChanged: (idx) => setState(() => currentBanner = idx),
                      itemBuilder: (_, i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: bannerItems[i].image,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: Colors.grey[200]),
                                errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
//                                   Colors.black.withOpacity(0.5),
                                      Colors.transparent, // Fix gradient later if needed
                                    ],
                                  ),
                                ),
                              ),
                              // Indicator
                              Positioned(
                                bottom: 12,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    bannerItems.length,
                                    (idx) => AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      width: currentBanner == idx ? 20 : 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: currentBanner == idx ? Colors.white : Colors.white54,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 25),

            // ---------- INFO CARDS ----------
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _infoCard(
                    Icons.local_shipping_outlined,
                    'Free Shipping\nOn orders over Rs 5000',
                    const Color(0xFFE3F2FD),
                    Colors.blue[800]!,
                  ),
                   const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DiscountProductsScreen(products: discountProducts),
                        ),
                      );
                    },
                    child: _infoCard(
                      Icons.discount_outlined,
                      'Flash Sale\nUp to 50% Off',
                      const Color(0xFFFFF3E0),
                       Colors.orange[800]!,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ---------- LOGOS ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Top Brands', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                   Text('See All', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _logo('https://fareedbookcentre.com/cdn/shop/files/fg-06.jpg'),
                  _logo('https://fareedbookcentre.com/cdn/shop/files/fg-07.jpg'),
                  _logo('https://fareedbookcentre.com/cdn/shop/files/fg-08.jpg'),
                  _logo('https://fareedbookcentre.com/cdn/shop/files/fg-09.jpg'),
                  _logo('https://fareedbookcentre.com/cdn/shop/files/fg-12.jpg?v=1722345996'),
                  _logo('https://fareedbookcentre.com/cdn/shop/files/fg-13.jpg?v=1722345997'),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ---------- PRODUCTS ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Featured Books', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  // Filter icon or view all could go here
                ],
              ),
            ),
            const SizedBox(height: 16),

            isLoading
                ? const ProductSkeletonGrid()
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.62,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: normalProducts.length,
                    itemBuilder: (_, i) {
                      final p = normalProducts[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(product: p),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image
                              Expanded(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: (p.images.isNotEmpty && p.images.first.isNotEmpty)
                                            ? CachedNetworkImage(
                                                imageUrl: p.images.first,
                                                fit: BoxFit.cover,
                                                placeholder: (_, __) => Container(color: Colors.grey[100]),
                                                errorWidget: (_, url, error) => Container(
                                                  color: Colors.grey[100],
                                                  padding: const EdgeInsets.all(4),
                                                  child: Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          error.toString().contains('host') ? 'Bad URL' : 'Error',
                                                          style: const TextStyle(fontSize: 8, color: Colors.red),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                        Text(
                                                          url, // SHOW THE URL FOR DEBUGGING
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(fontSize: 6, color: Colors.grey),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                color: Colors.grey[100],
                                                child: const Center(
                                                  child: Icon(Icons.book, size: 40, color: Colors.grey),
                                                ),
                                              ),
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                              // Details
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name, 
                                      maxLines: 2, 
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.2),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      p.category, 
                                      maxLines: 1,
                                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          'Rs ${p.price}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        const Spacer(),
                                        const Icon(Icons.star, size: 14, color: Colors.amber),
                                        Text(' 4.5', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String text, Color bgColor, Color iconColor) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
             padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(8),
             ),
             child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logo(String url) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: CachedNetworkImage(
        imageUrl: url, 
        fit: BoxFit.contain,
        placeholder: (_,__) => const SizedBox(),
      ),
    );
  }
}
