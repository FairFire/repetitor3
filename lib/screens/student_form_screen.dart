import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:repetitor/database/db_helper.dart';
import 'package:repetitor/models/student.dart';
import 'package:repetitor/screens/student_comments_screen.dart';

class StudentFormScreen extends StatefulWidget {
  final Student? student;
  const StudentFormScreen({super.key, this.student});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _phone1Controller;
  late TextEditingController _phone2Controller;
  late DateTime _startDate;
  late String _level;
  final _dbHelper = DBHelper();
  static const List<String> _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  final DateFormat _dateFormatter = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    final student = widget.student;
    _nameController = TextEditingController(text: student?.fullName ?? '');
    _priceController = TextEditingController(
      text: student?.price.toString() ?? '',
    );
    _phone1Controller = TextEditingController(text: student?.phone1 ?? '');
    _phone2Controller = TextEditingController(text: student?.phone2 ?? '');
    _startDate = student?.startDate ?? DateTime.now();
    _level = student?.level ?? 'A1';
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
      final phone1 = _phone1Controller.text.trim().isEmpty
          ? '-'
          : _phone1Controller.text.trim();
      final phone2 = _phone2Controller.text.trim().isEmpty
          ? '-'
          : _phone2Controller.text.trim();

      if (name.isEmpty || price < 0) {
        return;
      }

      final student = Student(
        id: widget.student?.id,
        fullName: name,
        price: price,
        startDate: _startDate,
        level: _level,
        phone1: phone1,
        phone2: phone2,
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          widget.student == null ? 'Новый ученик' : 'Редактирование ученика',
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ФИО ученика',
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
                      return 'Введите ФИО ученика';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Цена за час (Р)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final num = int.tryParse(value ?? '');
                    if (num == null || num < 0) {
                      return 'Введите корректную цену занятия';
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 20),

                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2010),
                      lastDate: DateTime(2050),
                      locale: const Locale('ru'),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Дата начала занятий',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _dateFormatter.format(_startDate),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),

                SizedBox(height: 16),
                DropdownButtonFormField(
                  items: _levels.map((level) {
                    return DropdownMenuItem(value: level, child: Text(level));
                  }).toList(),
                  initialValue: _level,
                  onChanged: (val) => setState(() => _level = val!),
                  decoration: const InputDecoration(
                    labelText: 'Уровень',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _phone1Controller,
                  decoration: const InputDecoration(
                    labelText: 'Телефон 1',
                    hintText: 'Необязательное поле',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _phone2Controller,
                  decoration: const InputDecoration(
                    labelText: 'Телефон 2',
                    hintText: 'Необязательное поле',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),

                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    final student = widget.student;
                    if (student != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentCommentsScreen(
                            studentId: student.id!,
                            studentName: student.fullName,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Сначала сохраните студента')),
                      );
                    }
                  },
                  label: const Text('Комментарии'),
                  icon: Icon(Icons.comment),
                ),

                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveStudent,
                    child: Text(
                      widget.student == null ? 'Добавить' : 'Изменить',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
