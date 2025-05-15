import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/task_model.dart';

class JsonImportHelper {
  static Future<List<Task>?> pickAndParseJSON() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();

      final List<dynamic> jsonList = jsonDecode(jsonString);

      List<Task> tasks = jsonList.map((json) => Task.fromMap(json)).toList();

      return tasks;
    }

    return null;
  }
}
