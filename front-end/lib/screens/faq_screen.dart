import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Professional background
      appBar: AppBar(title: const Text('Frequently Asked Questions'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _FaqTile(
            question: 'How do I place an order?',
            answer: 'Simply browse our collection, add items to your cart, and click "Proceed to Checkout". You can pay via Cash on Delivery.',
          ),
          SizedBox(height: 12),
          _FaqTile(
            question: 'What payment methods do you accept?',
            answer: 'Currently, we support Cash on Delivery (COD) for all orders nationwide.',
          ),
          SizedBox(height: 12),
          _FaqTile(
            question: 'How can I track my order?',
            answer: 'Go to "My Account" > "My Orders" to see your order history and current status.',
          ),
           SizedBox(height: 12),
          _FaqTile(
            question: 'What is your return policy?',
            answer: 'We accept returns within 7 days of delivery if the item is damaged or incorrect. Please contact support.',
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        iconColor: Colors.black,
        shape: const Border(), // Removes default divider
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
