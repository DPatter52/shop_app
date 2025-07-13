import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admincreate_product_screen.dart';
import 'adminupdate_product_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _navigateToEdit(BuildContext context, DocumentSnapshot productDoc) {
    final productId = productDoc.id;
    final productData = productDoc.data() as Map<String, dynamic>;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => AdminUpdateProduct(
              productId: productId,
              productData: productData,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminCreateProduct(),
                    ),
                  );
                },
                child: const Text("Create New Product"),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Product List",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('products')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!.docs;

                  if (products.isEmpty) {
                    return const Center(child: Text("No products found."));
                  }

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final data = product.data() as Map<String, dynamic>;

                      return ListTile(
                        title: Text(data['title'] ?? 'No Title'),
                        subtitle: Text(
                          "\$${data['price']?.toStringAsFixed(2) ?? '0.00'}",
                        ),
                        onTap: () => _navigateToEdit(context, product),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
