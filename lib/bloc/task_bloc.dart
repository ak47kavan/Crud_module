import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'task_event.dart';
import 'task_state.dart';
import '../services/local_db_helper.dart';
import '../services/firestore_service.dart';
import '../models/task_model.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final FirestoreService firestoreService;
  StreamSubscription<List<Task>>? _taskSubscription;

  TaskBloc({required this.firestoreService}) : super(TaskLoading()) {
    on<LoadTasks>(_onLoadTasks);
    on<StreamTasks>(_onStreamTasks); // ✅ for real-time
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<TasksUpdated>(_onTasksUpdated);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final firestoreTasks = await firestoreService.fetchTasks();

      await LocalDbHelper.clearAll();
      for (var task in firestoreTasks) {
        await LocalDbHelper.insertTask(task);
      }

      final localTasks = await LocalDbHelper.getTasks();
      emit(TaskLoaded(localTasks));
    } catch (e) {
      emit(TaskError("Failed to load tasks: $e"));
    }
  }

void _onStreamTasks(StreamTasks event, Emitter<TaskState> emit) {
  emit(TaskLoading());

  _taskSubscription?.cancel();

  _taskSubscription = firestoreService.streamTasks().listen((tasks) async {
    await LocalDbHelper.clearAll();
    for (var task in tasks) {
      await LocalDbHelper.insertTask(task);
    }
    final localTasks = await LocalDbHelper.getTasks();

    add(TasksUpdated(localTasks)); // ✅ dispatch new event
  });
}

void _onTasksUpdated(TasksUpdated event, Emitter<TaskState> emit) {
  emit(TaskLoaded(event.tasks));
}


  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      final id = await firestoreService.addTask(event.task);
      final taskWithId = event.task..firebaseId = id;
      await LocalDbHelper.insertTask(taskWithId);

      final tasks = await LocalDbHelper.getTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError("Failed to add task: $e"));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await firestoreService.updateTask(event.task);
      await LocalDbHelper.updateTask(event.task);

      final tasks = await LocalDbHelper.getTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError("Failed to update task: $e"));
    }
  }
  

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      if (event.task.firebaseId != null) {
        await firestoreService.deleteTask(event.task.firebaseId!);
      }
      await LocalDbHelper.deleteTask(event.task.id!);

      final tasks = await LocalDbHelper.getTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError("Failed to delete task: $e"));
    }
  }

  @override
  Future<void> close() {
    _taskSubscription?.cancel();
    return super.close();
  }
}
