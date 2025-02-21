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
import 'package:tutiontoall_mobile/widgets/navbar.dart';
import 'package:http/http.dart' as http;

class UpdateCourse extends ConsumerStatefulWidget {
  const UpdateCourse({super.key});

  @override
  ConsumerState<UpdateCourse> createState() => _UpdateCourseState();
}

class _UpdateCourseState extends ConsumerState<UpdateCourse> {

  TextEditingController courseNameController = TextEditingController();
  String? courseType;

  TextEditingController searchValueController = TextEditingController();
  TextEditingController searchTeacherValueController = TextEditingController();

  String teacherBaseUrl=dotenv.env['TEACHER_BASEURL'] ?? '';
  String courseBaseUrl=dotenv.env['COURSE_BASEURL'] ?? '';

  bool isCourseSearched = false;
  bool isTeacherSearched = false;
  bool updateTeacher = false;
  Teacher? teacher;
  Course? course;



  updateCourse(BuildContext context,WidgetRef ref) async{
    if(isCourseSearched) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? instituteId = prefs.getString('id');

      ref.read(loadingProvider.notifier).state = true;
      String courseName = courseNameController.text.trim();

      if (courseName.isEmpty) {
        showAlertDialog(context, "Invalid Input", "Enter a valid Course Name");
        ref.read(loadingProvider.notifier).state = false;
        return;
      }

      if (courseType == null) {
        showAlertDialog(context, "Invalid Input", "Select a valid Course Type");
        ref.read(loadingProvider.notifier).state = false;
        return;
      }

      var headers = {
        'Content-Type': 'application/json'
      };
      var request = http.Request('PATCH',
          Uri.parse('http://localhost:8080/courses/update/$instituteId'));
      request.body = json.encode({
        "id": course!.id,
        "name": courseName,
        "type": courseType
      });
      request.headers.addAll(headers);

      http.StreamedResponse courseRes = await request.send();

      if (courseRes.statusCode == 200) {
        if(updateTeacher) {
          if(teacher != null) {
            String courseId = course!.id;
            String? teacherId = teacher?.id;
            var teacherReq = http.Request('PATCH', Uri.parse('http://localhost:8080/courses/$courseId/teachers/update/$teacherId'));

            teacherReq.headers.addAll({
              'Content-Type': 'application/json',
            });

            http.StreamedResponse teacherRes = await teacherReq.send();

            if (teacherRes.statusCode == 200) {
              showAlertDialog(context, "Success", "Course added successfully with a new teacher $teacherId!");
              ref.read(loadingProvider.notifier).state = false;
              teacher=null;
              course=null;
              updateTeacher=false;
              isTeacherSearched=false;
              isCourseSearched=false;
              return;
            }
            else {
              showAlertDialog(context, "Error", "Some thing went wrong");
              ref.read(loadingProvider.notifier).state = false;
              teacher=null;
              course=null;
              updateTeacher=false;
              isTeacherSearched=false;
              isCourseSearched=false;
              return;
            }
          }else{
            showAlertDialog(context, "Warning", "No changers to the Teacher but course details UPDATED !");
            ref.read(loadingProvider.notifier).state = false;
            teacher=null;
            course=null;
            updateTeacher=false;
            isTeacherSearched=false;
            isCourseSearched=false;
            return;
          }
        }else{
          showAlertDialog(context, "Success", "Course Updated with the same Teacher");
          ref.read(loadingProvider.notifier).state = false;
          teacher=null;
          course=null;
          updateTeacher=false;
          isTeacherSearched=false;
          isCourseSearched=false;
          return;
        }
      }
      else {
        showAlertDialog(context, "Error", "Some thing went wrong");
        ref.read(loadingProvider.notifier).state = false;
        teacher=null;
        course=null;
        updateTeacher=false;
        isTeacherSearched=false;
        isCourseSearched=false;
        return;
      }
    }else{
      showAlertDialog(context, "Error", "Search a Course to update");
      ref.read(loadingProvider.notifier).state = false;
      teacher=null;
      course=null;
      updateTeacher=false;
      isTeacherSearched=false;
      isCourseSearched=false;
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
        Map<String,dynamic> jsonResponse=jsonDecode(responseString);
        course=Course.fromJson(jsonResponse);
        courseNameController.text=course!.name;
        courseType=course!.type;
        ref.read(loadingProvider.notifier).state=false;
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

  searchTeacher() async{
    ref.read(loadingProvider.notifier).state = true;
    if(isCourseSearched) {
      isTeacherSearched = true;
      String searchValue = searchTeacherValueController.text.trim();

      if (searchValue.isEmpty) {
        showAlertDialog(context, 'Username is Required',
            'Please enter a username to search');
        return;
      }

      if (searchValue.startsWith('T')) {
        var request = http.Request(
            'GET', Uri.parse('$teacherBaseUrl/search/$searchValue'));

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          String responseString = await response.stream.bytesToString();
          Map<String, dynamic> jsonResponse = jsonDecode(responseString);
          teacher = Teacher.fromJson(jsonResponse);
          ref
              .read(loadingProvider.notifier)
              .state = false;
        }
        else {
          ref.read(loadingProvider.notifier).state = false;
          showAlertDialog(context, 'Not Found', 'Searched Username Not found');
          teacher = null;
          isTeacherSearched = false;
          return;
        }
      } else {
        ref.read(loadingProvider.notifier).state = false;
        showAlertDialog(context, 'Invalid Username','Enter an Valid Teacher ID starts with T');
        isTeacherSearched = false;
        return;
      }
    }else{
      ref.read(loadingProvider.notifier).state = false;
      showAlertDialog(context, 'Error','Cannot Search a teacher without a searched course');
      isTeacherSearched = false;
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Navbar(
          title: "Update course",
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
              TextField(
                controller: courseNameController,
                decoration: const InputDecoration(
                  labelText: 'Course name',
                  prefixIcon: Icon(Icons.work),
                ),
                onChanged: (value) {

                },
              ),
              const SizedBox(
                height: 10,
              ),
              DropdownButtonFormField(
                value: courseType,
                items: ['Physical', 'Online', 'Physical/Online'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    courseType=newValue!;
                  });
                },
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                icon: const Icon(Icons.arrow_drop_down),
                dropdownColor: Colors.white,
                isExpanded: true,
                hint: const Text("Course Type"),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text("Teacher Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Checkbox(
                      value: updateTeacher,
                      onChanged: (bool? value) {
                        setState(() {
                          updateTeacher = value!;
                        });
                      }),
                  const Text(
                    "Change Teacher ?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const SizedBox(height: 16),
              updateTeacher?
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchTeacherValueController,
                      decoration: InputDecoration(
                        hintText: "Search Teacher",
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
                        : () => searchTeacher(),
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
              ):
              const SizedBox(height: 15),
              if (teacher != null) ...[
                buildLabel("Teacher Id", teacher!.id),
                buildLabel("Teacher Name", teacher!.firstName+teacher!.lastName),
              ]else if(course != null) ...[
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
                      : () => updateCourse(context,ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
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
                      : const Text("Update Course",
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
