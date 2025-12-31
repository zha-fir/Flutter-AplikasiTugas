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

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  List<bool>? previousSubTaskStatus;

  @HiveField(7, defaultValue: 'Tugas Kuliah')
  String category;

  Task({
    required this.title,
    required this.deadline,
    this.subTasks = const [],
    this.filePaths = const [],
    this.isHabit = false,
    this.isCompleted = false,
    this.previousSubTaskStatus,
    this.category = 'Tugas Kuliah',
  });

  // Logika Smart Toggle (Sinkronisasi dengan Sub-Tugas)
  void toggleCompletion(bool value) {
    if (value) {
      // User menandai SELESAI
      // 1. Simpan status sub-tugas saat ini sebagai history
      previousSubTaskStatus = subTasks.map((s) => s.isCompleted).toList();

      // 2. Tandai semua sub-tugas jadi selesai
      for (var s in subTasks) {
        s.isCompleted = true;
      }
    } else {
      // User membatalkan (UNCHECK)
      if (previousSubTaskStatus != null &&
          previousSubTaskStatus!.length == subTasks.length) {
        // Restore status dari history
        for (int i = 0; i < subTasks.length; i++) {
          subTasks[i].isCompleted = previousSubTaskStatus![i];
        }
        previousSubTaskStatus = null; // Hapus history setelah dipakai
      } else {
        // Fallback: Jika tidak ada history (misal auto-complete), uncheck semua
        for (var s in subTasks) {
          s.isCompleted = false;
        }
      }
    }

    isCompleted = value;
    save(); // Simpan perubahan ke Hive
  }

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
