
import 'package:tutiontoall_mobile/model/student_registered_courses.dart';

class Course{
  final String id;
  final String name;
  final String type;
  final String? teacherId;
  final String? teacherName;
  final List<StudentRegisteredCourses> studentCoursesList;

  Course({required this.id, required this.name, required this.type, required this.teacherId, required this.teacherName, required this.studentCoursesList});

  factory Course.fromJson(Map<String,dynamic> json){
    return Course(
      id : json['id'],
      name: json['name'],
      type: json['type'],
      teacherId: json['teacherId'],
      teacherName: json['teacherName'],
      studentCoursesList: (json['studentCoursesList'] as List<dynamic>)
            .map((e)=> StudentRegisteredCourses.fromJson(e))
            .toList()
    );
  }
}