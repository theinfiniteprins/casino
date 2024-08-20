import 'dart:convert';

import 'package:flutter/material.dart';
import '../custom_app_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class CricketScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            value: 'Sign Out',
            child: Text('Sign Out'),
          ),
        ],
      ),
      body: Center(
        child: RunningMatchesWidget(),
      ),
    );
  }
}


class RunningMatchesWidget extends StatefulWidget {
  @override
  _RunningMatchesWidgetState createState() => _RunningMatchesWidgetState();
}

class _RunningMatchesWidgetState extends State<RunningMatchesWidget> {
  List<Match> _matches = [];

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    final response = await http.get(Uri.parse('https://api.cricapi.com/v1/currentMatches?apikey=f764fc6c-ab15-4698-9c6e-2f315b685b93&offset=0'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        _matches = data.map((json) => Match.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load matches');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _matches.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          final match = _matches[index];
          return Card(
            margin: EdgeInsets.all(12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: Colors.blueAccent, width: 1),
            ),
            elevation: 4,
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: Text(
                '${match.teamA} vs ${match.teamB}',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                'Score: ${match.score}',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[600],
                ),
              ),
              trailing: Text(
                match.status,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: match.status == 'Live' ? Colors.green : Colors.red,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Match {
  final String teamA;
  final String teamB;
  final String score;
  final String status;

  Match({required this.teamA, required this.teamB, required this.score, required this.status});

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      teamA: json['teamA'],
      teamB: json['teamB'],
      score: json['score'],
      status: json['status'],
    );
  }
}






