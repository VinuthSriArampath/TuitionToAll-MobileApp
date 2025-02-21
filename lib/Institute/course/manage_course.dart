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
import '../../widgets/navbar.dart';

class ManageCourse extends ConsumerStatefulWidget {
  const ManageCourse({super.key});

  @override
  ConsumerState<ManageCourse> createState() => _ManageCourseState();
}

class _ManageCourseState extends ConsumerState<ManageCourse> {
  TextEditingController searchValueController = TextEditingController();
  TextEditingController searchStudentValueController = TextEditingController();
  final String? courseBaseUrl = dotenv.env['COURSE_BASEURL'];
  final String? studentBaseUrl = dotenv.env['STUDENT_BASEURL'];

  Course? course;
  List<Student> studentList = [];
  Student? student;

  bool isSearched = false;
  bool isStudentSearched = false;

  searchCourse() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? instituteId = prefs.getString('id');

    ref.read(loadingProvider.notifier).state = true;

    String searchValue = searchValueController.text.trim();

    if (searchValue.isEmpty) {
      showAlertDialog(context, 'Username is Required', 'Please enter a username to search');
      ref.read(loadingProvider.notifier).state = false;
      return;
    }

    if (searchValue.startsWith('C')) {
      var request = http.Request('GET', Uri.parse('$courseBaseUrl/search/$searchValue/institute/$instituteId'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseString = await response.stream.bytesToString();
        if (responseString.isNotEmpty) {
          Map<String, dynamic> jsonResponse = jsonDecode(responseString);
          course = Course.fromJson(jsonResponse);
          ref.read(loadingProvider.notifier).state = false;
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
          setState(() {});
        } else {
          ref.read(loadingProvider.notifier).state = false;
          showAlertDialog(context, 'Not Found', 'Searched Course Not found in your institute');
          course = null;
          studentList.clear();
        }
      } else {
        ref.read(loadingProvider.notifier).state = false;
        showAlertDialog(context, 'Not Found', 'Searched Course Not found');
        course = null;
        studentList.clear();
        return;
      }
    } else {
      ref.read(loadingProvider.notifier).state = false;
      showAlertDialog(context, 'Invalid Username', 'Enter a Valid Course ID that starts with C');
      studentList.clear();
      return;
    }
  }

  searchStudent() async {
    ref.read(loadingProvider.notifier).state = true;
    isStudentSearched = true;
    String searchValue = searchStudentValueController.text.trim();

    if (searchValue.isEmpty) {
      showAlertDialog(context, 'Username is Required', 'Please enter a username to search');
      return;
    }

    if (searchValue.startsWith('S')) {
      var request = http.Request('GET', Uri.parse('$studentBaseUrl/search/$searchValue'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseString = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = jsonDecode(responseString);
        student = Student.fromJson(jsonResponse);
        ref.read(loadingProvider.notifier).state = false;
      } else {
        ref.read(loadingProvider.notifier).state = false;
        showAlertDialog(context, 'Not Found', 'Searched Username Not found');
        student = null;
        isStudentSearched = false;
        return;
      }
    } else {
      ref.read(loadingProvider.notifier).state = false;
      showAlertDialog(context, 'Invalid Username', 'Enter a Valid Student ID that starts with S');
      isStudentSearched = false;
      return;
    }
  }

  cancelSearch() {
    student = null;
    isStudentSearched = false;
    searchStudentValueController.text = "";
  }

  addToCourse(BuildContext context, WidgetRef ref) async {
    ref.read(loadingProvider.notifier).state = true;
    if (isStudentSearched && student != null && course != null) {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request('POST', Uri.parse('$courseBaseUrl/student/add'));
      request.body = json.encode({
        "studentId": student!.id,
        "courseId": course!.id,
        "date": DateTime.now().toIso8601String()
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        studentList.add(student!);
        student = null;
        isStudentSearched = false;
        searchStudentValueController.text = "";
        showAlertDialog(context, "Success", "Student added to the course successfully");
        ref.read(loadingProvider.notifier).state = false;
      } else {
        isStudentSearched = false;
        showAlertDialog(context, "Error", "Something went wrong");
        ref.read(loadingProvider.notifier).state = false;
      }
    } else {
      isStudentSearched = false;
      showAlertDialog(context, "Error", "Search a student first");
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Navbar(
          title: "Manage Course",
        ),
      ),
      drawer: const InstituteDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
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
                              prefixIcon: const Icon(Icons.search, color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: isLoading ? null : () => searchCourse(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "Search",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    ] else ...[
                      buildLabel("Name", ""),
                      buildLabel("Type", ""),
                      const SizedBox(height: 10),
                      const Text("Teacher Details", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      buildLabel("Teacher ID", ""),
                      buildLabel("Teacher Name", ""),
                    ],
                    const SizedBox(height: 15),
                    const Text(
                      "Search student to add",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchStudentValueController,
                            decoration: InputDecoration(
                              hintText: "Search Student",
                              prefixIcon: const Icon(Icons.search, color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: isLoading ? null : () => searchStudent(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "Search",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Column(
                      children: isStudentSearched
                          ? [
                        buildLabel("ID", student!.id),
                        buildLabel("Name", '${student?.firstName} ${student?.lastName}'),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () => cancelSearch(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("Cancel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () => addToCourse(context, ref),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("Add To Course", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        )
                      ]
                          : [
                        buildLabel("ID", 'N/A'),
                        buildLabel("Name", 'N/A'),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Students enrolled with this course",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                    text: value ?? "N/A",
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
