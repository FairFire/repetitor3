import 'package:flutter/material.dart';
import 'package:repetitor/database/db_helper.dart';
import 'package:repetitor/models/student.dart';
import 'package:repetitor/screens/student_comments_screen.dart';
import 'package:repetitor/screens/student_form_screen.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  late Future<List<Student>> _studentsFuture;
  final dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _refreshStudents();
  }

  void _refreshStudents() {
    setState(() {
      _studentsFuture = dbHelper.getStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: Text('Студенты'),
        leading: IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: Icon(Icons.close),
        ),
      ),*/
      resizeToAvoidBottomInset: true,
      body: FutureBuilder(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          final students = snapshot.data!;
          return students.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Студенты не найдены',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        trailing: IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentCommentsScreen(
                                  studentId: student.id!,
                                  studentName: student.fullName,
                                ),
                              ),
                            );
                          },
                        ),
                        title: Text(student.fullName),
                        subtitle: Text('${student.price} ₽/час'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StudentFormScreen(student: student),
                            ),
                          ).then((_) => _refreshStudents());
                        },
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StudentFormScreen()),
          ).then((_) => _refreshStudents());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
