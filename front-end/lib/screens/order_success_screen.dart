import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Order Placed Successfully!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Payment Method: Cash on Delivery'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Determine if we should go to specific tab of HomeScreen later if needed
                // For now, just pop until first seems okay, BUT customer requested "Back to Home Screen Navigation"
                // Using pushAndRemoveUntil is safer to ensure we are at Home
                // Assuming HomeScreen route is named '/' or we can just popUntil first.
                // Re-reading request: "us ma home screen ka navigation daal do" (put home screen navigation there)
                
                // option 1: popUntil root
                Navigator.popUntil(context, (route) => route.isFirst);
                
                // option 2: push home if not at root (unlikely if splash -> home -> ...)
                // Better to just clear stack back to Home.
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(200, 45),
              ),
              child: const Text('Continue Shopping', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
