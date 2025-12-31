import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// Baris ini wajib ada agar generator tahu nama file yang akan dibuat
part 'task_model.g.dart';

@HiveType(typeId: 0) // ID unik untuk object Task
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime deadline;

  @HiveField(2)
  List<SubTask> subTasks;

  @HiveField(3)
  List<String> filePaths;

  @HiveField(4)
  bool isHabit;

  Task({
    required this.title,
    required this.deadline,
    this.subTasks = const [],
    this.filePaths = const [],
    this.isHabit = false,
  });

  // Logika Warna (Tidak perlu disimpan di database, jadi tidak pakai @HiveField)
  Color get urgencyColor {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;
    if (difference < 0) return Colors.grey;
    if (difference <= 1) return Colors.red;
    if (difference <= 3) return Colors.orange;
    return Colors.green;
  }
}

@HiveType(typeId: 1) // ID unik untuk object SubTask
class SubTask extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isCompleted;

  SubTask({required this.title, this.isCompleted = false});
}
