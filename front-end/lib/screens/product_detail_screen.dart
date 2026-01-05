import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import 'cart_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<Product> relatedProducts = [];
  int currentImage = 0;
  final PageController _imageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadRelated();
  }

  void _loadRelated() async {
    final products = await ApiService.fetchProducts();
    if (mounted) {
      setState(() {
        relatedProducts = products
            .where(
              (p) =>
                  p.category == widget.product.category &&
                  p.id != widget.product.id,
            )
            .toList();
      });
    }
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    final images = widget.product.images.isNotEmpty
        ? widget.product.images
        : [];

    return Scaffold(
      backgroundColor: Colors.white,
      
      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      cart.itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ================= BODY =================
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // ================= IMAGE GALLERY =================
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    SizedBox(
                      height: 400,
                      child: PageView.builder(
                        controller: _imageController,
                        itemCount: images.length,
                        onPageChanged: (index) {
                          setState(() {
                            currentImage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Container(
                            color: Colors.grey[50],
                            child: CachedNetworkImage(
                              imageUrl: images[index],
                              fit: BoxFit.contain, // Contain usually looks better for books/products
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Center(child: Icon(Icons.error, size: 80, color: Colors.grey)),
                            ),
                          );
                        },
                      ),
                    ),

                    // -------- DOT INDICATORS --------
                    if (images.length > 1)
                      Positioned(
                        bottom: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            images.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: currentImage == i ? 20 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: currentImage == i
                                    ? Colors.black87
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // ================= PRODUCT DETAILS =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.product.category.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Title
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      
                      const SizedBox(height: 12),

                      // Price & Rating
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rs ${widget.product.discountedPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (widget.product.discount > 0) ...[
                            Text(
                              'Rs ${widget.product.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '-${widget.product.discount}%',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Mock Ratings (to make it look like a real ecommerce app)
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          const Text(
                            '4.8',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(124 verified reviews)',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Description Title
                      const Text(
                         'Description', // Updated Heading
                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                       ),
                       const SizedBox(height: 12),
                       
                      // Short Description
                      Text(
                        widget.product.description,
                        style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[800]),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Full Description (if different)
                      if (widget.product.fulldescription.isNotEmpty && widget.product.fulldescription != widget.product.description)
                        Text(
                           widget.product.fulldescription,
                           style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[800]),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ================= RELATED PRODUCTS =================
                if (relatedProducts.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'You might also like',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: relatedProducts.length,
                          itemBuilder: (context, index) {
                            final p = relatedProducts[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(product: p),
                                  ),
                                );
                              },
                              child: Container(
                                width: 160,
                                margin: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                        child: CachedNetworkImage(
                                          imageUrl: p.images.isNotEmpty ? p.images.first : '',
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(color: Colors.grey[200]),
                                          errorWidget: (context, url, error) =>
                                              const Center(child: Icon(Icons.image, color: Colors.grey)),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.w600, height: 1.2),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Rs ${p.discountedPrice.toStringAsFixed(0)}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                      ),
                    ],
                  ),

                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
          
          // ================= BOTTOM ACTIONS =================
          Container(
             padding: const EdgeInsets.all(16).copyWith(top: 20),
             decoration: BoxDecoration(
               color: Colors.white,
               boxShadow: [
                 BoxShadow(
                   color: Colors.black.withOpacity(0.05),
                   blurRadius: 10,
                   offset: const Offset(0, -5),
                 ),
               ],
             ),
             child: SafeArea(
               child: Row(
                 children: [
                    // Favorite Button placeholder (optional)


                   Expanded(
                     child: ElevatedButton(
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.black,
                         foregroundColor: Colors.white,
                         elevation: 0,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                         padding: const EdgeInsets.symmetric(vertical: 16),
                       ),
                       onPressed: widget.product.inStock
                           ? () {
                               cart.addToCart(widget.product);
                               ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(
                                   content: const Text('Added to bag'),
                                   margin: const EdgeInsets.all(20),
                                   behavior: SnackBarBehavior.floating,
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                 ),
                               );
                             }
                           : null,
                       child: Text(
                         widget.product.inStock ? 'Add to Bag' : 'Out of Stock',
                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                       ),
                     ),
                   ),
                 ],
               ),
             ),
          ),
        ],
      ),
    );
  }
}
