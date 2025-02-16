
class Student{
  final String id;
  final String firstName;
  final String lastName;
  final DateTime dob;
  final String contact;
  final String email;
  final String address;
  final String password;

  Student({required this.id, required this.firstName, required this.lastName, required this.dob, required this.contact, required this.email, required this.address, required this.password});

  factory Student.fromJson(Map<String,dynamic> json){
    return Student(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dob:  DateTime.parse(json['dob']),
      contact: json['contact'],
      email: json['email'],
      address: json['address'],
      password: json['password']
    );
  }
}