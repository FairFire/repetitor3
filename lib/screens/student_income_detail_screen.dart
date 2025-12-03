import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:repetitor/database/db_helper.dart';
import 'package:repetitor/models/lesson.dart';
import 'package:repetitor/models/student.dart';

class StudentIncomeDetailScreen extends StatelessWidget {
  final int studentId;
  final DateTime month;

  const StudentIncomeDetailScreen({
    super.key,
    required this.studentId,
    required this.month,
  });

  String _formatDuration(double duration) {
    if (duration == 1.0) return '1 час';
    if (duration == 1.5) return '1.5 часа';
    if (duration == 2.0) return '2 часа';
    return '$duration часов';
  }

  @override
  Widget build(BuildContext context) {
    final dbHelper = DBHelper();
    final monthFormatted = DateFormat('MMMM yyyy', 'ru').format(month);
    return Scaffold(
      appBar: AppBar(
        title: Text('Детализация'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder<Student?>(
        future: dbHelper.getStudentById(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final student = snapshot.data;
          final fullName = student?.fullName ?? 'Студент не найден';
          return FutureBuilder<List<Lesson>>(
            future: dbHelper.getLessonsForStudentInMonth(studentId, month),
            builder: (context, lessonSnapshot) {
              if (lessonSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              final lessons = lessonSnapshot.data ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Ученик: $fullName',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Занятий в $monthFormatted:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: lessons.isEmpty
                        ? const Text('Нет занятий')
                        : ListView.builder(
                            itemCount: lessons.length,
                            itemBuilder: (context, index) {
                              final lesson = lessons[index];
                              final dateStr = DateFormat(
                                'dd MMMM yyyy HH:mm',
                                'ru',
                              ).format(lesson.dateTime);
                              return ListTile(
                                title: Text(dateStr),
                                subtitle: Text(
                                  '${_formatDuration(lesson.duration)} * ${lesson.amount.toStringAsFixed(0)} ₽',
                                ),
                                trailing: Text(
                                  '+${lesson.amount.toStringAsFixed(0)} ₽',
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
