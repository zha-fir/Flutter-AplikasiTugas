import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart'; // Indikator Progress
import 'task_model.dart';
import 'add_task_screen.dart';
import 'detail_task_screen.dart';
import 'category_screen.dart';
import 'settings_screen.dart';
import 'history_screen.dart';

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
            onPressed: () {
              showSearch(context: context, delegate: TaskSearchDelegate());
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'category') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoryScreen(),
                  ),
                );
              } else if (value == 'history') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              } else if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'category',
                  child: Row(
                    children: [
                      Icon(Icons.category_rounded, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Kategori'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'history',
                  child: Row(
                    children: [
                      Icon(Icons.history_rounded, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Riwayat'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings_rounded, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Pengaturan'),
                    ],
                  ),
                ),
              ];
            },
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
          // Filter Tugas:
          // Tampilkan jika:
          // 1. Belum Selesai (isCompleted == false)
          // 2. ATAU Selesai TAPI Deadline belum lewat 1 hari yg lalu (Masih "Hangat")
          final now = DateTime.now();
          var tasks = box.values.where((task) {
            final isOld = task.deadline.isBefore(
              now.subtract(const Duration(days: 1)),
            );
            // Jika sudah selesai DAN sudah lama, jangan tampilkan di Home (Masuk History)
            if (task.isCompleted && isOld) {
              return false;
            }
            return true;
          }).toList();

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
                    color: Theme.of(
                      context,
                    ).disabledColor.withValues(alpha: 0.5),
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

class TaskSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final box = Hive.box<Task>('tasksBox');
    final tasks = box.values.toList().cast<Task>().where((task) {
      return task.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    // Sort by deadline
    tasks.sort((a, b) => a.deadline.compareTo(b.deadline));

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Tidak ditemukan",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
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

    if (task.isCompleted) {
      statusColor = Colors.grey;
      statusText = "Selesai";
    } else if (isOverdue) {
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
      elevation: task.isCompleted ? 0 : 2, // Flat jika selesai
      color: task.isCompleted
          ? Colors.grey.withOpacity(0.1)
          : Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: task.isCompleted
              ? Colors.grey.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
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
              // Baris Atas: Checkbox, Judul & Chip Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox Manual
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: task.isCompleted,
                      shape: const CircleBorder(),
                      activeColor: Colors.green,
                      onChanged: (val) {
                        task.toggleCompletion(val ?? false);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Judul & Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: task.isCompleted ? Colors.grey : null,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: statusColor.withOpacity(0.5),
                                ),
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
                            const SizedBox(width: 8),
                            // Chip Kategori
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.blueGrey.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.label_outline,
                                    size: 12,
                                    color: Colors.blueGrey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.category,
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ], // End Wrap children
                        ), // End Wrap
                      ], // End Column children
                    ), // End Column
                  ), // End Expanded
                ],
              ),
              const SizedBox(height: 12),

              // Info Waktu
              Row(
                children: [
                  Icon(
                    Icons.access_time_filled_rounded,
                    size: 16,
                    color: task.isCompleted ? Colors.grey : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat(
                      'd MMM yyyy, HH:mm',
                      'id_ID',
                    ).format(task.deadline),
                    style: TextStyle(
                      color: task.isCompleted ? Colors.grey : Colors.grey[700],
                      fontSize: 13,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
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
                        progressColor: task.isCompleted
                            ? Colors.grey
                            : statusColor,
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
