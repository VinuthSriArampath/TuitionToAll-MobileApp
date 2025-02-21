import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutiontoall_mobile/model/institute_model.dart';
import 'package:tutiontoall_mobile/model/teacher_model.dart';
import 'package:tutiontoall_mobile/teacher/teacher_course_screen.dart';
import 'package:tutiontoall_mobile/widgets/alert.dart';
import 'package:tutiontoall_mobile/widgets/navbar.dart';
import 'package:tutiontoall_mobile/widgets/teacher_drawer.dart';
import 'dart:convert';

import '../model/course_model.dart';
import '../widgets/institute_drawer.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  TeacherDashboardState createState() => TeacherDashboardState();
}

class TeacherDashboardState extends State<TeacherDashboard> {
  Teacher? teacher;
  List<Institute> instituteList = [];
  List<List<Course>> instituteCourseList = [];

  @override
  void initState() {
    super.initState();
    fetchTeacherData();
  }

  Future<void> fetchTeacherData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final teacherId = prefs.getString('id') ?? '';

    var request = http.Request(
        'GET', Uri.parse('http://localhost:8080/teachers/search/$teacherId'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> jsonResponse = jsonDecode(responseString);
      Teacher teacher = Teacher.fromJson(jsonResponse);

      for (var institute in teacher.registeredInstitutes) {
        var request = http.Request('GET', Uri.parse('http://localhost:8080/institutes/search/${institute.instituteId}'));
        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          String responseString = await response.stream.bytesToString();
          Map<String, dynamic> jsonResponse = jsonDecode(responseString);
          Institute institute = Institute.fromJson(jsonResponse);

          setState(() {
            instituteList.add(institute);
            List<Course> tempCourseArray = [];
            for (var course in institute.courseList) {
              if (teacher.registeredCourses.any((c) => c.id == course.id)) {
                tempCourseArray.add(course);
              }
            }
            instituteCourseList.add(tempCourseArray);
          });
        } else {
          showAlertDialog(context, "Error", "Failed to load data");
        }
      }
    } else {
      showAlertDialog(context, "Error", "Failed to load data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Navbar(
          title: "Search teachers",
        ),
      ),
      drawer: const TeacherDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (int i = 0; i < instituteList.length; i++)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      decoration: const BoxDecoration(
                        border: Border(left: BorderSide(color: Colors.blue, width: 4)),
                      ),
                      child: Text(
                        instituteList[i].name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Adjust for responsiveness
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 3 / 2,
                      ),
                      itemCount: instituteCourseList[i].length,
                      itemBuilder: (context, j) {
                        var course = instituteCourseList[i][j];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> TeacherCourseScreen(course: course,)));
                          },
                          child: Card(
                            elevation: 3,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.asset('assets/ICT.jpeg', fit: BoxFit.cover),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    course.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
