import 'package:casino/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'games/bets_screen.dart';
import 'login_page.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<PopupMenuEntry<String>> menuItems;

  const CustomAppBar({super.key, required this.title, required this.menuItems});

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Sign out and clear shared preferences.
  Future<void> _signOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
    await prefs.remove('password');
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      leading: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipOval(
            child: Image.asset(
              'assets/logo.png',
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      title: Text(
        widget.title,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      actions: [
        // Use StreamBuilder to listen to Firestore for balance updates in real-time
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots(), // Real-time listener for the user's document
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Row(
                  children: [
                    const CircularProgressIndicator(color: Colors.yellow),
                  ],
                ),
              );
            }

            if (snapshot.hasData && snapshot.data!.exists) {
              double balance = snapshot.data!['balance'] ?? 0;

              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.yellow, // Border color
                      width: 2, // Border width
                    ),
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/coin_icon.jpg',  // Replace with your coin icon
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '\$$balance',  // Display the current balance
                        style: const TextStyle(
                          color: Colors.yellow,  // Color to differentiate the balance
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
        GestureDetector(
          onTap: () {
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                double.infinity,
                kToolbarHeight,
                0,
                0,
              ),
              items: widget.menuItems,
            ).then((value) {
              if (value != null) {
                switch (value) {
                  case 'Profile':
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                    break;
                  case 'History':
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryPage()));
                    break;
                  case 'Deposit':
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => DepositPage()));
                    break;
                  case 'Withdraw':
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => WithdrawPage()));
                    break;
                  case 'Sign Out':
                    _signOut(context);
                    break;
                  case 'bets':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserBetsWidget()),
                    );
                    break;
                }
              }
            });
          },
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/menu.png'),
            radius: 20,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}
