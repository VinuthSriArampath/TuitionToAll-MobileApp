import 'package:flutter/material.dart';

class InstituteNavbar extends StatelessWidget {
  const InstituteNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
      },
    );
  }
}
