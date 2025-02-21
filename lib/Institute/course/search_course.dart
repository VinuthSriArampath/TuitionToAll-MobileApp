import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tutiontoall_mobile/model/course_model.dart';
import 'package:tutiontoall_mobile/model/student_model.dart';
import 'package:tutiontoall_mobile/providers/loading_provider.dart';

import '../../widgets/alert.dart';
import '../../widgets/institute_drawer.dart';
import '../../widgets/institute_navbar.dart';

class SearchCourse extends ConsumerStatefulWidget {
  const SearchCourse({super.key});

  @override
  ConsumerState<SearchCourse> createState() => _SearchCourseState();
}

class _SearchCourseState extends ConsumerState<SearchCourse> {
  TextEditingController searchValueController = TextEditingController();
  final String? courseBaseUrl=dotenv.env['COURSE_BASEURL'];
  final String? studentBaseUrl=dotenv.env['STUDENT_BASEURL'];

  Course? course;
  List<Student> studentList=[];

  bool isSearched = false;

  @override
  void initState() {
    loadInstituteCourse();
    super.initState();
  }

  searchCourse() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? instituteId = prefs.getString('id');

    ref.read(loadingProvider.notifier).state = true;

    String searchValue = searchValueController.text.trim();

    if (searchValue.isEmpty) {
      showAlertDialog(context,'Username is Required', 'Please enter a username to search');
      ref.read(loadingProvider.notifier).state=false;
      return;
    }

    if (searchValue.startsWith('C')) {
      var request = http.Request('GET', Uri.parse('$courseBaseUrl/search/$searchValue/institute/$instituteId'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseString=await response.stream.bytesToString();
        if(responseString.isNotEmpty){
          Map<String,dynamic> jsonResponse=jsonDecode(responseString);
          course=Course.fromJson(jsonResponse);
          ref.read(loadingProvider.notifier).state=false;
          studentList.clear();
          for (var student in course!.studentCoursesList) {
            var studentRequest = http.Request('GET', Uri.parse('$studentBaseUrl/search/${student.studentId}'));
            http.StreamedResponse studentResponse = await studentRequest.send();

            if (studentResponse.statusCode == 200) {
              String studentResponseString = await studentResponse.stream.bytesToString();

              if (studentResponseString.isNotEmpty) {
                Map<String, dynamic> studentJson = jsonDecode(studentResponseString);
                Student tempStudent = Student.fromJson(studentJson);
                studentList.add(tempStudent);
              }
            }
          }
          setState(() {
          });
        }else{
          print(responseString);
          ref.read(loadingProvider.notifier).state=false;
          showAlertDialog(context,'Not Found', 'Searched Course Not found in you institute');
          course=null;
          studentList.clear();
        }

      }
      else {
        ref.read(loadingProvider.notifier).state=false;
        showAlertDialog(context,'Not Found', 'Searched Course Not found');
        course=null;
        studentList.clear();
        return;
      }
    } else {
      ref.read(loadingProvider.notifier).state=false;
      showAlertDialog(context,'Invalid Username', 'Enter an Valid Course ID starts with C');
      studentList.clear();
      return;
    }
  }

  loadInstituteCourse() async {
    studentList=[];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? instituteId = prefs.getString('id');

    var request = http.Request('GET', Uri.parse('http://localhost:8080/courses/getAll/$instituteId'));
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();

      if (responseString.isEmpty) {
        return;
      }

      var jsonResponse = jsonDecode(responseString);

      if (jsonResponse is List) {
        if (jsonResponse.isNotEmpty) {
          jsonResponse = jsonResponse[0];
        } else {
          return;
        }
      }
      course = Course.fromJson(jsonResponse);

      studentList.clear(); // Clear previous students
      for (var student in course!.studentCoursesList) {
        var studentRequest = http.Request('GET', Uri.parse('$studentBaseUrl/search/${student.studentId}'));
        http.StreamedResponse studentResponse = await studentRequest.send();

        if (studentResponse.statusCode == 200) {
          String studentResponseString = await studentResponse.stream.bytesToString();

          if (studentResponseString.isNotEmpty) {
            Map<String, dynamic> studentJson = jsonDecode(studentResponseString);
            Student tempStudent = Student.fromJson(studentJson);
            studentList.add(tempStudent);
          }
        }
      }
    } else {
      print("Error: ${response.reasonPhrase}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading=ref.watch(loadingProvider);
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: InstituteNavbar(
          title: "Search students",
        ),
      ),
      drawer: const InstituteDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5))
                  ],
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchValueController,
                            decoration: InputDecoration(
                              hintText: "Search Course",
                              prefixIcon: const Icon(Icons.search,
                                  color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => searchCourse(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                              color: Colors.white)
                              : const Text(
                            "Search",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("Course Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (course != null) ...[
                      buildLabel("Name", course!.name),
                      buildLabel("Type", course!.type),
                      const SizedBox(height: 10),
                      const Text("Teacher Details", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      buildLabel("Teacher ID", course!.teacherId),
                      buildLabel("Teacher Name", course!.teacherName),
                    ]else ...[
                      buildLabel("Name", ""),
                      buildLabel("Type", ""),
                      const SizedBox(height: 10),
                      const Text("Teacher Details", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      buildLabel("Teacher ID", ""),
                      buildLabel("Teacher Name", ""),
                    ],
                    const SizedBox(height: 15),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Students enrolled with this course",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (studentList.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: studentList.length,
                        itemBuilder: (context, index) {
                          Student student = studentList[index];
                          return ListTile(
                            title: Text('${student.firstName} ${student.lastName}'),
                            leading: Text(student.id),
                            subtitle: Text('Contact: ${student.contact}'),
                          );
                        },
                      ),
                    ] else ...[
                      const Text(
                        "No Students Available",
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget buildLabel(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: Colors.blueAccent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$label : ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
