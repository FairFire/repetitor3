import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lesson.dart';
import '../database/db_helper.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const LessonCard({
    Key? key,
    required this.lesson,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dbHelper = DBHelper();
    return FutureBuilder(
      future: dbHelper.getStudentById(lesson.studentId),
      builder: (context, snapshot) {
        String studentInfo = 'Студент не найден';
        if (snapshot.hasData && snapshot.data != null) {
          final student = snapshot.data!;
          studentInfo = '${student.fullName} (${student.price} ₽/ч)';
        }

        final formatter = DateFormat('dd.MM HH:mm');
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(studentInfo),
            subtitle: Text(
              '${formatter.format(lesson.dateTime)} • ${lesson.duration} ч • Итого: ${lesson.amount.toStringAsFixed(0)} ₽',
            ),
            onTap: onTap,
            onLongPress: onLongPress,
          ),
        );
      },
    );
  }
}
