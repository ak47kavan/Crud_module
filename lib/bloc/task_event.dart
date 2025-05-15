import 'package:equatable/equatable.dart';
import '../models/task_model.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();
  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}
class StreamTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final Task task;
  const AddTask(this.task);
  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TaskEvent {
  final Task task;
  const UpdateTask(this.task);
  @override
  List<Object?> get props => [task];
}

class TasksUpdated extends TaskEvent {
  final List<Task> tasks;
  const TasksUpdated(this.tasks);
  @override
  List<Object?> get props => [tasks];
}

class DeleteTask extends TaskEvent {
  final Task task;
  const DeleteTask(this.task);
  @override
  List<Object?> get props => [task];
}
