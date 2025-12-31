import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'task_model.dart';
import 'detail_task_screen.dart';
import 'package:intl/intl.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ['Tugas Kuliah', 'Pribadi', 'Kerja', 'Lainnya'];

    return Scaffold(
      appBar: AppBar(title: const Text('Kategori 📂')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: Icon(_getCategoryIcon(category)),
              title: Text(
                category,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [_TaskByCategoryList(category: category)],
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Tugas Kuliah':
        return Icons.school;
      case 'Pribadi':
        return Icons.person;
      case 'Kerja':
        return Icons.work;
      default:
        return Icons.label;
    }
  }
}

class _TaskByCategoryList extends StatelessWidget {
  final String category;

  const _TaskByCategoryList({required this.category});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Task>>(
      valueListenable: Hive.box<Task>('tasksBox').listenable(),
      builder: (context, box, _) {
        final tasks = box.values
            .where((task) => task.category == category)
            .toList();

        if (tasks.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Tidak ada tugas di kategori ini."),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ListTile(
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: Text(DateFormat('d MMM').format(task.deadline)),
              trailing: Checkbox(
                value: task.isCompleted,
                onChanged: (val) {
                  task.toggleCompletion(val ?? false);
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailTaskScreen(task: task),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
