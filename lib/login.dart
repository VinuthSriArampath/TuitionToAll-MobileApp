import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:tutiontoall_mobile/Institute/institute_dashboard.dart';
import 'package:tutiontoall_mobile/change_password.dart';
import 'package:tutiontoall_mobile/widgets/alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  login() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();
    await dotenv.load(fileName: '.env');
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (username.isEmpty) {
      showAlertDialog(context,'Username is Required', 'Please enter your username');
      return;
    } else if (password.isEmpty) {
      showAlertDialog(context,'Password is Required', 'Please enter your password');
      return;
    }

    String url;
    if (username.startsWith('I')) {
      url = dotenv.env['INSTITUTE_LOGIN']!;
    } else if (username.startsWith('S')) {
      url = dotenv.env['STUDENT_LOGIN']!;
    } else if (username.startsWith('T')) {
      url = dotenv.env['INSTITUTE_LOGIN']!;
    } else {
      showAlertDialog(context,'Invalid Username', 'Please ');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userName': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        showAlertDialog(context,'Login Success', 'Welcome Back');
        await prefs.setString('id', username );
        Navigator.push(context, MaterialPageRoute(
            builder: (context)=>const InstituteDashboard()
        ));
      } else {
        showAlertDialog(context,'Unauthorized Login', 'Check your username and password');
      }
    } catch (e) {
      showAlertDialog(context,'Error', 'Something went wrong. Please try again later.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFDDF2FF),
        child: Center(
          child:
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "logo.png",
                ),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Signup Institute',
                        style: TextStyle(color: Color(0xFF02748D), fontSize: 14),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>const ChangePassword()));
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Color(0xFF02748D), fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Copyright © 2024 TuitionToAll. All rights reserved.',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
