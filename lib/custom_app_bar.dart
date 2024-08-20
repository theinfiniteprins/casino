import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<PopupMenuEntry<String>> menuItems;

  CustomAppBar({required this.title, required this.menuItems});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      leading: GestureDetector(
        onTap: () {

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
        style: TextStyle(
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
            backgroundImage: AssetImage('assets/menu.png'),
            radius: 30,
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
