import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;

import 'package:tutiontoall_mobile/login.dart';
import 'package:tutiontoall_mobile/providers/OtpProvider.dart';
import 'package:tutiontoall_mobile/providers/institute_provider.dart';
import 'package:tutiontoall_mobile/widgets/alert.dart';

class InstituteRegisterOtp extends ConsumerStatefulWidget {
  const InstituteRegisterOtp({super.key});

  @override
  ConsumerState<InstituteRegisterOtp> createState() =>
      _InstituteRegisterOtpState();
}

class _InstituteRegisterOtpState extends ConsumerState<InstituteRegisterOtp> {
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    otpConfirmation(BuildContext context, WidgetRef ref) async {
      String instituteBaseUrl = dotenv.env['INSTITUTE_BASEURL'] ?? '';
      final otp = ref.watch(otpProvider);
      final institute = ref.watch(instituteProvider);
      String userOtp = otpController.text.trim();
      if (userOtp.length < 6) {
        showAlertDialog(context, "Invalid Otp", "otp is a 6 digit code");
      } else {
        if (otp == userOtp) {
          var headers = {'Content-Type': 'application/json'};
          var request = http.Request(
              'POST', Uri.parse('$instituteBaseUrl/register'));
          request.body = json.encode({
            "name": institute.name,
            "email": institute.email,
            "contact": institute.contact,
            "address": institute.address,
            "password": institute.password
          });
          request.headers.addAll(headers);

          http.StreamedResponse response = await request.send();

          if (response.statusCode == 200) {
            await showAlertDialog(context, "Registration Successful",
                "You Have been successfully registered!");
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
                (route) => false);
          } else {
            await showAlertDialog(context, "Registration Failed",
                "Something went Wrong, Please try again!");
            Navigator.pop(context);
          }
        }
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFDDF2FF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFDDF2FF),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text("Otp Confirmation",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
        ),
        body: Center(
            child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
                  children: [
                    const Text(
                      "** We have sent you a 6-digit code to verify your email address. Please enter the code below to continue. **",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    PinCodeTextField(
                      controller: otpController,
                      appContext: context,
                      length: 6,
                      keyboardType: TextInputType.number,
                      obscureText: false,
                      animationType: AnimationType.slide,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(5),
                        fieldHeight: 50,
                        fieldWidth: 40,
                        activeFillColor: Colors.white,
                        inactiveFillColor: Colors.transparent,
                        selectedFillColor: Colors.blue[100],
                        activeColor: Colors.blue,
                        inactiveColor: Colors.blueAccent,
                        selectedColor: Colors.blueAccent,
                      ),
                      enableActiveFill: true,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: () {
                            otpConfirmation(context, ref);
                          },
                          child: const Text("Continue",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold))),
                    )
                  ],
                ),
              )
            ],
          ),
        )),
      ),
    );
  }
}