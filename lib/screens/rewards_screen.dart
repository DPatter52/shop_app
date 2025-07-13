import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  Future<int> _getUserPoints() async {
    final user = FirebaseAuth.instance.currentUser;
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
    return (doc.data()?['points'] ?? 0) as int;
  }

  Future<void> _redeemReward(
    BuildContext context,
    String rewardId,
    int cost,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid);

    final userDoc = await userRef.get();
    final currentPoints = (userDoc.data()?['points'] ?? 0) as int;

    if (currentPoints >= cost) {
      await userRef.update({'points': FieldValue.increment(-cost)});
      await FirebaseFirestore.instance.collection('redemptions').add({
        'userId': user.uid,
        'rewardId': rewardId,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Reward redeemed!')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Not enough points')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _getUserPoints(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final userPoints = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: const Text('Rewards')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Your Points: $userPoints',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('rewards')
                          .snapshots(),
                  builder: (context, rewardSnapshot) {
                    if (!rewardSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final rewards = rewardSnapshot.data!.docs;

                    return ListView.builder(
                      itemCount: rewards.length,
                      itemBuilder: (context, index) {
                        final reward = rewards[index];
                        final title = reward['title'];
                        final cost = reward['cost'];
                        final description = reward['description'];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: ListTile(
                            title: Text(title),
                            subtitle: Text('$description\nCost: $cost points'),
                            isThreeLine: true,
                            trailing: ElevatedButton(
                              onPressed:
                                  () => _redeemReward(context, reward.id, cost),
                              child: const Text("Redeem"),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
