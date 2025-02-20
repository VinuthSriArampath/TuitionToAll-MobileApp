
import 'package:tutiontoall_mobile/model/registered_students_model.dart';

class Student{
  final String id;
  final String firstName;
  final String lastName;
  final DateTime dob;
  final String contact;
  final String email;
  final String address;
  final String password;
  final List<RegisteredStudents> registeredInstitutes;

  Student({required this.id, required this.firstName, required this.lastName, required this.dob, required this.contact, required this.email, required this.address, required this.password,required this.registeredInstitutes});

  factory Student.fromJson(Map<String,dynamic> json){
    return Student(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dob:  DateTime.parse(json['dob']),
      contact: json['contact'],
      email: json['email'],
      address: json['address'],
      password: json['password'],
      registeredInstitutes: (json['registeredInstitutes'] as List<dynamic>)
        .map((e) => RegisteredStudents.fromJson(e))
        .toList()
    );
  }
}