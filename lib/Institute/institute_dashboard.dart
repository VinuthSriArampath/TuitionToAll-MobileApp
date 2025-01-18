import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InstituteDashboard extends StatefulWidget {
  const InstituteDashboard({super.key});

  @override
  State<InstituteDashboard> createState() => _InstituteDashboardState();
}

class _InstituteDashboardState extends State<InstituteDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: InstituteNavbar(),
      ),
      drawer: const InstituteDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard("No Of Students", noOfStudents.toString()),
                _buildStatCard("No Of Teachers", noOfTeachers.toString()),
                _buildStatCard("No Of Courses", noOfCourses.toString()),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Course Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: courseList.length,
                      itemBuilder: (context, index) {
                        final course = courseList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: Text((index + 1).toString()),
                            title: Text(course['name']),
                            subtitle: Text("Type: ${course['type']}"),
                            trailing: Text("ID: ${course['id']}"),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ) // Show error message
      ),
    );
  }

  // Helper to build stat cards
  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
