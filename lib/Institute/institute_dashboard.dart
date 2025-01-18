import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../widgets/institute_drawer.dart';
import '../widgets/institute_navbar.dart';


class InstituteDashboard extends StatefulWidget {
  const InstituteDashboard({super.key});

  @override
  InstituteDashboardState createState() => InstituteDashboardState();
}

class InstituteDashboardState extends State<InstituteDashboard> {
  int noOfStudents = 0;
  int noOfTeachers = 0;
  int noOfCourses = 0;
  List<Map<String, dynamic>> courseList = [];
  bool isLoading = true; // To show loading indicator
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchInstituteData();
  }

  Future<void> fetchInstituteData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final instituteId = prefs.getString('id');

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/institutes/search/$instituteId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          courseList = List<Map<String, dynamic>>.from(data['courseList']);
          noOfStudents = data['registeredStudents'].length;
          noOfTeachers = data['registeredTeachers'].length;
          noOfCourses = data['courseList'].length;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data. Please try again later.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: InstituteNavbar(),
      ),
      drawer: const InstituteDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard("No Of Students", noOfStudents.toString()),
                _buildStatCard("No Of Teachers", noOfTeachers.toString()),
                _buildStatCard("No Of Courses", noOfCourses.toString()),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Course Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: courseList.length,
                      itemBuilder: (context, index) {
                        final course = courseList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: Text((index + 1).toString()),
                            title: Text(course['name']),
                            subtitle: Text("Type: ${course['type']}"),
                            trailing: Text("ID: ${course['id']}"),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ) // Show error message
      ),
    );
  }

  // Helper to build stat cards
  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
