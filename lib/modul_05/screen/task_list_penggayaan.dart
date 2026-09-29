import 'package:flutter/material.dart';

import '../services/task_storage.dart';
import 'task_list_screen.dart';

class TaskListPenggayaanScreen extends StatelessWidget {
  const TaskListPenggayaanScreen({super.key, this.storage});

  final TaskStorage? storage;

  @override
  Widget build(BuildContext context) {
    return TaskListScreen(storage: storage);
  }
}
