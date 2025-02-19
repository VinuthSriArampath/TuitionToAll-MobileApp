import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutiontoall_mobile/model/course_model.dart';
import 'package:tutiontoall_mobile/model/teacher_model.dart';
import 'package:tutiontoall_mobile/providers/loading_provider.dart';
import 'package:tutiontoall_mobile/widgets/alert.dart';
import 'package:tutiontoall_mobile/widgets/institute_drawer.dart';
import 'package:tutiontoall_mobile/widgets/institute_navbar.dart';
import 'package:http/http.dart' as http;

class DeleteCourse extends ConsumerStatefulWidget {
  const DeleteCourse({super.key});

  @override
  ConsumerState<DeleteCourse> createState() => _DeleteCourseState();
}

class _DeleteCourseState extends ConsumerState<DeleteCourse> {

  TextEditingController searchValueController = TextEditingController();

  String teacherBaseUrl=dotenv.env['TEACHER_BASEURL'] ?? '';
  String courseBaseUrl=dotenv.env['COURSE_BASEURL'] ?? '';

  bool isCourseSearched = false;

  Course? course;



  deleteCourse(BuildContext context,WidgetRef ref) async{
    if(isCourseSearched) {
      String courseId=course!.id;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? instituteId = prefs.getString('id');

      ref.read(loadingProvider.notifier).state = true;

      var request = http.Request('DELETE', Uri.parse('http://localhost:8080/courses/delete/$courseId/from/$instituteId'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        showAlertDialog(context, "Success", "Successfully Course Removed from the institute!");
        ref.read(loadingProvider.notifier).state = false;
        isCourseSearched =false;
        course=null;
        return;
      }else {
        showAlertDialog(context, "Error", "Some thing went wrong");
        ref.read(loadingProvider.notifier).state = false;
        isCourseSearched =false;
        course=null;
        return;
      }
    }else{
      showAlertDialog(context, "Error", "Search a Course to delete");
      ref.read(loadingProvider.notifier).state = false;
      isCourseSearched =false;
      course=null;
      return;
    }
  }

  searchCourse() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? instituteId = prefs.getString('id');

    ref.read(loadingProvider.notifier).state = true;

    isCourseSearched = true;
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
        if(responseString.isEmpty){
          ref.read(loadingProvider.notifier).state=false;
          showAlertDialog(context,'Not Found', 'Searched Course Not found');
          course=null;
          isCourseSearched=false;
          return;
        }else{
          Map<String,dynamic> jsonResponse=jsonDecode(responseString);
          course=Course.fromJson(jsonResponse);
          ref.read(loadingProvider.notifier).state=false;
          return;
        }

      }
      else {
        ref.read(loadingProvider.notifier).state=false;
        showAlertDialog(context,'Not Found', 'Searched Course Not found');
        course=null;
        isCourseSearched=false;
        return;
      }
    } else {
      ref.read(loadingProvider.notifier).state=false;
      showAlertDialog(context,'Invalid Username', 'Enter an Valid Course ID starts with C');
      isCourseSearched=false;
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: InstituteNavbar(
          title: "Delete course",
        ),
      ),
      drawer: const InstituteDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
              const SizedBox(
                height: 15,
              ),
              const Text("Course Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 15,
              ),
              if (course != null) ...[
                buildLabel("Course Name", course!.name),
                buildLabel("Course Type", course!.type),
              ]else ...[
                buildLabel("Course Name", ""),
                buildLabel("Course Type", ""),
              ],
              const SizedBox(height: 15),
              const Text("Teacher Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              if (course != null) ...[
                buildLabel("Teacher Id", course!.teacherId),
                buildLabel("Teacher Name", course!.teacherName),
              ]else ...[
                buildLabel("Teacher Id", ""),
                buildLabel("Teacher Name", ""),
              ],
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () => deleteCourse(context,ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text("Delete Course",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLabel(String label, String value) {
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
          // Label and value
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
