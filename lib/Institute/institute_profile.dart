import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tutiontoall_mobile/change_password.dart';
import 'package:tutiontoall_mobile/model/institute_model.dart';
import 'package:tutiontoall_mobile/widgets/alert.dart';
import 'dart:convert';

import '../widgets/institute_drawer.dart';
import '../widgets/navbar.dart';

class InstituteProfile extends StatefulWidget {
  const InstituteProfile({super.key});

  @override
  State<InstituteProfile> createState() => _InstituteProfileState();
}

class _InstituteProfileState extends State<InstituteProfile> {
  bool isEdit = false;
  Institute? institute;
  String instituteId="N/A";

  TextEditingController instituteNameController = TextEditingController();
  TextEditingController instituteContactController = TextEditingController();
  TextEditingController instituteEmailController = TextEditingController();
  TextEditingController instituteAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getInstituteDetails();
  }

  getInstituteDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loggedUserId = prefs.getString('id');

    if (loggedUserId != null) {
      var request = http.Request('GET', Uri.parse('http://localhost:8080/institutes/search/$loggedUserId'));


      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseString =await response.stream.bytesToString();
        Map<String,dynamic> jsonResponse=json.decode(responseString);
        institute = Institute.fromJson(jsonResponse);
        setState(() {
          instituteId=institute!.id;
          instituteNameController.text=institute!.name;
          instituteContactController.text=institute!.contact;
          instituteEmailController.text=institute!.email;
          instituteAddressController.text=institute!.address;
        });
      } else {
        throw Exception('Failed to load institute data');
      }
    }
  }

  void editSwitch() {
    setState(() {
      isEdit = true;
    });
  }

  void cancel() {
    setState(() {
      isEdit = false;
      instituteNameController.text=institute!.name;
      instituteContactController.text=institute!.contact;
      instituteEmailController.text=institute!.email;
      instituteAddressController.text=institute!.address;
    });
  }

  void update() async {
    String instituteName = instituteNameController.text.trim();
    String instituteContact = instituteContactController.text.trim();
    String instituteEmail = instituteEmailController.text.trim();
    String instituteAddress = instituteAddressController.text.trim();
    if (validateInstitute(instituteName,instituteContact,instituteEmail,instituteAddress)) {
      var headers = {
        'Content-Type': 'application/json'
      };
      var request = http.Request('PATCH', Uri.parse('http://localhost:8080/institutes/update'));
      request.body = json.encode({
        "id": instituteId,
        "name": instituteName,
        "email": instituteEmail,
        "contact": instituteContact,
        "address": instituteAddress,
        "password": institute!.password
      });
      print('Request Body: ${request.body}');
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        showAlertDialog(context, 'success','Institute Details Updated Successfully');
        setState(() {
          isEdit = false;
        });
      } else {
        showAlertDialog(context, 'error','Failed to update institute details');
      }
    }
  }

  bool validateInstitute(String instituteName,String instituteContact, String instituteEmail,String instituteAddress) {
    const contactPattern = r'^0[0-9]{9}$';
    const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

    if (instituteName == '' || instituteName.isEmpty) {
      showAlertDialog(context, 'error','Institute Name is Required');
      return false;
    }
    if (!RegExp(contactPattern).hasMatch(instituteContact)) {
      showAlertDialog(context, 'error','Contact Number is Invalid');
      return false;
    }
    if (!RegExp(emailPattern).hasMatch(instituteEmail)) {
      showAlertDialog(context, 'error','Email Address is Invalid');
      return false;
    }
    if (instituteAddress == '' || instituteAddress.isEmpty) {
      showAlertDialog(context, 'error','Address is Required');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Navbar(title: "Dashboard",),
      ),
      drawer: const InstituteDrawer(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Institute Details',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Text('UserName:$instituteId')
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Name'),
                          isEdit?
                          const SizedBox(height: 10)
                              :
                          GestureDetector(
                            onTap: editSwitch,
                            child: const Text(
                              'Edit',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          )
                        ],
                      ),
                      TextField(
                        controller: instituteNameController,
                        decoration: const InputDecoration(
                          hintText: 'Institute Name',
                        ),
                        enabled: isEdit,
                      ),
                      const SizedBox(height: 20),

                      // Institute Contact
                      const Row(
                        children: [
                          Text('Contact No'),
                        ],
                      ),
                      TextField(
                        controller:instituteContactController,
                        decoration: const InputDecoration(
                          hintText: 'Institute Contact',
                        ),
                        enabled: isEdit,
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Text('Email'),
                        ],
                      ),
                      TextField(
                        controller:instituteEmailController,
                        decoration: const InputDecoration(
                          hintText: 'Institute Email',
                        ),
                        enabled: isEdit,
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Text('Address'),
                        ],
                      ),
                      TextField(
                        controller:instituteAddressController,
                        decoration: const InputDecoration(
                          hintText: 'Institute Address',
                        ),
                        enabled: isEdit,
                      ),
                      const SizedBox(height: 20),

                      // Change Password link
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const ChangePassword()),(route) => false);
                        },
                        child: const Text(
                          'Change Password From Here...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Update and Cancel Buttons
                      if (isEdit) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: cancel,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Colors.black),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: update,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                              child: const Text(
                                'Update',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
