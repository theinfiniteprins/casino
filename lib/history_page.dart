import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../custom_app_bar.dart';
import 'package:intl/intl.dart'; // For formatting the date

class HistoryPage extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Mines',
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
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection('users')
              .doc(userId)
              .collection('history')
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No history available.'));
            }

            return ListView.separated(
              itemCount: snapshot.data!.docs.length,
              separatorBuilder: (context, index) => Divider(thickness: 1),
              itemBuilder: (context, index) {
                var history = snapshot.data!.docs[index];

                // Convert Firestore Timestamp to DateTime
                Timestamp timestamp = history['date'];
                DateTime dateTime = timestamp.toDate();

                // Format the date using intl package
                String formattedDate =
                DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Game: ${history['Game']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (history['Game'] == 'Mines') ...[
                          Text(
                            'Amount: \$${history['amount']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Win Amount: \$${history['winAmount'].toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Mine Count: ${history['mineCount']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Opened Safe Tiles: ${history['openedSafeTiles']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ] else if (history['Game'] == 'Flip It') ...[
                          Text(
                            'Bet: ${history['bet']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Outcome: ${history['outcome']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Amount: \$${history['amount']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Result: ${history['result']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'Result: ${history['won'] ? 'Won' : 'Lost'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: history['won'] ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
