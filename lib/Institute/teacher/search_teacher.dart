import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutiontoall_mobile/model/institute_model.dart';
import 'package:tutiontoall_mobile/model/teacher_model.dart';
import 'package:http/http.dart' as http;
import 'package:tutiontoall_mobile/providers/loading_provider.dart';

import '../../widgets/alert.dart';
import '../../widgets/institute_drawer.dart';
import '../../widgets/navbar.dart';

class SearchTeacher extends ConsumerStatefulWidget {
  const SearchTeacher({super.key});

  @override
  ConsumerState<SearchTeacher> createState() => _SearchTeacherState();
}

class _SearchTeacherState extends ConsumerState<SearchTeacher> {

  TextEditingController searchValueController=TextEditingController();

  final List<Teacher> teacherList=[];
  Institute? institute;
  Teacher? teacher;

  String teacherBaseUrl = dotenv.env['TEACHER_BASEURL'] ?? '';
  String? instituteBaseUrl = dotenv.env['INSTITUTE_BASEURL'];

  bool isSearched = false;



  search() async{
    ref.read(loadingProvider.notifier).state = true;
    isSearched = true;
    String searchValue = searchValueController.text.trim();

    if (searchValue.isEmpty) {
      showAlertDialog(context,'Username is Required', 'Please enter a username to search');
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
  void initState() {
    loadTeachers();
    super.initState();
  }

  Future<String> getInstituteId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? instituteId = prefs.getString('id');
    if (instituteId == null) {
      throw Exception('Institute ID not found');
    }
    return instituteId;
  }

  loadTeachers() async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? instituteId = prefs.getString('id');

    var request = http.Request('GET', Uri.parse('http://localhost:8080/institutes/search/$instituteId'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {

      String responseString=await response.stream.bytesToString();
      Map<String,dynamic> jsonResponse=jsonDecode(responseString);
      institute=Institute.fromJson(jsonResponse);

      for (var teacher in institute!.registeredTeachers) {
        String? teacherId=teacher.teacherId;

        var request = http.Request('GET', Uri.parse('http://localhost:8080/teachers/search/$teacherId'));

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          String responseString=await response.stream.bytesToString();
          Map<String,dynamic> jsonResponse=jsonDecode(responseString);
          Teacher teacher=Teacher.fromJson(jsonResponse);
          teacherList.add(teacher);
          print(teacherList.length);
          setState(() {});
        }
      }
    }
    else {
      print(response.reasonPhrase);
    }

  }

  @override
  Widget build(BuildContext context) {
    final isLoading=ref.watch(loadingProvider);
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Navbar(
          title: "Search teachers",
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
                    const Text("Teacher Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (teacher != null) ...[
                      buildLabel("First Name", teacher!.firstName),
                      buildLabel("Last Name", teacher!.lastName),
                      buildLabel("Contact", teacher!.contact),
                      buildLabel("Email", teacher!.email),
                      buildLabel("Date of Birth",teacher!.dob.toLocal().toString().split(' ')[0]),
                      buildLabel("Address", teacher!.address),
                    ]else ...[
                      buildLabel("First Name", ""),
                      buildLabel("Last Name", ""),
                      buildLabel("Contact", ""),
                      buildLabel("Email", ""),
                      buildLabel("Date of Birth",""),
                      buildLabel("Address", ""),
                    ],
                    const SizedBox(height: 15),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "All Teachers",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (teacherList.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: teacherList.length,
                        itemBuilder: (context, index) {
                          Teacher teacher = teacherList[index];
                          return ListTile(
                            title: Text('${teacher.firstName} ${teacher.lastName}'),
                            leading: Text(teacher.id),
                            subtitle: Text('Contact: ${teacher.contact}'),
                          );
                        },
                      ),
                    ] else ...[
                      Text("${teacherList.length}"),
                      const Text(
                        "No Teachers Available",
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
