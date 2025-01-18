import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
              Navigator.pushNamed(context, '/institute/dashboard');
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
                  Navigator.pushNamed(context, '/institute/course/add-course');
                },
              ),
              ListTile(
                title: const Text('Update Course'),
                onTap: () {
                  Navigator.pushNamed(context, '/institute/course/update');
                },
              ),
              ListTile(
                title: const Text('Delete Course'),
                onTap: () {
                  Navigator.pushNamed(context, '/institute/course/delete');
                },
              ),
              ListTile(
                title: const Text('Search Course'),
                onTap: () {
                  Navigator.pushNamed(context, '/institute/course/search');
                },
              ),
              ListTile(
                title: const Text('Manage Course Students'),
                onTap: () {
                  Navigator.pushNamed(context, '/institute/course/manage');
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
                  Navigator.pushNamed(context, '/institute/student/add-student');
                },
              ),
              ListTile(
                title: const Text('Update Student'),
                onTap: () {
                  Navigator.pushNamed(context, '/institute/student/update');
                },
              ),
              ListTile(
                title: const Text('Remove Student'),
                onTap: () {
                  Navigator.pushNamed(context, '/institute/student/delete');
                },
              ),
              ListTile(
                title: const Text('Search Student'),
                onTap: () {
                  Navigator.pushNamed(context, '/institute/student/search');
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
                  Navigator.pushNamed(context, '/institute/teacher/add-teacher');
                },
              ),
              ListTile(
                title: const Text('Update Teacher'),
                onTap: () {
                  Navigator.pushNamed(context, '/institute/teacher/update');
                },
              ),
              ListTile(
                title: const Text('Remove Teacher'),
                onTap: () {
                  Navigator.pushNamed(context, '/institute/teacher/remove');
                },
              ),
              ListTile(
                title: const Text('Search Teacher'),
                onTap: () {
                  Navigator.pushNamed(context, '/institute/teacher/search');
                },
              ),
            ],
          ),
          ListTile(
            title: const Text('Profile'),
            onTap: () {
              Navigator.pushNamed(context, '/institute/profile');
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
