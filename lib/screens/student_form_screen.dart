import 'package:flutter/material.dart';
import 'package:repetitor/database/db_helper.dart';
import 'package:repetitor/models/student.dart';

class StudentFormScreen extends StatefulWidget {
  final Student? student;
  const StudentFormScreen({Key? key, this.student}) : super(key: key);

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  final _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    final student = widget.student;
    _nameController = TextEditingController(text: student?.fullName ?? '');
    _priceController = TextEditingController(
      text: student?.price.toString() ?? '',
    );
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _priceController.dispose();
  }

  void _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final name = _nameController.text.trim();
      final price = int.tryParse(_priceController.text.trim()) ?? 1000;

      if (name.isEmpty || price <= 0) {
        return;
      }

      final student = Student(
        id: widget.student?.id,
        fullName: name,
        price: price,
      );

      if (widget.student == null) {
        await _dbHelper.insertStudent(student);
      } else {
        await _dbHelper.updateStudent(student);
      }

      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.student == null ? 'Новый студент' : 'Редактирование студента',
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ФИО студента',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Иванов Иван Иванович',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите ФИО студента';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Цена за час'),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  hintText: '2000',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final num = int.tryParse(value ?? '');
                  if (num == null || num <= 0) {
                    return 'Введите корректную цену занятия';
                  } else {
                    return null;
                  }
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveStudent,
                  child: Text(widget.student == null ? 'Добавить' : 'Изменить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
