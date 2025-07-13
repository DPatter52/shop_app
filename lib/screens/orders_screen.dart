import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart' as shop;

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Order History")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('orders')
                .doc(user!.uid)
                .collection('userOrders')
                .orderBy('dateTime', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No past orders.", style: TextStyle(fontSize: 18),));
          }

          final docs = snapshot.data!.docs;

          final orders =
              docs.map((doc) {
                return shop.Order.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                );
              }).toList();

          return ListView.builder(

            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ExpansionTile(
                  title: Text("Total: \$${order.amount.toStringAsFixed(2)}"),
                  subtitle: Text(
                    "Placed on: ${order.dateTime.toLocal().toString().split('.')[0]}",
                  ),
                  children:
                      order.products.map((item) {
                        return ListTile(
                          title: Text(item['title']),
                          subtitle: Text("Quantity: ${item['quantity']}"),
                          trailing: Text("\$${item['price']}"),
                        );
                      }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
