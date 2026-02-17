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
      theme: ThemeData(primarySwatch: Colors.blue),
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
        iconTheme: IconThemeData(color: Colors.yellow.shade200),
        backgroundColor: Colors.deepPurple,
        title: switch (_selectedIndex) {
          0 => Text(
            'Расписание',
            style: TextStyle(
              color: Colors.yellow.shade200,
              fontWeight: FontWeight.bold,
            ),
          ),
          1 => Text(
            'Ученики',
            style: TextStyle(
              color: Colors.yellow.shade200,
              fontWeight: FontWeight.bold,
            ),
          ),
          2 => Text(
            'Архив',
            style: TextStyle(
              color: Colors.yellow.shade200,
              fontWeight: FontWeight.bold,
            ),
          ),
          3 => Text(
            'Доход за месяц',
            style: TextStyle(
              color: Colors.yellow.shade200,
              fontWeight: FontWeight.bold,
            ),
          ),
          4 => Text(
            'Настройка',
            style: TextStyle(
              color: Colors.yellow.shade200,
              fontWeight: FontWeight.bold,
            ),
          ),
          _ => Text(
            'Репетитор',
            style: TextStyle(
              color: Colors.yellow.shade200,
              fontWeight: FontWeight.bold,
            ),
          ),
        },
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.yellow[200],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.deepPurple),
                child: Text(
                  'Меню',
                  style: TextStyle(
                    color: Colors.yellow[200],
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                textColor: Colors.deepPurple,
                leading: const Icon(
                  Icons.calendar_today,
                  color: Colors.deepPurple,
                ),
                selected: _selectedIndex == 0,
                title: Text(
                  'Расписание',
                  style: TextStyle(
                    fontWeight: _selectedIndex == 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _onItemTap(0);
                },
              ),
              ListTile(
                textColor: Colors.deepPurple,
                leading: const Icon(Icons.person, color: Colors.deepPurple),
                title: Text(
                  'Ученики',
                  style: TextStyle(
                    fontWeight: _selectedIndex == 1
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                selected: _selectedIndex == 1,
                onTap: () {
                  Navigator.pop(context);
                  _onItemTap(1);
                },
              ),
              ListTile(
                textColor: Colors.deepPurple,
                leading: const Icon(Icons.person, color: Colors.deepPurple),
                title: Text(
                  'Архив',
                  style: TextStyle(
                    fontWeight: _selectedIndex == 2
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                selected: _selectedIndex == 2,
                onTap: () {
                  Navigator.pop(context);
                  _onItemTap(2);
                },
              ),
              ListTile(
                textColor: Colors.deepPurple,
                leading: const Icon(
                  Icons.monetization_on,
                  color: Colors.deepPurple,
                ),
                title: Text(
                  'Доход',
                  style: TextStyle(
                    fontWeight: _selectedIndex == 3
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                selected: _selectedIndex == 3,
                onTap: () {
                  Navigator.pop(context);
                  _onItemTap(3);
                },
              ),
              ListTile(
                textColor: Colors.deepPurple,
                leading: const Icon(Icons.settings, color: Colors.deepPurple),
                title: Text(
                  'Настройка',
                  style: TextStyle(
                    fontWeight: _selectedIndex == 4
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                selected: _selectedIndex == 4,
                onTap: () {
                  Navigator.pop(context);
                  _onItemTap(4);
                },
              ),
            ],
          ),
        ),
      ),

      body: currentScreen,
    );
  }
}
