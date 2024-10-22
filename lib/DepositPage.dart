import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'custom_app_bar.dart';

class DepositPage extends StatefulWidget {
  @override
  _DepositPageState createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  TextEditingController amountController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  int balance = 0;

  @override
  void initState() {
    super.initState();
    _getUserBalance();  // Fetch the current balance on page load
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  // Fetch the user's current balance from Firebase
  Future<void> _getUserBalance() async {
    try {
      if (user != null) {
        DocumentSnapshot doc = await firestore.collection('users').doc(user!.uid).get();
        var data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('balance')) {
          setState(() {
            balance = data['balance'];
          });
        }
      }
    } catch (e) {
      print('Error fetching user balance: $e');
    }
  }

  // Update the user's balance in Firebase after deposit
  Future<void> _depositAmount(int amount) async {
    try {
      if (user != null) {
        await firestore.collection('users').doc(user!.uid).update({
          'balance': FieldValue.increment(amount),
        });
        setState(() {
          balance += amount;  // Update the local balance
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Deposited ₹${amount} successfully!")),
        );
      }
    } catch (e) {
      print('Error updating balance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to deposit amount")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Deposit',
        menuItems: [
          PopupMenuItem<String>(
            value: 'Profile',
            child: Text('Profile'),
          ),
          PopupMenuItem<String>(
            value: 'History',
            child: Text('History'),
          ),
          PopupMenuItem<String>(
            value: 'Deposit',
            child: Text('Deposit'),
          ),
          PopupMenuItem<String>(
            value: 'Withdraw',
            child: Text('Withdraw'),
          ),
          PopupMenuItem<String>(
            value: 'bets',
            child: Text('Cricket Bets'),
          ),
          PopupMenuItem<String>(
            value: 'Sign Out',
            child: Text('Sign Out'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                int amount = int.tryParse(amountController.text) ?? 0;
                if (amount > 0) {
                  _depositAmount(amount);  // Update the user's balance in Firebase
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a valid amount")),
                  );
                }
              },
              child: Text('Deposit'),
            ),
          ],
        ),
      ),
    );
  }
}
