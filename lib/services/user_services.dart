import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> getUserRole(String uid) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  if (doc.exists) {
    final role = doc['role'];
    //print('getUserRole: role for $uid is $role');
    return role;
  } else {
   // print('getUserRole: no document found for $uid');
  }
  return null;
}

