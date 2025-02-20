import 'package:tutiontoall_mobile/model/registered_teachers_model.dart';

class Institute{
  String id="0";
  final String name;
  final String email;
  final String contact;
  final String address;
  final String password;
  final List<RegisteredTeachers> registeredTeachers;
  Institute(
      {
        required this.id,
        required this.name,
        required this.email,
        required this.contact,
        required this.address,
        required this.password,
        required this.registeredTeachers
      });
  factory Institute.fromJson(Map<String,dynamic> json){
    return Institute(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      contact: json['contact'],
      address: json['address'],
      password: json['password'],
      registeredTeachers: (json['registeredTeachers'] as List<dynamic>)
        .map((e)=> RegisteredTeachers.fromJson(e))
        .toList()
    );
  }
}