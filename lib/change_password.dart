import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tutiontoall_mobile/login.dart';
import 'package:http/http.dart' as http;
import 'package:tutiontoall_mobile/widgets/alert.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  late String instituteBaseUrl;
  late String teacherBaseUrl;
  late String studentBaseUrl;

  List<dynamic> institutes = [];
  List<dynamic> students = [];
  List<dynamic> teachers = [];

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController = TextEditingController();

  dynamic user;
  
  @override
  void initState() {
    super.initState();
    loadEnvAndFetchUsers();
  }

  Future<void> loadEnvAndFetchUsers() async {
    await dotenv.load(fileName: '.env');
    instituteBaseUrl = dotenv.env['INSTITUTE_BASEURL'] ?? '';
    teacherBaseUrl = dotenv.env['TEACHER_BASEURL'] ?? '';
    studentBaseUrl = dotenv.env['STUDENT_BASEURL'] ?? '';

    fetchUsers();
  }

  void changePassword() async {
    String username = usernameController.text.trim();
    String newPassword = newPasswordController.text.trim();
    String confirmNewPassword = confirmNewPasswordController.text.trim();

    if (validator(username, newPassword, confirmNewPassword)) {
      String? baseUrl;
      if (username.startsWith('I')) {
        user = institutes.firstWhere((inst) => inst['id'] == username, orElse: () => null);
        baseUrl=instituteBaseUrl;
      } else if (username.startsWith('S')) {

      } else if (username.startsWith('T')) {

      } else {
        showAlertDialog(context,'Invalid Username', 'Please ');
        return;
      }
      if (user != null) {
        try {
          final response = await http.patch(
            Uri.parse('$baseUrl/${user['id']}/updatePassword'),
            headers: {"Content-Type": "application/json"},
            body: newPassword,
          );

          if (response.statusCode == 200) {
            showAlertDialog(context, "Password updated successfully", "success");
            Navigator.pushNamed(context, '/'); // Navigate to home
          } else {
            showAlertDialog(context, "Error updating password: ${response.body}", "error");
          }
        } catch (e) {
          showAlertDialog(context, "Error updating password: $e", "error");
        }
      } else {
        showAlertDialog(context, "Invalid username for selected role", "error");
      }
    } else {
      showAlertDialog(context, "Error", "Something went wrong!");
    }
  }

  bool validator(String username, String newPassword, String confirmNewPassword) {
    final RegExp passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

    if (username.isEmpty) {
      showAlertDialog(context, "Invalid Username", "Provide a valid username!");
      return false;
    } else if (!passwordRegex.hasMatch(newPassword)) {
      showAlertDialog(context, "Invalid Password", "Password should contain at least 8 characters, 1 letter, 1 number, and 1 special character!");
      return false;
    } else if (newPassword != confirmNewPassword) {
      showAlertDialog(context, "Does Not Match", "Both new and confirm passwords should match each other!");
      return false;
    }
    return true;
  }

  Future<void> fetchUsers() async {
    try {
      final instResponse = await http.get(Uri.parse('$instituteBaseUrl/all'));
      final studResponse = await http.get(Uri.parse('$studentBaseUrl/all'));
      final teachResponse = await http.get(Uri.parse('$teacherBaseUrl/all'));
      setState(() {
        if (instResponse.statusCode == 200) institutes = jsonDecode(instResponse.body);
        if (studResponse.statusCode == 200) students = jsonDecode(studResponse.body);
        if (teachResponse.statusCode == 200) teachers = jsonDecode(teachResponse.body);
      });
    } catch (e) {
      showAlertDialog(context, "Error", "Something went wrong!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFDDF2FF),
          leading: TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF8EC6FF),
              padding: const EdgeInsets.all(8.0),
            ),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFDDF2FF),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        "logo.png",
                        width: 150,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Center(
                      child: Text(
                        "Change Password",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextField(
                      controller: confirmNewPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          changePassword();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
