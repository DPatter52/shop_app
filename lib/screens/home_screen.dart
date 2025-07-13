import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_app/screens/admindashboard_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_list_screen.dart';
import '../services/user_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/rewards_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  void _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final role = await getUserRole(user.uid);
      setState(() {
        _userRole = role;
      });
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid);

    return Scaffold(
      //Nav Bar
      appBar: AppBar(
        title: Text("Shop Home"),
        actions: [
          
          //Cart Button
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),

          // Order History Button
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
              );
            },
          ),

          // Logout Button
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final points = userData['points'] ?? 0;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_userRole == 'user')
                  Text(
                    "Your Reward Points: $points",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 20),

                // Browse Products Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductListScreen()),
                    );
                  },
                  child: const Text("Browse Products"),
                ),
                const SizedBox(height: 16),

                // Admin Dashboard Check
                if (_userRole == 'admin')
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdminDashboard()),
                      );
                    },
                    child: const Text("Admin Dashboard"),
                  ),

                // Rewards Check
                if (_userRole == 'user')
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RewardsScreen()),
                      );
                    },
                    child: Text("Rewards"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
