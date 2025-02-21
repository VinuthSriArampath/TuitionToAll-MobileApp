import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final String title;
  const Navbar({super.key,required this.title});

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
                Text(style: const TextStyle(fontSize: 20), title),
              ],
            ),
          );
      },
    );
  }
}
