class Note {
  final String id;
  final String courseId;
  final String title;
  final String path;

  Note({required this.id, required this.courseId, required this.title, required this.path});

  factory Note.fromJson(Map<String,dynamic> json){
    return Note(
      id: json['id'],
      courseId: json['courseId'],
      title: json['title'],
      path: json['path']
    );
  }
}