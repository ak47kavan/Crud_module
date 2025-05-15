import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../models/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String status = 'Pending';
  int priority = 1;
  String category = 'Work';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Title"),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
                onSaved: (val) => title = val!,
              ),SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: "Description"),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
                onSaved: (val) => description = val!,
              ),SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: status,
                items: ['Pending', 'In Progress', 'Completed']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => status = val!),
                decoration: InputDecoration(labelText: "Status"),
              ),SizedBox(height: 10),
              DropdownButtonFormField<String>(
              value: category,
              decoration: InputDecoration(labelText: "Category"),
              borderRadius: BorderRadius.circular(10),
              items: ['Work', 'Personal', 'Study', 'Other']
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => category = val!),
            ),SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: priority,
                items: [1, 2, 3, 4, 5]
                    .map((e) => DropdownMenuItem(value: e, child: Text("Priority $e")))
                    .toList(),
                onChanged: (val) => setState(() => priority = val!),
                decoration: InputDecoration(labelText: "Priority"),

              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTask,
                child: Text("Add Task"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
              )
              )
            ],
          ),
        ),
      ),
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final task = Task(
        title: title,
        description: description,
        status: status,
        createdDate: DateTime.now(),
        priority: priority,
        category: category,
      );
      context.read<TaskBloc>().add(AddTask(task));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Task added")));
    }
  }
}
