class StudentRegisteredCourses{
  final String studentId;
  final String courseId;
  final DateTime date;

  StudentRegisteredCourses({required this.studentId, required this.courseId, required this.date});

  factory StudentRegisteredCourses.fromJson(Map<String,dynamic> json){
    return StudentRegisteredCourses(
      studentId: json['studentId'],
      courseId: json['courseId'],
      date: DateTime.parse(json['date'])
    );
  }
}