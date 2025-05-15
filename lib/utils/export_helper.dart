import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/task_model.dart';

class ExportHelper {
static Future<String?> exportTasksToCSV(List<Task> tasks) async {
  final status = await Permission.storage.request();
  if (!status.isGranted) return null;

  List<List<dynamic>> rows = [
    ['Title', 'Description', 'Status', 'Created Date', 'Priority'],
    ...tasks.map((task) => [
          task.title,
          task.description,
          task.status,
          task.createdDate.toIso8601String(),
          task.priority
        ])
  ];

  String csv = const ListToCsvConverter().convert(rows);

  final directory = await getExternalStorageDirectory(); // internal app-safe location
  final path = '${directory!.path}/tasks_export.csv';

  final file = File(path);
  await file.writeAsString(csv);
print("Exported CSV to: $path");
  return path;
}

}
