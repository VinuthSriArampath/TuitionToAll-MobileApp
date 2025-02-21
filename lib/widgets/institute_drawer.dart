import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutiontoall_mobile/Institute/course/add_course.dart';
import 'package:tutiontoall_mobile/Institute/course/delete_course.dart';
import 'package:tutiontoall_mobile/Institute/course/manage_course.dart';
import 'package:tutiontoall_mobile/Institute/course/search_course.dart';
import 'package:tutiontoall_mobile/Institute/course/update_course.dart';
import 'package:tutiontoall_mobile/Institute/institute_dashboard.dart';
import 'package:tutiontoall_mobile/Institute/institute_profile.dart';
import 'package:tutiontoall_mobile/Institute/student/add_student.dart';
import 'package:tutiontoall_mobile/Institute/student/delete_student.dart';
import 'package:tutiontoall_mobile/Institute/student/search_student.dart';
import 'package:tutiontoall_mobile/Institute/student/update_student.dart';
import 'package:tutiontoall_mobile/Institute/teacher/add_teacher.dart';
import 'package:tutiontoall_mobile/Institute/teacher/delete_teacher.dart';
import 'package:tutiontoall_mobile/Institute/teacher/search_teacher.dart';
import 'package:tutiontoall_mobile/Institute/teacher/update_teacher.dart';
import 'package:tutiontoall_mobile/login.dart';

class InstituteDrawer extends StatefulWidget {
  const InstituteDrawer({super.key});

  @override
  State<InstituteDrawer> createState() => _InstituteDrawerState();
}

class _InstituteDrawerState extends State<InstituteDrawer> {

  int _expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>const InstituteDashboard()));
            },
          ),
          ExpansionTile(
            title: const Text('Course'),
            initiallyExpanded: _expandedIndex == 0,
            onExpansionChanged: (expanded) {
              setState(() {
                _expandedIndex = expanded ? 0 : -1;
              });
            },
            children: [
              ListTile(
                title: const Text('Add Course'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const AddCourse()));
                },
              ),
              ListTile(
                title: const Text('Update Course'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const UpdateCourse()));
                },
              ),
              ListTile(
                title: const Text('Delete Course'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const DeleteCourse()));
                },
              ),
              ListTile(
                title: const Text('Search Course'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const SearchCourse()));
                },
              ),
              ListTile(
                title: const Text('Manage Course Students'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const ManageCourse()));
                },
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Student'),
            initiallyExpanded: _expandedIndex == 2,
            onExpansionChanged: (expanded) {
              setState(() {
                _expandedIndex = expanded ? 1 : -1;
              });
            },
            children: [
              ListTile(
                title: const Text('Add Student'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const AddStudent()));
                },
              ),
              ListTile(
                title: const Text('Update Student'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const UpdateStudent()));
                },
              ),
              ListTile(
                title: const Text('Remove Student'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const DeleteStudent()));
                },
              ),
              ListTile(
                title: const Text('Search Student'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const SearchStudent()));
                },
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Teacher'),
            initiallyExpanded: _expandedIndex == 2,
            onExpansionChanged: (expanded) {
              setState(() {
                _expandedIndex = expanded ? 2 : -1;
              });
            },
            children: [
              ListTile(
                title: const Text('Add Teacher'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> const AddTeacher()));
                },
              ),
              ListTile(
                title: const Text('Update Teacher'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> const UpdateTeacher()));
                },
              ),
              ListTile(
                title: const Text('Remove Teacher'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> const DeleteTeacher()));
                },
              ),
              ListTile(
                title: const Text('Search Teacher'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> const SearchTeacher()));
                },
              ),
            ],
          ),
          ListTile(
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> const InstituteProfile()));
            },
          ),
          ListTile(
            title: const Text('Sign out'),
            onTap: () {
              _logout(context);
            },
          ),
        ],
      ),
    );
  }
  void _logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
    Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => const Login()),(route) => false,);
  }

}
