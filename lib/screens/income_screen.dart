import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:repetitor/screens/student_income_detail_screen.dart';

import '../database/db_helper.dart';
import '../models/lesson.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  late DateTime _selectedMonth;
  late Future<List<Lesson>> _lessonsFuture;
  final dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _lessonsFuture = dbHelper.getLessonsForMonth(_selectedMonth);
    });
  }

  void _selectMonth(int year, int month) {
    setState(() {
      _selectedMonth = DateTime(year, month);
      _refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MM.yyyy').format(_selectedMonth);
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    onChanged: (month) {
                      if (month != null) {
                        _selectMonth(_selectedMonth.year, month);
                      }
                    },
                    value: _selectedMonth.month,
                    items: List.generate(12, (i) => i + 1)
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(
                              DateFormat('MMMM').format(DateTime(2020, m)),
                            ),
                          ),
                        )
                        .toList(),
                    decoration: const InputDecoration(labelText: 'Месяц'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField(
                    value: _selectedMonth.year,
                    items: List.generate(5, (i) => DateTime.now().year - 2 + i)
                        .map(
                          (y) => DropdownMenuItem(
                            value: y,
                            child: Text(y.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (year) {
                      if (year != null)
                        _selectMonth(year, _selectedMonth.month);
                    },
                    decoration: const InputDecoration(labelText: 'Год'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Lesson>>(
              future: _lessonsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final lessons = snapshot.data ?? [];
                final Map<int, List<Lesson>> lessonsByStudents = {};

                // Группируем уроки по студенту
                for (final lesson in lessons) {
                  lessonsByStudents
                      .putIfAbsent(lesson.studentId, () => [])
                      .add(lesson);
                }
                // Считаем итог
                double totalIncome = lessons.fold(
                  0,
                  (sum, lesson) => sum = sum + lesson.amount,
                );
                return Column(
                  children: [
                    //Итоговая сумма
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Итого за $monthName: ${totalIncome.toStringAsFixed(0)} P',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const Divider(),

                    // Список студентов
                    Expanded(
                      child: lessonsByStudents.isEmpty
                          ? const Center(
                              child: Text('Нет занятий в этом месяце'),
                            )
                          : FutureBuilder(
                              future: dbHelper.getStudents(),
                              builder: (context, studentSnapshoot) {
                                if (studentSnapshoot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                final allStudent = studentSnapshoot.data ?? [];
                                final studentMap = {
                                  for (var s in allStudent) s.id: s,
                                };
                                return ListView.builder(
                                  itemCount: lessonsByStudents.length,
                                  itemBuilder: (context, index) {
                                    final studentID = lessonsByStudents.keys
                                        .elementAt(index);
                                    final studentLesson =
                                        lessonsByStudents[studentID];
                                    final student = studentMap[studentID];
                                    final totalHours = studentLesson!.fold(
                                      0.0,
                                      (sum, lesson) => sum + lesson.duration,
                                    );
                                    final totalAmount = studentLesson.fold(
                                      0.0,
                                      (sum, lesson) =>
                                          sum = sum + lesson.amount,
                                    );
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          student?.fullName ??
                                              'Студент №$studentID',
                                        ),
                                        subtitle: Text(
                                          '${totalHours.toStringAsFixed(1)} ч * ${totalAmount.toStringAsFixed(0)} P',
                                        ),
                                        trailing: Text(
                                          '+${totalAmount.toStringAsFixed(0)} P',
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  StudentIncomeDetailScreen(
                                                    studentId: studentID,
                                                    month: _selectedMonth,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
