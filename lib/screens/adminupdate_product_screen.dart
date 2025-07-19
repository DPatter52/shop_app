// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUpdateProduct extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const AdminUpdateProduct({
    super.key,
    required this.productId,
    required this.productData,
  });

  @override
  State<AdminUpdateProduct> createState() => _AdminUpdateProductState();
}

class _AdminUpdateProductState extends State<AdminUpdateProduct> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.productData['title']);
    _descController = TextEditingController(
      text: widget.productData['description'],
    );
    _priceController = TextEditingController(
      text: widget.productData['price'].toString(),
    );
    _imageUrlController = TextEditingController(
      text: widget.productData['imageUrl'],
    );
  }

  void _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
            'title': _titleController.text.trim(),
            'description': _descController.text.trim(),
            'price': double.parse(_priceController.text.trim()),
            'imageUrl': _imageUrlController.text.trim(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product updated successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _deleteProduct() async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product deleted successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Update Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,

          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: "Title"),
                        validator:
                            (value) => value!.isEmpty ? 'Enter title' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: "Description",
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Enter description' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: "Price"),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter price';
                          }
                          final price = double.tryParse(value);
                          return (price == null || price < 0)
                              ? 'Enter valid price'
                              : null;
                        },
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: "Image URL",
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Enter image URL' : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProduct,
                child: const Text("Save Changes"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 53, 39),
                  foregroundColor: Colors.white,
                ),
                onPressed: _deleteProduct,
                child: const Text("Delete Product"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
