import 'package:tutiontoall_mobile/model/course_model.dart';
import 'package:tutiontoall_mobile/model/registered_teachers_model.dart';

class Teacher{
  final String id;
  final String firstName;
  final String lastName;
  final DateTime dob;
  final String contact;
  final String email;
  final String address;
  final String password;
  final List<RegisteredTeachers> registeredInstitutes;
  final List<Course> registeredCourses;

  Teacher({required this.id, required this.firstName, required this.lastName, required this.dob, required this.contact, required this.email, required this.address, required this.password,required this.registeredInstitutes,required this.registeredCourses});

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dob: DateTime.parse(json['dob']),
      contact: json['contact'],
      email: json['email'],
      address: json['address'],
      password: json['password'],
      registeredInstitutes: (json['registeredInstitutes'] as List<dynamic>)
          .map((e) => RegisteredTeachers.fromJson(e))
          .toList(),
      registeredCourses: (json['registeredCourses'] as List<dynamic>)
        .map((e)=> Course.fromJson(e))
        .toList()
    );
  }

}