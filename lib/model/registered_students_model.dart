class RegisteredStudents{
  final String studentId;
  final String instituteId;
  final String? instituteName;
  final DateTime date;

  RegisteredStudents({required this.studentId, required this.instituteId, required this.instituteName, required this.date});

  factory RegisteredStudents.fromJson(Map<String,dynamic> json){
    return RegisteredStudents(
      studentId:json['studentId'],
      instituteId: json['instituteId'],
      instituteName: json['instituteName'],
      date: DateTime.parse(json['date'])
    );
  }
}