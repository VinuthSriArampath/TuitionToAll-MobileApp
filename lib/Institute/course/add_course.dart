import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutiontoall_mobile/model/teacher_model.dart';
import 'package:tutiontoall_mobile/providers/loading_provider.dart';
import 'package:tutiontoall_mobile/widgets/alert.dart';
import 'package:tutiontoall_mobile/widgets/institute_drawer.dart';
import 'package:tutiontoall_mobile/widgets/navbar.dart';
import 'package:http/http.dart' as http;

class AddCourse extends ConsumerStatefulWidget {
  const AddCourse({super.key});

  @override
  ConsumerState<AddCourse> createState() => _AddCourseState();
}

class _AddCourseState extends ConsumerState<AddCourse> {
  TextEditingController courseNameController = TextEditingController();
  TextEditingController searchValueController = TextEditingController();
  String? courseType;
  String teacherBaseUrl=dotenv.env['TEACHER_BASEURL'] ?? '';
  String courseBaseUrl=dotenv.env['COURSE_BASEURL'] ?? '';
  bool isSearched = false;
  Teacher? teacher;



  addCourse(BuildContext context,WidgetRef ref) async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? instituteId = prefs.getString('id');

    ref.read(loadingProvider.notifier).state=true;
    String courseName=courseNameController.text.trim();

    if(courseName.isEmpty){
      showAlertDialog(context, "Invalid Input", "Enter a valid Course Name");
      ref.read(loadingProvider.notifier).state = false;
      return;
    }

    if (courseType == null) {
      showAlertDialog(context, "Invalid Input", "Select a valid Course Type");
      ref.read(loadingProvider.notifier).state = false;
      return;
    }

    if(isSearched==false){
      showAlertDialog(context, "Error", "Search a teacher to assign before add a course");
      ref.read(loadingProvider.notifier).state = false;
      return;
    }


    var courseReq = http.Request('POST', Uri.parse('$courseBaseUrl/add/$instituteId'));

    courseReq.headers.addAll({
      'Content-Type': 'application/json',
    });

    courseReq.body = json.encode({
    "name":courseName,
    "type":courseType,
    });

    http.StreamedResponse courseRes = await courseReq.send();

    if (courseRes.statusCode == 200) {

      String courseId = (await courseRes.stream.bytesToString()).replaceAll('"', '');
      String? teacherId=teacher?.id;
      var teacherReq = http.Request('POST', Uri.parse('$courseBaseUrl/$courseId/teacher/add/$teacherId'));

      teacherReq.headers.addAll({
        'Content-Type': 'application/json',
      });

      http.StreamedResponse teacherRes = await teacherReq.send();

      if (teacherRes.statusCode == 200) {
        showAlertDialog(context, "Success", "Course added successfully!");
        ref.read(loadingProvider.notifier).state = false;
        return;
      }
      else {
        showAlertDialog(context, "Error", "Some thing went wrong");
        ref.read(loadingProvider.notifier).state = false;
        return;
      }

    }
    else {
      showAlertDialog(context, "Error", "Some thing went wrong");
      ref.read(loadingProvider.notifier).state = false;
      return;
    }
  }

  search() async{
    ref.read(loadingProvider.notifier).state = true;

    isSearched = true;
    String searchValue = searchValueController.text.trim();

    if (searchValue.isEmpty) {
      showAlertDialog(context,'Username is Required', 'Please enter a username to search');
      ref.read(loadingProvider.notifier).state=false;
      return;
    }

    if (searchValue.startsWith('T')) {
      var request = http.Request('GET', Uri.parse('$teacherBaseUrl/search/$searchValue'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseString=await response.stream.bytesToString();
        Map<String,dynamic> jsonResponse=jsonDecode(responseString);
        teacher=Teacher.fromJson(jsonResponse);
        ref.read(loadingProvider.notifier).state=false;
      }
      else {
        ref.read(loadingProvider.notifier).state=false;
        showAlertDialog(context,'Not Found', 'Searched Username Not found');
        teacher=null;
        isSearched=false;
        return;
      }
    } else {
      ref.read(loadingProvider.notifier).state=false;
      showAlertDialog(context,'Invalid Username', 'Enter an Valid Teacher ID starts with T');
      isSearched=false;
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
          title: "Add course",
        ),
      ),
      drawer: const InstituteDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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
                height: 10,
              ),
              const Text("Teacher Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchValueController,
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
                        : () => search(),
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
              if (teacher != null) ...[
                buildLabel("Teacher Id", teacher!.id),
                buildLabel("Teacher Name", teacher!.firstName+teacher!.lastName),
              ]else ...[
                buildLabel("Teacher Id", ""),
                buildLabel("Teacher Name", ""),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () => addCourse(context,ref),
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
                      : const Text("Add Course",
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
