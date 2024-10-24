import 'dart:convert';
import 'package:flutter/material.dart';
import '../custom_app_bar.dart';
import 'package:http/http.dart' as http;

import 'match_screen.dart';

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
            value: 'bets',
            child: Text('Cricket Bets'),
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
  List<dynamic> _matches = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    final url = Uri.parse('https://api.cricapi.com/v1/currentMatches?apikey=bf1cd1eb-8d55-44e8-b92b-c6a04eac2ae9&offset=0');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> matches = data['data'] ?? [];
        final List<dynamic> upcomingMatches = matches.where((match) {
          return match['status'] == "Match not started";
        }).toList();

        setState(() {
          _matches = upcomingMatches;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load matches: ${response.reasonPhrase}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load matches: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(child: Text(_error));
    }

    return _matches.isEmpty
        ? Center(child: Text('No matches found.'))
        : ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: _matches.length,
      itemBuilder: (context, index) {
        final match = _matches[index];
        return GestureDetector(
          onTap: () {
            // Navigate to match details page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchDetailsScreen(match: match),
              ),
            );
          },
          child: Card(
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
                    '${match['name']}',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Teams: ${match['teams'].join(' vs ')}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Venue: ${match['venue']}',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Status: ${match['status']}',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: match['status'] == 'Live' ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

