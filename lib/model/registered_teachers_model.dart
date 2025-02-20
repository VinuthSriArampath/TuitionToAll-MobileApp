class RegisteredTeachers{
  final String teacherId;
  final String instituteId;
  final DateTime date;

  RegisteredTeachers({required this.teacherId, required this.instituteId, required this.date});

  factory RegisteredTeachers.fromJson(Map<String,dynamic> json){
    return RegisteredTeachers(
      teacherId: json['teacherId'],
      instituteId: json['instituteId'],
      date: DateTime.parse(json['date']),
    );
  }
}