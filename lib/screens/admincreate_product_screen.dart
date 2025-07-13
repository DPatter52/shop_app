// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCreateProduct extends StatefulWidget {
  const AdminCreateProduct({super.key});

  @override
  State<AdminCreateProduct> createState() => _AdminCreateProductState();
}

class _AdminCreateProductState extends State<AdminCreateProduct> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  void _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'imageUrl': _imageUrlController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product added successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create New Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (value) => value!.isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Description"),
                validator:
                    (value) => value!.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter price';
                  final price = double.tryParse(value);
                  return (price == null || price < 0)
                      ? 'Enter valid price'
                      : null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: "Image URL"),
                validator: (value) => value!.isEmpty ? 'Enter image URL' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addProduct,
                child: const Text("Add Product"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
