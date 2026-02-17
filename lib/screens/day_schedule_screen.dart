import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:repetitor/database/db_helper.dart';
import 'package:repetitor/models/lesson.dart';
import 'package:repetitor/models/student.dart';
import 'package:repetitor/screens/lesson_detail_screen.dart';
import 'package:repetitor/screens/student_form_screen.dart';

class DayScheduleScreen extends StatefulWidget {
  final DateTime date;
  final List<Lesson> initialLessons;

  const DayScheduleScreen({
    Key? key,
    required this.date,
    required this.initialLessons,
  }) : super(key: key);

  @override
  State<DayScheduleScreen> createState() => _DayScheduleScreenState();
}

class _DayScheduleScreenState extends State<DayScheduleScreen> {
  late List<Lesson> _lessons;
  final dbHelper = DBHelper();
  //late Future<List<Student>> _studentFuture;

  @override
  void initState() {
    super.initState();
    _lessons = List.from(widget.initialLessons);
    //_studentFuture = dbHelper.getStudents();
  }

  String _formatDuration(double duration) {
    if (duration == 1.0) return '1 ч';
    if (duration == 1.5) return '1.5 ч';
    if (duration == 2.0) return '2.0 ч';
    return '${duration.toStringAsFixed(1)} ч';
  }

  Future<void> _addLesson() async {
    final students = await dbHelper.getStudents();
    if (students.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Сначала добавьте студента')));
      return;
    }
    final student = students[0];
    final now = DateTime.now();
    final lessonTime = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      now.hour,
      0,
    );

    final newLesson = Lesson(
      id: null,
      studentId: student.id!,
      dateTime: lessonTime,
      duration: 1.0,
      amount: student.price.toDouble(),
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonDetailScreen.create(lesson: newLesson),
      ),
    );
    if (result == true) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _editLesson(Lesson lesson) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonDetailScreen.edit(lessonId: lesson.id!),
      ),
    );
    if (result == true) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _openStudentCard(Lesson lesson) async {
    int idStudent = lesson.studentId;
    Student? student = await dbHelper.getStudentById(idStudent);
    if (student != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentFormScreen(student: student),
        ),
      );
    }
  }

  Future<void> _deleteLesson(Lesson lesson) async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Удалить урок?'),
            content: Text('Это действие нельзя отменить'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Удалить'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await dbHelper.deleteLesson(lesson.id!);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Урок удален')));
      Navigator.pop(context, true);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final fullDayName = DateFormat(
      'EEEE, dd.MM.yyyy',
      'ru',
    ).format(widget.date);
    final fullDayNamee =
        fullDayName[0].toUpperCase() + fullDayName.substring(1);
    return Scaffold(
      backgroundColor: Colors.yellow.shade200,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade200,
        title: Text(
          fullDayNamee,
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _lessons.isEmpty
          ? const Center(child: Text('Нет занятий'))
          : SafeArea(
              child: ListView.builder(
                itemCount: _lessons.length,
                itemBuilder: (context, index) {
                  final lesson = _lessons[index];
                  return FutureBuilder<Student?>(
                    future: dbHelper.getStudentById(lesson.studentId),
                    builder: (context, snapshot) {
                      final studentName = snapshot.hasData
                          ? snapshot.data!.fullName
                          : 'Студент без имени';
                      final time = DateFormat('HH:mm').format(lesson.dateTime);
                      return Dismissible(
                        key: Key(lesson.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.black),
                        ),
                        onDismissed: (_) => _deleteLesson(lesson),
                        child: ListTile(
                          title: Text(
                            studentName,
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            '${time} - ${_formatDuration(lesson.duration)}',
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 16,
                            ),
                          ),
                          trailing: Checkbox(
                            side: BorderSide(
                              color: Colors.deepPurple,
                              width: 2,
                            ),
                            checkColor: Colors.yellow,
                            hoverColor: Colors.deepPurple,
                            focusColor: Colors.deepPurple,
                            activeColor: Colors.deepPurple,

                            value: lesson.isCompleted,
                            onChanged: (value) async {
                              if (value != null) {
                                final updateLesson = Lesson(
                                  id: lesson.id,
                                  studentId: lesson.studentId,
                                  dateTime: lesson.dateTime,
                                  duration: lesson.duration,
                                  isCompleted: value,
                                  amount: lesson.amount,
                                );
                                await dbHelper.updateLesson(updateLesson);
                                setState(() {
                                  _lessons[index] = updateLesson;
                                });
                              }
                            },
                          ),
                          onTap: () => _editLesson(lesson),
                          onLongPress: () => _openStudentCard(lesson),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow.shade200,
        onPressed: _addLesson,
        child: Icon(Icons.add, size: 40, color: Colors.deepPurple),
      ),
    );
  }
}
