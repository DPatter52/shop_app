import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final total = cart.totalAmount;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Total: \$${total.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                final orderData = {
                  'userId': user.uid,
                  'amount': total,
                  'products':
                      cart.items.values
                          .map(
                            (item) => {
                              'title': item.title,
                              'price': item.price,
                              'quantity': item.quantity,
                            },
                          )
                          .toList(),
                  'dateTime': DateTime.now().toIso8601String(),
                };

                await FirebaseFirestore.instance
                    .collection('orders')
                    .doc(user.uid)
                    .collection('userOrders')
                    .add(orderData);

                final earnedPoints = (cart.totalAmount ~/ 10);
                final userRef = FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid);
                await FirebaseFirestore.instance.runTransaction((
                  transaction,
                ) async {
                  final snapshot = await transaction.get(userRef);
                  final currentPoints = snapshot['points'] ?? 0;
                  transaction.update(userRef, {
                    'points': currentPoints + earnedPoints,
                  });
                });

                cart.clearCart();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Order placed!")));
                Navigator.pop(context);
              },
              child: const Text("Confirm Order"),
            ),
          ],
        ),
      ),
    );
  }
}
