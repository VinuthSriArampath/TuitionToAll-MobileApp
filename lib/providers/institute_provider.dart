import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutiontoall_mobile/model/institute_model.dart';

final instituteProvider=StateProvider<Institute>((ref) => Institute(name: "", email: "", contact: "", address: "", password: "", id: '', registeredTeachers: [], registeredStudents: []));