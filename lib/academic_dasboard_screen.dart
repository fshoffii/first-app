import 'package:flutter/material.dart';

import 'modul_02/course.dart'; // Sesuaikan path jika menggunakan 'modul_02/course.dart'
import 'modul_02/widgets/course_card.dart';
import 'modul_02/widgets/header_banner.dart';

// 1. Deklarasi StatefulWidget lengkap
class AcademicDashboardScreen extends StatefulWidget {
  const AcademicDashboardScreen({super.key});

  @override
  State<AcademicDashboardScreen> createState() =>
      _AcademicDashboardScreenState();
}

class _AcademicDashboardScreenState extends State<AcademicDashboardScreen> {
  final List<Course> _courses = Course.getSampleCourses();

  // State untuk menyimpan kategori filter aktif
  String _selectedCategory = 'Semua';

  int get totalSks => _courses.fold<int>(0, (sum, course) => sum + course.sks);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Akademik TRPL',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0284C7),
        foregroundColor: Colors.white,
      ),
      // Versi Smartphone: ListView 1 kolom yang dapat di-scroll vertikal
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          HeaderBanner(totalSks: totalSks), // Banner profil di paling atas
          const SizedBox(height: 16),

          // 2. Widget Wrap dimasukkan dengan benar ke dalam children ListView
          Wrap(
            spacing: 8.0,
            children: ['Semua', 'Teori', 'Praktikum'].map((category) {
              return ChoiceChip(
                label: Text(category),
                selected: _selectedCategory == category,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          Text(
            'Mata Kuliah Semester 5 (${_courses.length} Terdaftar)',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Render seluruh kartu mata kuliah
          ..._courses.map((course) => CourseCard(course: course)),
        ],
      ),
    );
  }
}
