import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutiontoall_mobile/model/teacher_model.dart';
import 'package:tutiontoall_mobile/providers/loading_provider.dart';
import 'package:tutiontoall_mobile/widgets/alert.dart';
import 'package:tutiontoall_mobile/widgets/institute_drawer.dart';
import 'package:tutiontoall_mobile/widgets/institute_navbar.dart';
import 'package:http/http.dart' as http;

class AddTeacher extends ConsumerStatefulWidget {
  const AddTeacher({super.key});

  @override
  ConsumerState<AddTeacher> createState() => _AddTeacherState();
}

class _AddTeacherState extends ConsumerState<AddTeacher> {
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

  registerTeacher(BuildContext context, WidgetRef ref) async {
    ref.read(loadingProvider.notifier).state = true;

    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String contactNumber = contactNumberController.text.trim();
    String email = emailController.text.trim();
    String birthdayText = birthdayController.text.trim();
    String address = addressController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    DateTime? birthday;
    if (birthdayText.isNotEmpty) {
      try {
        birthday = DateTime.parse(birthdayText);
      } catch (e) {
        showAlertDialog(context, "Invalid Date", "Please select a valid date.");
        return;
      }
    } else {
      showAlertDialog(context, "Invalid Date", "Please select a date of birth.");
      return;
    }

    if (validator(firstName, lastName, birthday, contactNumber, email, address,password, confirmPassword)) {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request('POST', Uri.parse('$teacherBaseUrl/register'));
      request.body = json.encode({
        "firstName": firstName,
        "lastName": lastName,
        "dob": birthday.toIso8601String(),
        "contact": contactNumber,
        "email": email,
        "address": address,
        "password": password
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        showAlertDialog(context, "Registration Successful", "$firstName $lastName Registered as a teacher successfully");
        firstNameController.text="";
        lastNameController.text="";
        contactNumberController.text="";
        emailController.text="";
        birthdayController.text="";
        addressController.text="";
        passwordController.text="";
        confirmPasswordController.text="";
        ref.read(loadingProvider.notifier).state = false;
      } else {
        showAlertDialog(context, "Registration Failed", "$firstName $lastName Registration as a teacher failed");
        ref.read(loadingProvider.notifier).state = false;
      }
    }
  }

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

  addTeacherToInstitute(BuildContext context,WidgetRef ref) async {

    ref.read(loadingProvider.notifier).state=true;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? instituteId = prefs.getString('id');
    print(isSearched);
    if(isSearched){
      var headers = {
        'Content-Type': 'application/json'
      };
      var request = http.Request('POST', Uri.parse('$instituteBaseUrl/teachers/add'));
      request.body = json.encode({
        "teacherId": teacher!.id,
        "instituteId": instituteId,
        "date": DateTime.now().toIso8601String()
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        isSearched=false;
        teacher=null;
        ref.read(loadingProvider.notifier).state=false;
        showAlertDialog(context, "Added Successfully", 'Teacher added to the institute successfully');
      }
      else {
        ref.read(loadingProvider.notifier).state=false;
        showAlertDialog(context, "Teacher Not Searched", "Search a teacher before adding to the institute");
      }

    }else{
      ref.read(loadingProvider.notifier).state=false;
      showAlertDialog(context, "Error occurred", "Some thing went wrong");
    }
  }

  bool validator(String firstName,String lastName,DateTime birthday,String contact,String email,String address,String password,String confirmPassword) {
    final RegExp passwordRegex =RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    final RegExp contactRegex = RegExp(r'^0\d{9}$');
    final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        contact.isEmpty ||
        email.isEmpty ||
        address.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showAlertDialog(context, "Invalid Input", "Please fill all fields.");
      return false;
    }

    if (!passwordRegex.hasMatch(password)) {
      showAlertDialog(context, "Invalid Password",
          "Password should contain at least 8 characters, 1 letter, 1 number, and 1 special character!");
      return false;
    } else if (password != confirmPassword) {
      showAlertDialog(context, "Does Not Match",
          "Both new and confirm passwords should match each other!");
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

  @override
  Widget build(BuildContext context) {

    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: InstituteNavbar(
          title: "Add teachers",
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
                  Checkbox(
                      value: isRegisteredTeacher,
                      onChanged: (bool? value) {
                        setState(() {
                          isRegisteredTeacher = value!;
                        });
                      }),
                  const Text(
                    "Registered Teacher ?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              isRegisteredTeacher
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          const SizedBox(
                            height: 10,
                          ),
                          isSearched ?
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () =>addTeacherToInstitute(context,ref),
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
                                  : const Text("Add To Institute",
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
                                showAlertDialog(context, "Teacher not searched", "Search a Teacher First");
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
                                "Search a Teacher",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  : Container(
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
                                  border: OutlineInputBorder())),
                          const SizedBox(height: 15),
                          const Text("Login Credentials",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                          const SizedBox(height: 15),
                          TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                  labelText: "Password",
                                  border: OutlineInputBorder())),
                          const SizedBox(height: 10),
                          TextField(
                              controller: confirmPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                  labelText: "Confirm Password",
                                  border: OutlineInputBorder())),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => registerTeacher(context, ref),
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
                                  : const Text("Register",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
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
