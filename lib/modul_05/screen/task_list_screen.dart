import 'dart:async';

import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_storage.dart';
import '../widgets/task_tile.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, this.storage});

  /// Dapat disuntikkan dari luar (widget test atau praktikum keadaan memuat).
  final TaskStorage? storage;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late final TaskStorage _storage = widget.storage ?? const TaskStorage();

  List<Task>? _tugas;
  Object? _error;
  bool _sedangMenyimpan = false;

  void _pesan(String teks) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(teks)));
  }

  String _rapikanPesan(Object e) {
    if (e is FormatException) {
      return e.message;
    }

    final String s = e.toString();
    return s.startsWith('Exception: ') ? s.substring('Exception: '.length) : s;
  }

  @override
  void initState() {
    super.initState();
    unawaited(_muat());
  }

  Future<void> _muat() async {
    setState(() {
      _tugas = null;
      _error = null;
    });

    try {
      final List<Task> hasil = await _storage.muat();
      if (!mounted) return;
      setState(() => _tugas = hasil);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<bool> _simpanDaftar(
    List<Task> daftarBaru, {
    String? pesan,
    List<Task>? daftarSebelumnya,
  }) async {
    final List<Task>? cadangan = daftarSebelumnya ?? _tugas;

    setState(() {
      _tugas = daftarBaru;
      _sedangMenyimpan = true;
    });

    try {
      await _storage.simpan(daftarBaru);
      if (!mounted) return true;
      setState(() => _sedangMenyimpan = false);
      if (pesan != null) {
        _pesan(pesan);
      }
      return true;
    } catch (e) {
      if (!mounted) return false;
      setState(() {
        _tugas = cadangan;
        _sedangMenyimpan = false;
      });
      _pesan('Gagal menyimpan: ${_rapikanPesan(e)}');
      return false;
    }
  }

  Future<void> _ubahStatus(Task tugas) async {
    final List<Task>? sekarang = _tugas;
    if (sekarang == null) return;

    final List<Task> baru = sekarang
        .map(
          (Task item) =>
              item.id == tugas.id ? item.copyWith(done: !item.done) : item,
        )
        .toList(growable: true);

    await _simpanDaftar(
      baru,
      daftarSebelumnya: sekarang,
      pesan: 'Status tugas berhasil diperbarui',
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Task> daftar = _tugas ?? const <Task>[];

    if (_tugas == null && _error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daftar Tugas')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_rapikanPesan(_error!), textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        actions: <Widget>[
          if (_sedangMenyimpan)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _tugas == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _muat,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: daftar.length,
                itemBuilder: (BuildContext context, int index) {
                  final Task task = daftar[index];
                  return TaskTile(task: task, onToggle: _ubahStatus);
                },
              ),
            ),
    );
  }
}
