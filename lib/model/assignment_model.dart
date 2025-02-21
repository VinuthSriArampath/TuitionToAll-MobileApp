class Assignment{
  final String id;
  final String courseId;
  final String assignmentName;
  final DateTime dueDate;
  final String path;

  Assignment({required this.id, required this.courseId, required this.assignmentName, required this.dueDate, required this.path});

  factory Assignment.fromJson(Map<String,dynamic> json){
    return Assignment(
      id: json['id'],
      courseId: json['courseId'],
      assignmentName: json['assignmentName'],
      dueDate: json['dueDate'],
      path: json['path']
    );
  }
}