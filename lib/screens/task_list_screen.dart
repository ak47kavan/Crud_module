import 'dart:async';
import 'package:crud_module/utils/export_helper.dart';
import 'package:crud_module/utils/json_import_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../models/task_model.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';
import '../theme_provider.dart'; 

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;
  String _statusFilter = 'All';
  bool _sortDescending = false;
  String _categoryFilter = 'All';
  int _itemsPerPage = 10;
int _currentPage = 1;
ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(StreamTasks());

    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        setState(() {
          _searchQuery = _searchController.text.trim().toLowerCase();
        });
      });
    });
    _scrollController.addListener(() {
  if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
    setState(() {
      _currentPage++;
    });
  }
});

  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks'),
       actions: [
        IconButton(
  icon: Icon(Icons.download),
  onPressed: () async {
    final state = context.read<TaskBloc>().state;
    if (state is TaskLoaded) {
      final path = await ExportHelper.exportTasksToCSV(state.tasks);
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tasks exported to: $path")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Permission denied or failed to export.")),
        );
      }
    }
  },
  tooltip: "Export to CSV",
),
IconButton(
  icon: Icon(Icons.file_upload),
  tooltip: "Import from JSON",
  onPressed: () async {
    final tasks = await JsonImportHelper.pickAndParseJSON();
    if (tasks != null && tasks.isNotEmpty) {
      final bloc = context.read<TaskBloc>();
      for (var task in tasks) {
        bloc.add(AddTask(task));
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${tasks.length} tasks imported")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Import cancelled or failed")),
      );
    }
  },
),

    Consumer<ThemeProvider>(
    builder: (context, themeProvider, _) => Switch(
      value: themeProvider.themeMode == ThemeMode.dark,
      onChanged: (val) {
        themeProvider.toggleTheme(val);
      },
    ),
  ),
  PopupMenuButton<String>(
    onSelected: (value) {
      setState(() {
        _sortDescending = value == 'Priority ↓';
      });
    },
    itemBuilder: (context) => [
      PopupMenuItem(value: 'Priority ↑', child: Text('Priority ↑')),
      PopupMenuItem(value: 'Priority ↓', child: Text('Priority ↓')),
    ],
    icon: Icon(Icons.sort),
  ),
  IconButton(
    icon: Icon(Icons.refresh),
    onPressed: () => context.read<TaskBloc>().add(StreamTasks()),
  ),
],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search tasks",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonFormField<String>(
              value: _statusFilter,
              decoration: InputDecoration(
                labelText: "Filter by Status",
              ),
              borderRadius: BorderRadius.circular(10),
              items: ['All', 'Pending', 'In Progress', 'Completed']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _statusFilter = val!;
                });
              },
            ),
          ),
          SizedBox(height: 8),
                            DropdownButtonFormField<String>(
  value: _categoryFilter,
  decoration: InputDecoration(labelText: "Filter by Category"),
  borderRadius: BorderRadius.circular(10),
  items: ['All', 'Work', 'Personal', 'Study', 'Other']
      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
      .toList(),
  onChanged: (val) {
    setState(() => _categoryFilter = val!);
  },
),
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is TaskError) {
                  return Center(child: Text(state.message));
                } else if (state is TaskLoaded) {
                  final allTasks = state.tasks;

                  // Filter by search
                  List<Task> filteredTasks = _searchQuery.isEmpty
                      ? allTasks
                      : allTasks.where((task) =>
                          task.title.toLowerCase().contains(_searchQuery) ||
                          task.description
                              .toLowerCase()
                              .contains(_searchQuery)).toList();

                  // Filter by status
                  if (_statusFilter != 'All') {
                    filteredTasks = filteredTasks
                        .where((task) => task.status == _statusFilter)
                        .toList();
                  }

                  // Sort by priority
                  filteredTasks.sort((a, b) => _sortDescending
                      ? b.priority.compareTo(a.priority)
                      : a.priority.compareTo(b.priority));

                  if (filteredTasks.isEmpty) {
                    return Center(child: Text("No tasks found."));
                  }
                  if (_categoryFilter != 'All') {
  filteredTasks = filteredTasks
      .where((task) => task.category == _categoryFilter)
      .toList();
}
  final totalTasks = filteredTasks.length;
final paginatedTasks = filteredTasks.take(_itemsPerPage * _currentPage).toList();
final hasMore = paginatedTasks.length < totalTasks;
return ListView.separated(
  controller: _scrollController,
  itemCount: hasMore ? paginatedTasks.length + 1 : paginatedTasks.length,
  separatorBuilder: (_, __) => Divider(),
  itemBuilder: (context, index) {
    if (index == paginatedTasks.length && hasMore) {
      return Center(child: CircularProgressIndicator());
    }

    final task = paginatedTasks[index];
    return  Card(
  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  child: ListTile(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    title: Text(task.title, style: TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(task.description),
        SizedBox(height: 4),
        Text("Status: ${task.status} | Priority: ${task.priority} | ${task.category}"),
      ],
    ),
    trailing: IconButton(
      icon: Icon(Icons.delete, color: Colors.red),
      onPressed: () => _confirmDelete(task),
    ),
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)),
    ),
  ),
);

  },
);

                } else {
                  return SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTaskScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(Task task) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Task"),
        content: Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              context.read<TaskBloc>().add(DeleteTask(task));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Task deleted")),
              );
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
