import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'address_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Order Summary Card
          const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final item = cart.items.values.toList()[index];
                return Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                       child: item.product.images.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: item.product.images[0], 
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey[200]),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          )
                        : const Icon(Icons.image, size: 20, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${item.quantity} x Rs ${item.product.discountedPrice.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rs ${item.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          
          // Payment Method (Static for now)
          const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
             ),
             child: Row(
               children: const [
                 Icon(Icons.money, color: Colors.green),
                 SizedBox(width: 16),
                 Text('Cash on Delivery', style: TextStyle(fontWeight: FontWeight.w600)),
                 Spacer(),
                 Icon(Icons.check_circle, color: Colors.black),
               ],
             ),
          ),


          const SizedBox(height: 30),
          
          // Totals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: Colors.grey)),
              Text('Rs ${cart.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Delivery Fee', style: TextStyle(color: Colors.grey)),
              Text('Free', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 30),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Rs ${cart.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),


          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressScreen()),
              );
            },
            child: const Text('Enter Delivery Details', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
