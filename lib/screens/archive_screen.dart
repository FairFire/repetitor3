import 'package:flutter/material.dart';
import 'package:repetitor/database/db_helper.dart';
import 'package:repetitor/models/student.dart';
import 'package:repetitor/screens/student_form_screen.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  late Future<List<Student>> _archivedStudentsFuture;
  final dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _archivedStudentsFuture = dbHelper.getArchivedStudents();
  }

  void _refresh() {
    setState(() {
      _archivedStudentsFuture = dbHelper.getArchivedStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Архив учеников')),
      body: FutureBuilder(
        future: _archivedStudentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          final students = snapshot.data!;
          students.sort((a, b) => a.fullName.compareTo(b.fullName));
          return students.isEmpty
              ? const Center(child: Text('Архив пуст'))
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
                        title: Text(student.fullName),
                        subtitle: Text('${student.price} ₽/час'),
                        trailing: IconButton(
                          icon: const Icon(Icons.restore),
                          onPressed: () async {
                            final update = student.copyWith(isActive: true);
                            await dbHelper.updateStudent(update);
                            _refresh();
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StudentFormScreen(student: student),
                            ),
                          ).then((_) => _refresh());
                        },
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
