import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutiontoall_mobile/login.dart';
import 'package:tutiontoall_mobile/providers/OtpProvider.dart';
import 'package:tutiontoall_mobile/widgets/alert.dart';
import 'package:http/http.dart' as http;

final loadingProvider = StateProvider<bool>((ref) => false);

class InstituteRegister extends ConsumerStatefulWidget {
  const InstituteRegister({super.key});

  @override
  ConsumerState<InstituteRegister> createState() => _InstituteRegisterState();
}

class _InstituteRegisterState extends ConsumerState<InstituteRegister> {
  final TextEditingController instituteNameController = TextEditingController();
  final TextEditingController instituteContactController = TextEditingController();
  final TextEditingController instituteEmailController = TextEditingController();
  final TextEditingController instituteAddressController = TextEditingController();
  final TextEditingController institutePasswordController = TextEditingController();
  final TextEditingController instituteConfirmPasswordController = TextEditingController();

  register(BuildContext context, WidgetRef ref) async {
    ref.read(loadingProvider.notifier).state = true; // Show loader

    await dotenv.load(fileName: '.env');
    String instituteBaseUrl = dotenv.env['INSTITUTE_BASEURL'] ?? '';

    String instituteName = instituteNameController.text.trim();
    String instituteContact = instituteContactController.text.trim();
    String instituteEmail = instituteEmailController.text.trim();
    String instituteAddress = instituteAddressController.text.trim();
    String institutePassword = institutePasswordController.text.trim();
    String instituteConfirmPassword = instituteConfirmPasswordController.text.trim();

    if (validator(instituteName, instituteContact, instituteEmail, instituteAddress, institutePassword, instituteConfirmPassword)) {
      try {
        final response = await http.get(Uri.parse('$instituteBaseUrl/otp/$instituteEmail'));
        String otp = response.body;
        ref.read(otpProvider.notifier).state = otp;
        showAlertDialog(context, "Your OTP", otp);
      } catch (e) {
        showAlertDialog(context, "Error", "Something went wrong. Please try again.");
      }
    }

    ref.read(loadingProvider.notifier).state = false; // Hide loader
  }

  bool validator(String name, String contact, String email, String address, String password, String confirmPassword) {
    if (name.isEmpty || contact.isEmpty || email.isEmpty || address.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showAlertDialog(context, "Invalid Input", "Please fill all fields.");
      return false;
    }
    if (password != confirmPassword) {
      showAlertDialog(context, "Password Mismatch", "Passwords do not match.");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);

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
          title: const Text("Institute Registration", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                  ),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Institute Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      const SizedBox(height: 20),
                      TextField(controller: instituteNameController, decoration: const InputDecoration(labelText: "Institute Name", border: OutlineInputBorder())),
                      const SizedBox(height: 10),
                      TextField(controller: instituteContactController, decoration: const InputDecoration(labelText: "Contact Number", border: OutlineInputBorder())),
                      const SizedBox(height: 10),
                      TextField(controller: instituteEmailController, decoration: const InputDecoration(labelText: "Email Address", border: OutlineInputBorder())),
                      const SizedBox(height: 10),
                      TextField(controller: instituteAddressController, keyboardType: TextInputType.multiline, minLines: 1, maxLines: 5, decoration: const InputDecoration(labelText: "Address", border: OutlineInputBorder())),
                      const SizedBox(height: 20),
                      const Text("Login Credentials", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      const SizedBox(height: 20),
                      TextField(controller: institutePasswordController, obscureText: true, decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder())),
                      const SizedBox(height: 10),
                      TextField(controller: instituteConfirmPasswordController, obscureText: true, decoration: const InputDecoration(labelText: "Confirm Password", border: OutlineInputBorder())),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => register(context, ref),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Register", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
