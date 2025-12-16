import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:path/path.dart';
import 'package:repetitor/models/student.dart';
import 'package:repetitor/screens/day_schedule_screen.dart';
import '../database/db_helper.dart';
import '../models/lesson.dart';
import '../screens/lesson_detail_screen.dart';
//import '../widgets/lesson_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _currentWeekStart;
  late Future<List<Lesson>> _lessonsFuture;
  final dbHelper = DBHelper();
  final DateFormat _shortDayFormat = DateFormat('E', 'ru');

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getMonday(DateTime.now());
    _refreshLessons();
  }

  DateTime _getMonday(DateTime date) {
    final diff = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - diff);
  }

  void _refreshLessons() {
    setState(() {
      _lessonsFuture = dbHelper.getLessonsForWeek(_currentWeekStart);
    });
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
      _refreshLessons();
    });
  }

  void _prevWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
      _refreshLessons();
    });
  }

  Map<DateTime, List<Lesson>> _groupLessonsByDay(List<Lesson> lessons) {
    final Map<DateTime, List<Lesson>> grouped = {};
    for (final lesson in lessons) {
      final dateOnly = DateTime(
        lesson.dateTime.year,
        lesson.dateTime.month,
        lesson.dateTime.day,
      );
      grouped.putIfAbsent(dateOnly, () => []).add(lesson);
    }
    return grouped;
  }

  String _formatDuration(double duration) {
    if (duration == 1.0) return '1 ч';
    if (duration == 1.5) return '1.5 ч';
    if (duration == 2.0) return '2 ч';
    return '${duration.toStringAsFixed(1)} ч';
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd.MM.yyyy');
    final weekEnd = _currentWeekStart.add(const Duration(days: 6));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _prevWeek,
        ),
        title: Text(
          '${formatter.format(_currentWeekStart)} – ${formatter.format(weekEnd)}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _nextWeek,
          ),
        ],
      ),
      body: FutureBuilder<List<Lesson>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          final lessons = snapshot.data ?? [];

          if (lessons.isEmpty) {
            return const Center(child: Text('Нет занятий на эту неделю'));
          }
          final groupedLessons = _groupLessonsByDay(lessons);

          final List<DateTime> dayWithLesson = [];
          for (int i = 0; i < 7; i++) {
            final dayDate = _currentWeekStart.add(Duration(days: i));
            if (groupedLessons.containsKey(dayDate)) {
              dayWithLesson.add(dayDate);
            }
          }
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: dayWithLesson.map((dayDate) {
                  final dayLessons = groupedLessons[dayDate]!;
                  return _buildDayButton(context, dayDate, dayLessons);
                }).toList(),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final students = await dbHelper.getStudents();
          if (students.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Сначала добавьте студента')),
            );
            return;
          }
          final student = students[0];
          final now2 = DateTime.now();
          final now = DateTime(now2.year, now2.month, now2.day, now2.hour, 0);
          final newLesson = Lesson(
            id: null,
            studentId: student.id!,
            dateTime: now,
            duration: 1.0,
            amount: student.price.toDouble(),
          );
          //final id = await dbHelper.insertLesson(newLesson);
          //final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => LessonDetailScreen.create(lesson: newLesson)))
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    LessonDetailScreen.create(lesson: newLesson),
              ),
            ).then((result) {
              if (result == true) _refreshLessons();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDayButton(
    BuildContext context,
    DateTime dayDate,
    List<Lesson> lessons,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: lessons.isEmpty ? Colors.grey.shade200 : null,
        ),
        onPressed: lessons.isEmpty
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DayScheduleScreen(
                      date: dayDate,
                      initialLessons: lessons,
                    ),
                  ),
                ).then((_) {
                  _refreshLessons();
                });
              },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _shortDayFormat.format(dayDate).substring(0, 2),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  DateFormat('dd.MM').format(dayDate),
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: lessons.map((lesson) {
                  return FutureBuilder<Student?>(
                    future: dbHelper.getStudentById(lesson.studentId),
                    builder: (context, snapshot) {
                      final studentName = snapshot.hasData
                          ? snapshot.data!.fullName
                          : 'Студент';
                      final time = DateFormat('HH:mm').format(lesson.dateTime);
                      return Text(
                        //'$studentName - $time -(${_formatDuration(lesson.duration)})',
                        '$time - $studentName',
                        style: TextStyle(
                          fontSize: 18,
                          decoration: lesson.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
