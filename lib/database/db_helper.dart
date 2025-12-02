import 'package:path/path.dart';
import 'package:repetitor/models/comment.dart';
import 'package:sqflite/sqflite.dart';
import '../models/lesson.dart';
import '../models/student.dart';

// Класс для работы с базой данных
class DBHelper {
  static Database? _db;
  static const String _dbName = 'tutor_app.db';
  static const int _version = 3; // увеличена версия для обновления схемы

  // Получить экземпляр базы данных
  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  // Инициализация базы данных
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _version,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fullName TEXT NOT NULL,
            price INTEGER NOT NULL
            startDate INTEGER NOT NULL,
            level TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE lessons(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            studentId INTEGER NOT NULL,
            dateTime INTEGER NOT NULL,
            duration REAL NOT NULL,
            amount REAL NOT NULL,
            FOREIGN KEY (studentId) REFERENCES students(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE comments(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            studentId INTEGER NOT NULL,
            text TEXT NOT NULL,
            createdAt INTEGER NOT NULL,
            FOREIGN KEY (studentId) REFERENCES students(id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Добавляем новые колонки
          await db.execute(
            'ALTER TABLE students ADD COLUMN startDate INTEGER DEFAULT 0',
          );
          await db.execute(
            'ALTER TABLE students ADD COLUMN level TEXT DEFAULT "A1"',
          );

          // Обновляем существующие записи (если нужно)
          final nowMs = DateTime.now().millisecondsSinceEpoch;
          await db.execute(
            'UPDATE students SET startDate = ?, level = ? WHERE startDate = 0',
            [nowMs, 'A1'],
          );
        }
      },
    );
  }

  // === Студенты ===
  Future<int> insertStudent(Student student) async {
    final db = await this.db;
    return await db.insert('students', student.toMap());
  }

  //Обновить студента
  Future<int> updateStudent(Student student) async {
    final db = await this.db;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  //Получить всех студентов
  Future<List<Student>> getStudents() async {
    final db = await this.db;
    final maps = await db.query('students');
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  //Получить студента по id
  Future<Student?> getStudentById(int id) async {
    final db = await this.db;
    final maps = await db.query('students', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Student.fromMap(maps.first);
  }

  // УРОКИ
  Future<int> insertLesson(Lesson lesson) async {
    final db = await this.db;
    return await db.insert('lessons', lesson.toMap());
  }

  //Обновить урок
  Future<int> updateLesson(Lesson lesson) async {
    final db = await this.db;
    return await db.update(
      'lessons',
      lesson.toMap(),
      where: 'id = ?',
      whereArgs: [lesson.id],
    );
  }

  //Удалить урок
  Future<int> deleteLesson(int id) async {
    final db = await this.db;
    return await db.delete('lessons', where: 'id = ?', whereArgs: [id]);
  }

  //Получить уроки за неделю
  Future<List<Lesson>> getLessonsForWeek(DateTime weekStart) async {
    final startMs = weekStart.millisecondsSinceEpoch;
    final endMs = weekStart.add(const Duration(days: 7)).millisecondsSinceEpoch;
    final db = await this.db;
    final maps = await db.query(
      'lessons',
      where: 'dateTime >= ? AND dateTime < ?',
      whereArgs: [startMs, endMs],
      orderBy: 'dateTime ASC',
    );
    return List.generate(maps.length, (i) => Lesson.fromMap(maps[i]));
  }

  //Получить урок по id
  Future<Lesson?> getLessonById(int id) async {
    final db = await this.db;
    final maps = await db.query('lessons', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Lesson.fromMap(maps.first);
  }

  //Получить уроки за месяц
  Future<List<Lesson>> getLessonsForMonth(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;

    final db = await this.db;
    final maps = await db.query(
      'lessons',
      where: 'dateTime >= ? AND dateTime < ?',
      whereArgs: [startMs, endMs],
      orderBy: 'dateTime ASC',
    );
    return List.generate(maps.length, (i) => Lesson.fromMap(maps[i]));
  }

  // Получить уроки за месяц для конкретного студента
  Future<List<Lesson>> getLessonsForStudentInMonth(
    int studentId,
    DateTime month,
  ) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;

    final db = await this.db;
    final maps = await db.query(
      'lessons',
      where: 'studentId = ? AND dateTime >= ? AND dateTime < ?',
      whereArgs: [studentId, startMs, endMs],
      orderBy: 'dateTime ASC',
    );
    return List.generate(maps.length, (i) => Lesson.fromMap(maps[i]));
  }

  //Работаем с комментариями

  Future<int> insertComment(Comment comment) async {
    final db = await this.db;
    return await db.insert('comments', comment.toMap());
  }

  Future<int> deleteComment(int id) async {
    final db = await this.db;
    return await db.delete('comments', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Comment>> getCommentsByStudent(int studentId) async {
    final db = await this.db;
    final maps = await db.query(
      'commets',
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Comment.fromMap(maps[i]));
  }
}
