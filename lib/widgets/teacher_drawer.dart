import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutiontoall_mobile/login.dart';

class TeacherDrawer extends StatefulWidget {
  const TeacherDrawer({super.key});

  @override
  State<TeacherDrawer> createState() => _TeacherDrawerState();
}

class _TeacherDrawerState extends State<TeacherDrawer> {

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
              // Navigator.push(context, MaterialPageRoute(builder: (context)=>const InstituteDashboard()));
            },
          ),
          ListTile(
            title: const Text('Profile'),
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context)=> const InstituteProfile()));
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
