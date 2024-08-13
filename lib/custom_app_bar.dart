import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<PopupMenuEntry<String>> menuItems;

  CustomAppBar({required this.title, required this.menuItems});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black, // Set the AppBar color to black
      leading: GestureDetector(
        onTap: () {
          // Navigate to the home screen when the logo is tapped
          Navigator.pushNamed(context, '/');
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Add padding for a better look
          child: ClipOval(
            child: Image.asset(
              'assets/logo.png',
              width: 30,
              height: 30,
              fit: BoxFit.cover, // Ensure the image fits the circle
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white, // Set text color to white for contrast
        ),
      ),
      centerTitle: true, // Center the title text
      actions: [
        GestureDetector(
          onTap: () {
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                double.infinity, // Left position off-screen
                kToolbarHeight,  // Aligns with the app bar's height(this is app bar's default hight)
                0,               // Right position is 0 (aligned to the right edge)
                0,               // Bottom position
              ),
              items: menuItems,
            ).then((value) { // it returns "Future" (like promise in JS)
              // Handle menu option selection
              if (value != null) {
                switch (value) {
                  case 'Profile':
                    break;
                  case 'History':
                    break;
                  case 'Deposit':
                    break;
                  case 'Withdraw':
                    break;
                  case 'Sign Out':
                    break;
                }
              }
            });
          },
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/menu.png'), // Custom menu icon
            radius: 30, // Adjust the radius as needed
          ),
        ),
        SizedBox(width: 10), // Add spacing after the menu icon
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
