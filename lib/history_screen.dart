import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'task_model.dart';
import 'detail_task_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Set untuk menyimpan ID/Key tugas yang dipilih
  final Set<dynamic> _selectedKeys = {};
  bool _isSelectionMode = false;

  void _toggleSelection(dynamic key) {
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
      } else {
        _selectedKeys.add(key);
      }

      // Keluar mode seleksi jika tidak ada yang dipilih
      if (_selectedKeys.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _enterSelectionMode(dynamic key) {
    setState(() {
      _isSelectionMode = true;
      _selectedKeys.add(key);
    });
  }

  void _deleteSelectedTasks() async {
    final box = Hive.box<Task>('tasksBox');

    // Konfirmasi hapus
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Riwayat?"),
        content: Text(
          "Apakah Anda yakin ingin menghapus ${_selectedKeys.length} tugas ini secara permanen?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await box.deleteAll(_selectedKeys);
      setState(() {
        _selectedKeys.clear();
        _isSelectionMode = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Tugas berhasil dihapus")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_isSelectionMode) {
          setState(() {
            _selectedKeys.clear();
            _isSelectionMode = false;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: _isSelectionMode
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedKeys.clear();
                      _isSelectionMode = false;
                    });
                  },
                )
              : null,
          title: Text(
            _isSelectionMode
                ? "${_selectedKeys.length} Dipilih"
                : 'Riwayat Tugas',
          ),
          actions: [
            if (_isSelectionMode)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteSelectedTasks,
              ),
          ],
        ),
        body: ValueListenableBuilder<Box<Task>>(
          valueListenable: Hive.box<Task>('tasksBox').listenable(),
          builder: (context, box, _) {
            // Definisikan logika "Riwayat"
            // Tugas Selesai DAN Deadline lewat > 1 hari
            final now = DateTime.now();
            final historyTasks = box.values.where((task) {
              final isOld = task.deadline.isBefore(
                now.subtract(const Duration(days: 1)),
              );
              return task.isCompleted && isOld;
            }).toList();

            // Urutkan dari yang paling baru deadlinenya
            historyTasks.sort((a, b) => b.deadline.compareTo(a.deadline));

            if (historyTasks.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_toggle_off,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Belum ada riwayat tugas.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyTasks.length,
              itemBuilder: (context, index) {
                final task = historyTasks[index];
                final isSelected = _selectedKeys.contains(task.key);

                return Card(
                  color: _isSelectionMode && isSelected
                      ? Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.3)
                      : null,
                  child: ListTile(
                    leading: _isSelectionMode
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (_) => _toggleSelection(task.key),
                          )
                        : const Icon(Icons.check_circle, color: Colors.grey),
                    title: Text(
                      task.title,
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat(
                        'd MMM yyyy, HH:mm',
                        'id_ID',
                      ).format(task.deadline),
                    ),
                    onLongPress: () {
                      if (!_isSelectionMode) {
                        _enterSelectionMode(task.key);
                      }
                    },
                    onTap: () {
                      if (_isSelectionMode) {
                        _toggleSelection(task.key);
                      } else {
                        // Buka detail jika tidak mode seleksi
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailTaskScreen(task: task),
                          ),
                        );
                      }
                    },
                    trailing: !_isSelectionMode
                        ? IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              // Fitur Delete Single
                              // Kita masukin ke selectedKeys dulu biar logicnya sama
                              _selectedKeys.add(task.key);
                              _deleteSelectedTasks();
                            },
                          )
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
