import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutiontoall_mobile/model/teacher_model.dart';
import 'package:tutiontoall_mobile/providers/loading_provider.dart';
import 'package:http/http.dart' as http;

import '../../widgets/alert.dart';
import '../../widgets/institute_drawer.dart';
import '../../widgets/institute_navbar.dart';

class UpdateTeacher extends ConsumerStatefulWidget {
  const UpdateTeacher({super.key});

  @override
  ConsumerState<UpdateTeacher> createState() => _UpdateTeacherState();
}

class _UpdateTeacherState extends ConsumerState<UpdateTeacher> {

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final TextEditingController searchValueController = TextEditingController();

  bool isRegisteredTeacher = false;
  String teacherBaseUrl = dotenv.env['TEACHER_BASEURL'] ?? '';
  String instituteBaseUrl = dotenv.env['INSTITUTE_BASEURL'] ?? '';
  Teacher? teacher;
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
        firstNameController.text=teacher!.firstName;
        lastNameController.text=teacher!.lastName;
        contactNumberController.text=teacher!.contact;
        emailController.text=teacher!.email;
        birthdayController.text = teacher!.dob.toIso8601String().split('T')[0];
        addressController.text=teacher!.address;
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

  bool validator(String firstName,String lastName,DateTime birthday,String contact,String email,String address) {
    final RegExp passwordRegex =RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    final RegExp contactRegex = RegExp(r'^0\d{9}$');
    final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        contact.isEmpty ||
        email.isEmpty ||
        address.isEmpty) {
      showAlertDialog(context, "Invalid Input", "Please fill all fields.");
      return false;
    }

    if (!contactRegex.hasMatch(contact)) {
      showAlertDialog(context, "Invalid Contact Number",
          "Contact should contain at least 10 digits starting with 0!");
      return false;
    }

    if (!emailRegex.hasMatch(email)) {
      showAlertDialog(context, "Invalid Email",
          "Invalid Email Address please provide a valid email!");
      return false;
    }
    return true;
  }

  updateTeacher(BuildContext context,WidgetRef ref) async {
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String contact = contactNumberController.text.trim();
    String email = emailController.text.trim();
    String dob = birthdayController.text.trim();
    String address = addressController.text.trim();
    DateTime? birthday;
    if(isSearched) {
      if (dob.isNotEmpty) {
        try {
          birthday = DateTime.parse(dob);
        } catch (e) {
          showAlertDialog(
              context, "Invalid Date", "Please select a valid date.");
          return;
        }
      } else {
        showAlertDialog(
            context, "Invalid Date", "Please select a date of birth.");
        return;
      }
      if (validator(firstName, lastName, birthday, contact, email, address)) {
        ref
            .read(loadingProvider.notifier)
            .state = true;
        if (isSearched) {
          var headers = {'Content-Type': 'application/json'};
          var request = http.Request(
              'PATCH', Uri.parse('$teacherBaseUrl/update'));
          request.body = json.encode({
            "id": teacher?.id,
            "firstName": firstName,
            "lastName": lastName,
            "dob": birthday.toIso8601String(),
            "contact": contact,
            "email": email,
            "address": address
          });

          request.headers.addAll(headers);
          http.StreamedResponse response = await request.send();

          if (response.statusCode == 200) {
            isSearched = false;
            teacher = null;
            ref
                .read(loadingProvider.notifier)
                .state = false;
            showAlertDialog(context, "Success", 'Teacher updated successfully');
          } else {
            ref
                .read(loadingProvider.notifier)
                .state = false;
            showAlertDialog(context, "Teacher Not Searched",
                "Search a teacher before updating");
          }
        } else {
          ref.read(loadingProvider.notifier).state = false;
          showAlertDialog(context, "Error occurred", "Some thing went wrong");
        }
      }
    }else{
      ref.read(loadingProvider.notifier).state = false;
      showAlertDialog(context, "Error", "Search a teacher to update");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: InstituteNavbar(
          title: "Update teachers",
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
                    const SizedBox(height: 15),
                    const Text("Teacher Details",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 20),
                    TextField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                            labelText: "Teacher First Name",
                            border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                            labelText: "Teacher Last Name",
                            border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(
                        controller: contactNumberController,
                        decoration: const InputDecoration(
                            labelText: "Contact Number",
                            border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                            labelText: "Email Address",
                            border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(
                      controller: birthdayController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Date of Birth",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        DateTime now = DateTime.now();
                        DateTime lastDate =
                        DateTime(now.year - 17, now.month, now.day);

                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: lastDate,
                          firstDate: DateTime(1900),
                          lastDate: lastDate,
                        );
                        if (pickedDate != null) {
                          birthdayController.text =
                          "${pickedDate.toLocal()}".split(' ')[0];
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                        controller: addressController,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 5,
                        decoration: const InputDecoration(
                            labelText: "Address",
                            border: OutlineInputBorder()
                        )
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : ()=>updateTeacher(context,ref),
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
                            : const Text(
                            "Update",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            )
                        ),
                      ),
                    ),

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
