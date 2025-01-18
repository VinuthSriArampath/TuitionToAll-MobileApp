import 'package:flutter/material.dart';

class InstituteNavbar extends StatelessWidget {
  const InstituteNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return AppBar(
            backgroundColor: Colors.blue,
            title: const Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage('assets/logo.png'),
                ),
                SizedBox(width: 10),
                Text('Institute Dashboard', style: TextStyle(fontSize: 20)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ],
          );
        } else {
          return AppBar(
            backgroundColor: Colors.blue,
            title: Row(
              children: [
                Image.asset(
                    "logo.png",
                  width: 50,
                ) ,
                const SizedBox(width: 10),
                const Text('Institute Dashboard', style: TextStyle(fontSize: 20)),
              ],
            ),
          );
        }
      },
    );
  }
}
