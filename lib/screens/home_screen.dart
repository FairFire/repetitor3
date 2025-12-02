import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/lesson.dart';
import '../screens/lesson_detail_screen.dart';
import '../widgets/lesson_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _MyLessonGroup {
  final DateTime date;
  final String dayName;
  final List<Lesson> lessons;

  _MyLessonGroup(this.date, this.dayName, this.lessons);
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _currentWeekStart;
  late Future<List<Lesson>> _lessonsFuture;
  final dbHelper = DBHelper();
  final DateFormat _dayFormat = DateFormat('dd.MM');
  //final DateFormat _fullDateFormat = DateFormat('dd.MM.yyyy');

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

  List<_MyLessonGroup> _groupLessonsByDate(List<Lesson> lessons) {
    final Map<DateTime, List<Lesson>> grouped = {};
    for (final lesson in lessons) {
      final dateOnly = DateTime(
        lesson.dateTime.year,
        lesson.dateTime.month,
        lesson.dateTime.day,
      );
      grouped.putIfAbsent(dateOnly, () => []).add(lesson);
    }

    final List<_MyLessonGroup> result = [];
    for (int i = 0; i < 7; i++) {
      final dayDate = _currentWeekStart.add(Duration(days: i));
      if (grouped.containsKey(dayDate)) {
        final dayName = _getDayName(dayDate.weekday);
        result.add(_MyLessonGroup(dayDate, dayName, grouped[dayDate]!));
      }
    }
    return result;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Понедельник';
      case DateTime.tuesday:
        return 'Вторник';
      case DateTime.wednesday:
        return 'Среда';
      case DateTime.thursday:
        return 'Четверг';
      case DateTime.friday:
        return 'Пятница';
      case DateTime.saturday:
        return 'Суббота';
      case DateTime.sunday:
        return 'Воскресенье';
      default:
        return 'День';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd.MM.yyyy');
    final weekEnd = _currentWeekStart.add(const Duration(days: 6));

    return Scaffold(
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
          final groups = _groupLessonsByDate(lessons);

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    color: Colors.grey.shade200,
                    child: Text(
                      '${group.dayName}, ${_dayFormat.format(group.date)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...List.generate(
                    group.lessons.length,
                    (i) => LessonCard(
                      lesson: group.lessons[i],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LessonDetailScreen.edit(
                              lessonId: group.lessons[i].id!,
                            ),
                          ),
                        ).then((result) {
                          if (result == true) _refreshLessons();
                        });
                      },
                      onLongPress: () async {
                        final confirm =
                            await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Удалить урок?'),
                                content: const Text(
                                  'Это действие нельзя отменить',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Отмена'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Удалить'),
                                  ),
                                ],
                              ),
                            ) ??
                            false;
                        if (confirm) {
                          await dbHelper.deleteLesson(group.lessons[i].id!);
                          _refreshLessons();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Урок удален')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              );
            },
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
}
