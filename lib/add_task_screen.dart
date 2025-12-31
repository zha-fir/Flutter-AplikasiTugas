import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'task_model.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit;

  const AddTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<TextEditingController> _subTaskControllers = [];
  DateTime? _selectedDate;

  final ImagePicker _picker = ImagePicker();
  List<String> _attachedImagePaths = [];

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _selectedDate = widget.taskToEdit!.deadline;

      for (var sub in widget.taskToEdit!.subTasks) {
        _subTaskControllers.add(TextEditingController(text: sub.title));
      }

      _attachedImagePaths = List.from(widget.taskToEdit!.filePaths);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _attachedImagePaths.add(image.path);
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil gambar: $e");
    }
  }

  void _pickDate() async {
    final now = DateTime.now();
    DateTime firstDateAllowed = now;
    if (_selectedDate != null && _selectedDate!.isBefore(now)) {
      firstDateAllowed = _selectedDate!;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDateAllowed,
      lastDate: DateTime(2030),
    );

    if (pickedDate == null) return;

    if (!mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate ?? now),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _addSubTaskField() {
    setState(() {
      _subTaskControllers.add(TextEditingController());
    });
  }

  void _saveTask() {
    if (_titleController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Judul dan Deadline wajib diisi!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    List<SubTask> newSubTasks = _subTaskControllers
        .map((controller) => controller.text)
        .where((text) => text.isNotEmpty)
        .map((text) => SubTask(title: text))
        .toList();

    if (widget.taskToEdit != null) {
      var task = widget.taskToEdit!;
      task.title = _titleController.text;
      task.deadline = _selectedDate!;
      task.subTasks = newSubTasks;
      task.filePaths = _attachedImagePaths;
      task.save();
    } else {
      final newTask = Task(
        title: _titleController.text,
        deadline: _selectedDate!,
        subTasks: newSubTasks,
        filePaths: _attachedImagePaths,
      );
      var box = Hive.box<Task>('tasksBox');
      box.add(newTask);
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _subTaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Widget Helper untuk Section Title
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.taskToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Tugas' : 'Tambah Tugas Baru'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- JUDUL TUGAS ---
            TextFormField(
              controller: _titleController,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Apa yang harus dilakukan?',
                hintText: 'Misal: Beli Kopi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                prefixIcon: const Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 24),

            // --- TANGGAL DEADLINE ---
            _buildSectionTitle("Kapan Deadline-nya?", Icons.calendar_month),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_filled,
                      color: _selectedDate == null
                          ? Colors.grey
                          : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'Pilih Tanggal & Jam'
                            : DateFormat(
                                'EEEE, d MMMM yyyy, HH:mm',
                                'id_ID',
                              ).format(_selectedDate!),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _selectedDate == null
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- SUB-TUGAS ---
            _buildSectionTitle("Langkah-langkah (Checklist)", Icons.checklist),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  if (_subTaskControllers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Belum ada langkah kecil.",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  ..._subTaskControllers.asMap().entries.map((entry) {
                    int index = entry.key;
                    TextEditingController controller = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.circle_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                hintText: 'Langkah ${index + 1}...',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _subTaskControllers.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(),
                  TextButton.icon(
                    onPressed: _addSubTaskField,
                    icon: const Icon(Icons.add),
                    label: const Text("Tambah Langkah"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- LAMPIRAN ---
            _buildSectionTitle("Lampiran Foto", Icons.image),

            // Tombol Add Image
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Kamera"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Galeri"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Preview Image List
            if (_attachedImagePaths.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _attachedImagePaths.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_attachedImagePaths[index]),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _attachedImagePaths.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 40),

            // --- TOMBOL SIMPAN ---
            ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Text(
                isEditMode ? "SIMPAN PERUBAHAN" : "BUAT TUGAS",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
