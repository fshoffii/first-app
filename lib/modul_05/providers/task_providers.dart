import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';

// Notifier Riverpod untuk mengelola daftar tugas.
class TaskNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() => Task.getSampleTasks();

  // Menambahkan tugas baru dengan validasi duplikasi ID.
  bool tambahTask(Task task) {
    final exists = state.any(
      (item) => item.id.toUpperCase() == task.id.toUpperCase(),
    );
    if (exists) return false;

    state = [...state, task];
    return true;
  }

  // Menghapus tugas berdasarkan ID.
  void hapusTask(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  // Mengubah status selesai/belum selesai.
  void toggleTask(String id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(done: !item.done) else item,
    ];
  }

  // Total tugas saat ini.
  int get totalTasks => state.length;
}

// Provider global untuk task(tugas).
final taskProvider = NotifierProvider<TaskNotifier, List<Task>>(
  TaskNotifier.new,
);

// Provider terkomputasi untuk menghitung jumlah tugas.
final totalTasksProvider = Provider<int>((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks.length;
});
