import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';  // Import your login page.
// import 'profile_page.dart';  // Import for profile navigation.
// import 'history_page.dart';  // Import for history navigation.
// import 'deposit_page.dart';  // Import for deposit navigation.
// import 'withdraw_page.dart';  // Import for withdraw navigation.

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<PopupMenuEntry<String>> menuItems;

  const CustomAppBar({super.key, required this.title, required this.menuItems});

  Future<void> _signOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('id');
    prefs.remove('password');

    // Navigate to login screen after sign out.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      leading: GestureDetector(
        onTap: () {
          // This assumes that '/' is the route for the home page.
          Navigator.pushNamed(context, '/');
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
        title,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      actions: [
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
              items: menuItems,
            ).then((value) {
              if (value != null) {
                switch (value) {
                  case 'Profile':
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => ProfilePage()),
                    // );
                    break;
                  case 'History':
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => HistoryPage()),
                    // );
                    break;
                  case 'Deposit':
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => DepositPage()),
                    // );
                    break;
                  case 'Withdraw':
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => WithdrawPage()),
                    // );
                    break;
                  case 'Sign Out':
                    _signOut(context);  // Sign out and clear shared preferences.
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
