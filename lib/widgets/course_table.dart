import 'package:flutter/material.dart';

class CourseTable extends StatelessWidget {
  final List<dynamic> courseList;

  const CourseTable({super.key, required this.courseList});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text('Course Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DataTable(
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Course Name')),
                DataColumn(label: Text('Type')),
              ],
              rows: List.generate(courseList.length, (index) {
                var course = courseList[index];
                return DataRow(cells: [
                  DataCell(Text('${index + 1}')),
                  DataCell(Text(course['id'])),
                  DataCell(Text(course['name'])),
                  DataCell(Text(course['type'])),
                ]);
              }),
            ),
          ],
        ),
      ),
    );
  }
}
