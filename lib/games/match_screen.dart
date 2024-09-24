

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MatchDetailsScreen extends StatefulWidget {
  final dynamic match;

  MatchDetailsScreen({required this.match});

  @override
  _MatchDetailsScreenState createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  String? _selectedTeam;
  final TextEditingController _betController = TextEditingController();

  Future<void> _placeBet() async {
    final betAmount = _betController.text;
    final match = widget.match;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final balance = userDoc.data()?['balance'] as double?;
    if (_selectedTeam == null || betAmount.isEmpty) {
      // Show an error message if the required fields are not filled
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a team and enter a bet amount.')),
      );
      return;
    }

    try {
      // Create a new bet object
      final betData = {
        'matchId': match['id'],
        'matchName': match['name'],
        'teams': match['teams'],
        'venue': match['venue'],
        'selectedTeam': _selectedTeam,
        'betAmount': double.parse(betAmount),
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
      };

      // Add the bet to the Firestore collection
      await FirebaseFirestore.instance.collection('bets').add(betData);

      // Optionally show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bet placed successfully!')),
      );

      // Clear the input fields
      _betController.clear();
      setState(() {
        _selectedTeam = null;
      });
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing bet: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;

    return Scaffold(
      appBar: AppBar(
        title: Text('Match Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Match: ${match['name']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Teams: ${match['teams'].join(' vs ')}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Venue: ${match['venue']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Status: ${match['status']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Place Your Bet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _betController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Bet Amount',
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Team',
                border: OutlineInputBorder(),
              ),
              items: match['teams'].map<DropdownMenuItem<String>>((team) {
                return DropdownMenuItem<String>(
                  value: team,
                  child: Text(team),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTeam = value;
                });
              },
              value: _selectedTeam,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _placeBet,
              child: Text('Place Bet'),
            ),
          ],
        ),
      ),
    );
  }
}
