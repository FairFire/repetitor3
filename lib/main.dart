import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:repetitor/screens/setting_screen.dart';
//import 'package:intl/date_symbol_data_file.dart' as file;
import 'screens/archive_screen.dart';
import 'screens/home_screen.dart';
import 'screens/students_screen.dart';
import 'screens/income_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Репетитор',
      locale: const Locale('ru', 'RU'),
      supportedLocales: const [Locale('ru', 'RU'), Locale('en', 'US')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    StudentsScreen(),
    ArchiveScreen(),
    IncomeScreen(),
    SettingScreen(),
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentScreen = _widgetOptions.elementAt(_selectedIndex);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      //body: _widgetOptions.elementAt(_selectedIndex),
      appBar: AppBar(
        title: switch (_selectedIndex) {
          0 => const Text('Расписание'),
          1 => const Text('Студенты'),
          2 => const Text('Архив'),
          3 => const Text('Доход за месяц'),
          4 => const Text('Настройка'),
          _ => const Text('Репетитор'),
        },
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Меню',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Расписание'),
              selected: _selectedIndex == 0,
              onTap: () {
                Navigator.pop(context);
                _onItemTap(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Ученики'),
              selected: _selectedIndex == 1,
              onTap: () {
                Navigator.pop(context);
                _onItemTap(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Архив'),
              selected: _selectedIndex == 2,
              onTap: () {
                Navigator.pop(context);
                _onItemTap(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on),
              title: const Text('Доход'),
              selected: _selectedIndex == 3,
              onTap: () {
                Navigator.pop(context);
                _onItemTap(3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Настройка'),
              selected: _selectedIndex == 4,
              onTap: () {
                Navigator.pop(context);
                _onItemTap(4);
              },
            ),
          ],
        ),
      ),

      body: currentScreen,
    );
  }
}
