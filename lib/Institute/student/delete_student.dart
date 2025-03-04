import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutiontoall_mobile/model/student_model.dart';
import 'package:tutiontoall_mobile/providers/loading_provider.dart';
import 'package:tutiontoall_mobile/widgets/alert.dart';
import 'package:tutiontoall_mobile/widgets/institute_drawer.dart';
import 'package:tutiontoall_mobile/widgets/navbar.dart';
import 'package:http/http.dart' as http;

class DeleteStudent extends ConsumerStatefulWidget {
  const DeleteStudent({super.key});

  @override
  ConsumerState<DeleteStudent> createState() => _DeleteStudentState();
}

class _DeleteStudentState extends ConsumerState<DeleteStudent> {

  final TextEditingController searchValueController = TextEditingController();

  String studentBaseUrl = dotenv.env['STUDENT_BASEURL'] ?? '';
  String instituteBaseUrl = dotenv.env['INSTITUTE_BASEURL'] ?? '';
  Student? student;
  bool isSearched = false;

  search() async{
    ref.read(loadingProvider.notifier).state = true;
    isSearched = true;
    String searchValue = searchValueController.text.trim();

    if (searchValue.isEmpty) {
      showAlertDialog(context,'Username is Required', 'Please enter a username to search');
      return;
    }

    if (searchValue.startsWith('S')) {
      var request = http.Request('GET', Uri.parse('$studentBaseUrl/search/$searchValue'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseString=await response.stream.bytesToString();
        Map<String,dynamic> jsonResponse=jsonDecode(responseString);
        student=Student.fromJson(jsonResponse);
        ref.read(loadingProvider.notifier).state=false;
      }
      else {
        ref.read(loadingProvider.notifier).state=false;
        showAlertDialog(context,'Not Found', 'Searched Username Not found');
        student=null;
        isSearched=false;
        return;
      }
    } else {
      ref.read(loadingProvider.notifier).state=false;
      showAlertDialog(context,'Invalid Username', 'Enter an Valid Student ID starts with S');
      isSearched=false;
      return;
    }
  }

  removeFromInstitute(BuildContext context,WidgetRef ref) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? instituteId = prefs.getString('id');
    if(isSearched){
      String? studentId=student?.id;
      var request = http.Request('DELETE', Uri.parse('$instituteBaseUrl/$instituteId/students/remove/$studentId'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        ref.read(loadingProvider.notifier).state=false;
        showAlertDialog(context,'Success', 'Student $studentId removed from institute successfully');
        isSearched=false;
        return;
      }
      else {
        ref.read(loadingProvider.notifier).state=false;
        showAlertDialog(context,'Error', 'Something went wrong');
        isSearched=false;
        return;
      }

    }else{
      ref.read(loadingProvider.notifier).state=false;
      showAlertDialog(context,'Error', 'Search a student to remove from institute');
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
          title: "Remove students",
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
                              hintText: "Search Student",
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
                    const Text("Student Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (student != null) ...[
                      buildLabel("First Name", student!.firstName),
                      buildLabel("Last Name", student!.lastName),
                      buildLabel("Contact", student!.contact),
                      buildLabel("Email", student!.email),
                      buildLabel("Date of Birth",student!.dob.toLocal().toString().split(' ')[0]),
                      buildLabel("Address", student!.address),
                    ]else ...[
                      buildLabel("First Name", ""),
                      buildLabel("Last Name", ""),
                      buildLabel("Contact", ""),
                      buildLabel("Email", ""),
                      buildLabel("Date of Birth",""),
                      buildLabel("Address", ""),
                    ],
                    const SizedBox(height: 15),
                    isSearched ?
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () =>removeFromInstitute(context,ref),
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
                            : const Text("Remove from Institute",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    )
                        :
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (){
                          showAlertDialog(context, "Student not searched", "Search a Student First");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child:const Text(
                          "Search a Student",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )

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
          // Icon for visual appeal (optional)
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
