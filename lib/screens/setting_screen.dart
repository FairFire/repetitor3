import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  Future<String> _getAddDbPath() async {
    final dir = await getDatabasesPath();
    return path.join(dir, 'repetitor.db');
  }

  Future<void> _exportDatabase() async {
    String pathDownload = '/storage/emulated/0/Download';
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (status != PermissionStatus.granted) {
        ScaffoldMessenger.of(
          GlobalKey<NavigatorState>().currentContext!,
        ).showSnackBar(
          const SnackBar(content: Text('Нужно разрешение на запись!')),
        );
        return;
      }
    }
    try {
      final dbPath = await _getAddDbPath();
      final dbFile = File(dbPath);
      if (!await dbFile.exists()) {
        _showMessage('База данных не найдена');
        return;
      }

      final downloadsDir = Platform.isAndroid
          ? Directory(pathDownload)
          : await getApplicationDocumentsDirectory();
      if (!(await downloadsDir.exists())) {
        await downloadsDir.create(recursive: true);
      }

      final targetFile = File(
        '${downloadsDir.path}/tutor_backup_${DateTime.now().millisecondsSinceEpoch}.db',
      );
      await dbFile.copy(targetFile.path);
      _showMessage('Резервная копия сохранена: \n ${targetFile.path}');
    } catch (e) {
      _showMessage('Ошиибка экспорта: $e');
    }
  }

  Future<void> _importDatabase() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (result == null) return;

      final filePath = result.files.single.path!;
      final sourceFile = File(filePath);
      if (!await sourceFile.exists()) {
        _showMessage('Файл не найден');
        return;
      }

      final dbPath = await _getAddDbPath();
      final targetFile = File(dbPath);

      await sourceFile.copy(dbPath);
      _showMessage('База данных восстановлена! \n Перезагрузите приложение');
    } catch (e) {
      _showMessage('Ошибка импорта: $e');
    }
  }

  void _showMessage(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(
        GlobalKey<NavigatorState>().currentContext!,
      ).showSnackBar(SnackBar(content: Text(message)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Настройка'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsetsGeometry.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Резервное копирование',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text('Экспорт: сохранит файл базы данных в папку Download.'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _exportDatabase,
              label: const Text('Создать резеврную копию'),
              icon: const Icon(Icons.save),
            ),
            const SizedBox(height: 24),
            const Text('Импорт: заменит текущую базу данных выбранным файлом'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _importDatabase,
              icon: const Icon(Icons.upload),
              label: const Text('Восстановить из файла'),
            ),
            const SizedBox(height: 32),
            const Text('После перезапустите приложение!'),
          ],
        ),
      ),
    );
  }
}
