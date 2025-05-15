import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../models/task_model.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;
  const EditTaskScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String description;
  late String status;
  late int priority;

  @override
  void initState() {
    super.initState();
    title = widget.task.title;
    description = widget.task.description;
    status = widget.task.status;
    priority = widget.task.priority;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: title,
                decoration: InputDecoration(labelText: "Title"),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
                onSaved: (val) => title = val!,
              ),
              TextFormField(
                initialValue: description,
                decoration: InputDecoration(labelText: "Description"),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
                onSaved: (val) => description = val!,
              ),
              DropdownButtonFormField<String>(
                value: status,
                items: ['Pending', 'In Progress', 'Completed']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => status = val!),
                decoration: InputDecoration(labelText: "Status"),
              ),
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
                onPressed: _updateTask,
                child: Text("Update Task"),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _updateTask() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updatedTask = Task(
        id: widget.task.id,
        firebaseId: widget.task.firebaseId,
        title: title,
        description: description,
        status: status,
        createdDate: widget.task.createdDate,
        priority: priority,
        category: widget.task.category,
      );
      context.read<TaskBloc>().add(UpdateTask(updatedTask));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Task updated")));
    }
  }
}
