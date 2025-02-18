
class Course{
  final String id;
  final String name;
  final String type;
  final String teacherId;
  final String teacherName;

  Course({required this.id, required this.name, required this.type, required this.teacherId, required this.teacherName});

  factory Course.fromJson(Map<String,dynamic> json){
    return Course(
      id : json['id'],
      name: json['name'],
      type: json['type'],
      teacherId: json['teacherId'],
      teacherName: json['teacherName']
    );
  }
}