import 'package:flutter/material.dart';
import 'screen/task_list_screen.dart';
import 'services/task_storage.dart';

class Modul05App extends StatelessWidget {
  const Modul05App({super.key});

  @override
  Widget build(BuildContext context) {
    // Jalankan dengan flutter run --dart-define=SIMULASI=true untuk mengaktifkan mode simulasi.
    // Untuk membuktikkan keadaan memuat
    const bool lambat = bool.fromEnvironment('LAMBAT');
    const TaskStorage storage = TaskStorage(
      tunda : lambat ? Duration(seconds: 2) : Duration.zero,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modul 05 — Future & SharedPreferences',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0284C7)),
        useMaterial3: true,
      ),
      home: const TaskListScreen(storage: storage),
    );
  }
}