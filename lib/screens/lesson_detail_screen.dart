// lib/screens/lesson_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/lesson.dart';
import '../models/student.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson? initialLesson;
  final int? lessonId;

  const LessonDetailScreen.edit({super.key, required int lessonId})
    : initialLesson = null,
      lessonId = lessonId;

  const LessonDetailScreen.create({super.key, required Lesson lesson})
    : initialLesson = lesson,
      lessonId = null;

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  Lesson? _lesson;
  late Future<List<Student>> _studentsFuture;
  final dbHelper = DBHelper();
  final DateFormat _dateFormatter = DateFormat('dd.MM.yyyy');
  final DateFormat _timeFormatter = DateFormat('HH:mm');
  bool _isAmountManuallySet = false;
  late TextEditingController _amountController;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _studentsFuture = dbHelper.getStudents();
    _amountController = TextEditingController();
    _commentController = TextEditingController();
    if (widget.initialLesson != null) {
      _lesson = widget.initialLesson;
      _amountController.text = _lesson!.amount.toStringAsFixed(0);
      _commentController.text = _lesson!.comment ?? '';
    } else if (widget.lessonId != null) {
      dbHelper
          .getLessonById(widget.lessonId!)
          .then((lesson) {
            if (lesson != null) {
              setState(() {
                _lesson = lesson;
                _amountController.text = lesson.amount.toStringAsFixed(0);
                _commentController.text = lesson.comment ?? '';
              });
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Урок не найден')));
                Navigator.pop(context);
              }
            }
          })
          .catchError((error) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Ошибка загрузки: $error')));
            Navigator.pop(context);
          });
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: не указан урок')));
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_lesson == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Карточка урока'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: FutureBuilder<List<Student>>(
        future: _studentsFuture,
        builder: (context, studentsSnapshot) {
          if (studentsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (studentsSnapshot.hasError || studentsSnapshot.data == null) {
            return const Center(child: Text('Не удалось загрузить учеников'));
          }

          final students = studentsSnapshot.data!;
          if (students.isEmpty) {
            return const Center(
              child: Text('Нет учеников. Добавьте хотя бы одного.'),
            );
          }
          students.sort((a, b) => a.fullName.compareTo(b.fullName));

          // Убедимся, что studentId корректен
          if (!students.any((s) => s.id == _lesson!.studentId)) {
            setState(() {
              _lesson = Lesson(
                id: _lesson!.id,
                studentId: students[0].id!,
                dateTime: _lesson!.dateTime,
                duration: _lesson!.duration,
                amount: students[0].price * _lesson!.duration.toDouble(),
              );
            });
          }

          final currentStudent = students.firstWhere(
            (s) => s.id == _lesson!.studentId,
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Выбор студента
                  DropdownButtonFormField<int>(
                    initialValue: _lesson!.studentId,
                    items: students.map((s) {
                      return DropdownMenuItem(
                        value: s.id,
                        child: Text('${s.fullName} (${s.price} ₽/ч)'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final newStudent = students.firstWhere(
                          (s) => s.id == val,
                        );
                        final newAmount = newStudent.price * _lesson!.duration;
                        setState(() {
                          _lesson = Lesson(
                            id: _lesson!.id,
                            studentId: val,
                            dateTime: _lesson!.dateTime,
                            duration: _lesson!.duration,
                            amount: _isAmountManuallySet
                                ? _lesson!.amount
                                : newAmount,
                          );
                          if (!_isAmountManuallySet) {
                            _amountController.text = newAmount.toStringAsFixed(
                              0,
                            );
                          }
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Ученик',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDateTimeField(
                    label: 'Дата занятия',
                    value: _dateFormatter.format(_lesson!.dateTime),
                    icon: Icons.calendar_today,
                    onPressed: () async {
                      final selectDate = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2080),
                        locale: const Locale('ru'),
                      );
                      if (selectDate != null) {
                        setState(() {
                          _lesson = Lesson(
                            id: _lesson!.id,
                            studentId: _lesson!.studentId,
                            dateTime: DateTime(
                              selectDate.year,
                              selectDate.month,
                              selectDate.day,
                              _lesson!.dateTime.hour,
                              _lesson!.dateTime.minute,
                            ),
                            duration: _lesson!.duration,
                            amount: _lesson!.amount,
                          );
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildDateTimeField(
                    label: 'Время занятия',
                    value: _timeFormatter.format(_lesson!.dateTime),
                    icon: Icons.access_time,
                    onPressed: () async {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_lesson!.dateTime),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(platform: TargetPlatform.android),
                            child: child!,
                          );
                        },
                      );
                      if (selectedTime != null) {
                        setState(() {
                          _lesson = Lesson(
                            id: _lesson!.id,
                            studentId: _lesson!.studentId,
                            dateTime: DateTime(
                              _lesson!.dateTime.year,
                              _lesson!.dateTime.month,
                              _lesson!.dateTime.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            ),
                            duration: _lesson!.duration,
                            amount: _lesson!.amount,
                          );
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Длительность
                  DropdownButtonFormField<double>(
                    initialValue: _lesson!.duration,
                    items: const [
                      DropdownMenuItem(value: 1.0, child: Text('1 час')),
                      DropdownMenuItem(value: 1.5, child: Text('1.5 часа')),
                      DropdownMenuItem(value: 2.0, child: Text('2 часа')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        final newAmount = currentStudent.price * val;
                        setState(() {
                          _lesson = Lesson(
                            id: _lesson!.id,
                            studentId: _lesson!.studentId,
                            dateTime: _lesson!.dateTime,
                            duration: val,
                            amount: _isAmountManuallySet
                                ? _lesson!.amount
                                : newAmount,
                          );
                          if (!_isAmountManuallySet) {
                            _amountController.text = newAmount.toStringAsFixed(
                              0,
                            );
                          }
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Длительность',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Сумма (только для чтения)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Сумма (₽)',
                            helperText: _isAmountManuallySet
                                ? 'Введено вручную'
                                : 'Рассчитана: ${currentStudent.price} ₽/ч × ${_lesson!.duration} ч',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          controller: _amountController,
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null) {
                              setState(() {
                                _lesson = Lesson(
                                  id: _lesson!.id,
                                  studentId: _lesson!.studentId,
                                  dateTime: _lesson!.dateTime,
                                  duration: _lesson!.duration,
                                  amount: parsed,
                                );
                                _isAmountManuallySet = true;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Вернуть автосумму',
                        onPressed: () {
                          setState(() {
                            final newAmount =
                                currentStudent.price * _lesson!.duration;
                            _lesson = Lesson(
                              id: _lesson!.id,
                              studentId: _lesson!.studentId,
                              dateTime: _lesson!.dateTime,
                              duration: _lesson!.duration,
                              amount: newAmount,
                            );
                            _amountController.text = newAmount.toStringAsFixed(
                              0,
                            );
                            _isAmountManuallySet = false;
                          });
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ListTile(
                    title: const Text('Урок оплачен'),
                    leading: Checkbox(
                      value: _lesson!.isCompleted,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _lesson = Lesson(
                              id: _lesson!.id,
                              studentId: _lesson!.studentId,
                              dateTime: _lesson!.dateTime,
                              duration: _lesson!.duration,
                              amount: _lesson!.amount,
                              isCompleted: value,
                            );
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: 'Комментарий',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                    onChanged: (value) {
                      setState(() {
                        _lesson = Lesson(
                          id: _lesson!.id,
                          studentId: _lesson!.studentId,
                          dateTime: _lesson!.dateTime,
                          duration: _lesson!.duration,
                          amount: _lesson!.amount,
                          isCompleted: _lesson!.isCompleted,
                          comment: value.isEmpty ? null : value,
                        );
                      });
                    },
                  ),

                  const SizedBox(height: 32),
                  // Кнопка сохранения
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_lesson!.id == null) {
                          // final id = await dbHelper.insertLesson(_lesson!);
                          await dbHelper.insertLesson(_lesson!);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Урок добавлен!')),
                            );
                            Navigator.pop(context, true);
                          }
                        } else {
                          await dbHelper.updateLesson(_lesson!);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Изменения сохранены'),
                              ),
                            );
                            Navigator.pop(context, true);
                          }
                        }
                      },
                      child: const Text('Сохранить'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
