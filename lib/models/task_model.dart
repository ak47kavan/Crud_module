import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  int? id; // for SQLite
  String? firebaseId; // for Firestore
  final String title;
  final String description;
  final String status;
  final DateTime createdDate;
  final int priority;
  final String category;


  Task({
    this.id,
    this.firebaseId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdDate,
    required this.priority,
    required this.category,
  });

  // Local DB map
  Map<String, dynamic> toMap() => {
        'id': id,
        'firebaseId': firebaseId,
        'title': title,
        'description': description,
        'status': status,
        'createdDate': createdDate.toIso8601String(),
        'priority': priority,
        'category': category,
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'],
        firebaseId: map['firebaseId'],
        title: map['title'],
        description: map['description'],
        status: map['status'],
        createdDate: DateTime.parse(map['createdDate']),
        priority: map['priority'],
        category: map['category'] ?? '',
      );

  // Firestore
  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'status': status,
        'createdDate': createdDate,
        'priority': priority,
        'category': category,
      };

  factory Task.fromFirestore(Map<String, dynamic> map, String docId) => Task(
        firebaseId: docId,
        title: map['title'],
        description: map['description'],
        status: map['status'],
        createdDate: (map['createdDate'] as Timestamp).toDate(),
        priority: map['priority'],
        category: map['category'] ?? '',
      );
}
