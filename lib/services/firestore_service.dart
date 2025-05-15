import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirestoreService {
  final _collection = FirebaseFirestore.instance.collection('tasks');

  Future<String> addTask(Task task) async {
    final doc = await _collection.add(task.toFirestore());
    return doc.id;
  }

  Future<List<Task>> fetchTasks() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => Task.fromFirestore(doc.data(), doc.id)).toList();
  }

  Future<void> updateTask(Task task) async {
    if (task.firebaseId != null) {
      await _collection.doc(task.firebaseId).update(task.toFirestore());
    }
  }

  Future<void> deleteTask(String firebaseId) async {
    await _collection.doc(firebaseId).delete();
  }
  
  Stream<List<Task>> streamTasks() {
  return _collection.snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => Task.fromFirestore(doc.data(), doc.id))
        .toList();
  });
}

}
