import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'task_model.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistik 📊'), centerTitle: true),
      body: ValueListenableBuilder<Box<Task>>(
        valueListenable: Hive.box<Task>('tasksBox').listenable(),
        builder: (context, box, _) {
          var tasks = box.values.toList().cast<Task>();
          int totalTasks = tasks.length;
          int completedTasks = tasks.where((t) => t.isCompleted).length;
          int pendingTasks = totalTasks - completedTasks;

          if (totalTasks == 0) {
            return const Center(child: Text("Belum ada data tugas."));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSummaryCard(totalTasks, completedTasks, pendingTasks),
                const SizedBox(height: 24),
                const Text(
                  "Status Tugas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: completedTasks.toDouble(),
                          title: '$completedTasks',
                          color: Colors.green,
                          radius: 50,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PieChartSectionData(
                          value: pendingTasks.toDouble(),
                          title: '$pendingTasks',
                          color: Colors.orange,
                          radius: 50,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Indicator(color: Colors.green, text: 'Selesai'),
                    SizedBox(width: 10),
                    Indicator(color: Colors.orange, text: 'Belum'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(int total, int completed, int pending) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem("Total", total.toString(), Colors.blue),
            _buildStatItem("Selesai", completed.toString(), Colors.green),
            _buildStatItem("Pending", pending.toString(), Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;

  const Indicator({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}
