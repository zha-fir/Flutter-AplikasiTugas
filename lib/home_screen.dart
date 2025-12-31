import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart'; // Indikator Progress
import 'task_model.dart';
import 'add_task_screen.dart';
import 'detail_task_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar Modern: Judul Besar di Kiri
      appBar: AppBar(
        title: Text(
          'Tugasku 📝',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 28,
            color: Theme.of(context).colorScheme.primary, // Sesuaikan warna
          ),
        ),
        centerTitle: false, // Judul di kiri (gaya iOS / Modern Android)
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {}, // Placeholder
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        label: const Text("Tugas Baru"),
        icon: const Icon(Icons.add_rounded),
        elevation: 4,
      ),

      body: ValueListenableBuilder<Box<Task>>(
        valueListenable: Hive.box<Task>('tasksBox').listenable(),
        builder: (context, box, _) {
          var tasks = box.values.toList().cast<Task>();

          // Logika Sorting: Deadline terdekat di paling atas
          tasks.sort((a, b) => a.deadline.compareTo(b.deadline));

          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_alt_outlined,
                    size: 100,
                    color: Theme.of(context).disabledColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada tugas",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Santai dulu atau mulai produktif sekarang! 🚀",
                    style: TextStyle(color: Theme.of(context).disabledColor),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _TaskCard(task: task);
            },
          );
        },
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    // Logika Warna Status
    final now = DateTime.now();
    final isOverdue = task.deadline.isBefore(now);
    final daysLeft = task.deadline.difference(now).inDays;

    // Tentukan Warna & Label Status
    Color statusColor;
    String statusText;

    if (isOverdue) {
      statusColor = Colors.red;
      statusText = "Telat";
    } else if (daysLeft == 0) {
      statusColor = Colors.orange;
      statusText = "Hari Ini";
    } else if (daysLeft == 1) {
      statusColor = Colors.deepOrangeAccent;
      statusText = "Besok";
    } else if (daysLeft <= 3) {
      statusColor = Colors.blue;
      statusText = "$daysLeft Hari Lagi";
    } else {
      statusColor = Colors.green;
      statusText = "Masih Lama";
    }

    // Hitung Progress SubTask
    double progress = 0.0;
    if (task.subTasks.isNotEmpty) {
      final completed = task.subTasks.where((s) => s.isCompleted).length;
      progress = completed / task.subTasks.length;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0, // Flat dengan border
      color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailTaskScreen(task: task),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris Atas: Judul & Chip Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Info Waktu
              Row(
                children: [
                  Icon(
                    Icons.access_time_filled_rounded,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat(
                      'd MMM yyyy, HH:mm',
                      'id_ID',
                    ).format(task.deadline),
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress Bar (Jika ada subtasks)
              if (task.subTasks.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: LinearPercentIndicator(
                        lineHeight: 6.0,
                        percent: progress,
                        barRadius: const Radius.circular(3),
                        progressColor: statusColor,
                        backgroundColor: Colors.grey[200],
                        padding: EdgeInsets.zero,
                        animation: true,
                        animationDuration: 1000,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Jika tidak ada subtasks, kasih visual strip minimalis
                Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
