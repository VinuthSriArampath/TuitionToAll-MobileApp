import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:tutiontoall_mobile/model/course_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../widgets/navbar.dart';
import '../widgets/teacher_drawer.dart';

class TeacherCourseScreen extends StatefulWidget {
  final Course course;

  const TeacherCourseScreen({super.key, required this.course});

  @override
  _TeacherCourseScreenState createState() => _TeacherCourseScreenState();
}

class _TeacherCourseScreenState extends State<TeacherCourseScreen> {
  final TextEditingController assignmentNameController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController noteNameController = TextEditingController();
  PlatformFile? selectedAssignmentFile;
  PlatformFile? selectedNoteFile;

  Future<void> pickAssignmentFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedAssignmentFile = result.files.first;
      });
    }
  }

  Future<void> pickNoteFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedNoteFile = result.files.first;
      });
    }
  }

  void addAssignment() {
    if (assignmentNameController.text.isEmpty ||
        dueDateController.text.isEmpty ||
        selectedAssignmentFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all fields and select a file")));
      return;
    }

    setState(() {
      assignmentNameController.clear();
      dueDateController.clear();
      selectedAssignmentFile = null;
    });
  }

  Future<void> addNote() async {
    if (noteNameController.text.isEmpty || selectedNoteFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a note name and select a file")),
      );
      return;
    }

    Dio dio = Dio();
    dio.options.headers = {
      'Content-Type': 'multipart/form-data',
    };

    FormData formData = FormData();

    // Convert the note object to a JSON string
    String noteJson = jsonEncode({
      'courseId': widget.course.id,
      'title': noteNameController.text,
    });

    formData.fields.add(MapEntry('note', noteJson));

    if (selectedNoteFile != null) {
      MultipartFile file;
      if (kIsWeb) {
        file = MultipartFile.fromBytes(
          selectedNoteFile!.bytes!,
          filename: selectedNoteFile!.name,
          contentType: MediaType("application", "octet-stream"), // Ensures correct file type
        );
      } else {
        file = await MultipartFile.fromFile(
          selectedNoteFile!.path!,
          filename: selectedNoteFile!.name,
          contentType: MediaType("application", "octet-stream"),
        );
      }

      formData.files.add(MapEntry('document', file));
    }

    try {
      final response = await dio.post(
        'http://localhost:8080/notes/add',
        data: formData,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Note Added Successfully!")),
        );
        noteNameController.clear();
        selectedNoteFile = null;
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error adding Note")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Navbar(title: widget.course.name)),
      drawer: const TeacherDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add Assignment",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
                controller: assignmentNameController,
                decoration: const InputDecoration(labelText: "Assignment Name")),
            TextField(
              controller: dueDateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Due Date",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  dueDateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                }
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: pickAssignmentFile,
                child: Text(selectedAssignmentFile == null
                    ? "Select Assignment File"
                    : selectedAssignmentFile!.name)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addAssignment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Add Assignment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Add Notes",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
                controller: noteNameController,
                decoration: const InputDecoration(labelText: "Note Name")),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: pickNoteFile,
                child: Text(selectedNoteFile == null
                    ? "Select Note File"
                    : selectedNoteFile!.name)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Add Note',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
