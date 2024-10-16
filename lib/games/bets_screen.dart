import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../custom_app_bar.dart';

class UserBetsWidget extends StatefulWidget {
  @override
  _UserBetsWidgetState createState() => _UserBetsWidgetState();
}

class _UserBetsWidgetState extends State<UserBetsWidget> {
  List<DocumentSnapshot> _bets = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchUserBets();
  }

  Future<void> _fetchUserBets() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      setState(() {
        _error = 'User is not logged in.';
        _isLoading = false;
      });
      return;
    }

    try {
      final betsSnapshot = await FirebaseFirestore.instance
          .collection('bets')
          .where('userId', isEqualTo: userId)
          .get();

      setState(() {
        _bets = betsSnapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error fetching user bets: $e';
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'won') return Colors.green;
    if (status == 'lost') return Colors.red;
    return Colors.orange; // Pending
  }

  String _getBetResult(String status, int betAmount) {
    if (status == 'won') return '+\$${betAmount.toString()}';
    if (status == 'lost') return '-\$${betAmount.toString()}';
    return 'Pending';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(child: Text(_error));
    }

    return _bets.isEmpty
        ? Center(child: Text('No bets found.'))
        : Scaffold(
      appBar: CustomAppBar(
        title: 'Cricket',
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
            child: Text('See Bets'),
          ),
          PopupMenuItem<String>(
            value: 'Sign Out',
            child: Text('Sign Out'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: _bets.length,
        itemBuilder: (context, index) {
          final bet = _bets[index].data() as Map<String, dynamic>;
          final String status = bet['status']; // New field for status
          final int betAmount = bet['betAmount'];

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: Colors.blueAccent, width: 1),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Match: ${bet['matchName']}',
                    style: TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Teams: ${bet['teams'].join(' vs ')}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Selected Team: ${bet['selectedTeam']}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Bet Amount: \$${betAmount.toString()}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Timestamp: ${bet['timestamp'].toDate().toLocal().toString()}',
                    style: TextStyle(
                        fontSize: 14.0, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status: ${status[0].toUpperCase()}${status.substring(1)}',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(status),
                        ),
                      ),
                      Text(
                        _getBetResult(status, betAmount),
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}