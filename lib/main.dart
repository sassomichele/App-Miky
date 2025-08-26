
import 'package:flutter/material.dart';
import 'src/db_helper.dart';
import 'src/screens/chat_screen.dart';
import 'src/screens/mail_screen.dart';
import 'src/screens/calendar_screen.dart';
import 'src/screens/contacts_screen.dart';
import 'src/screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int index = 0;
  ThemeMode mode = ThemeMode.system;

  void setThemeMode(ThemeMode m) => setState(() => mode = m);

  @override
  Widget build(BuildContext context) {
    final pages = [
      const ChatScreen(),
      const MailScreen(),
      const CalendarScreen(),
      const ContactsScreen(),
      SettingsScreen(onThemeChange: setThemeMode),
    ];
    return MaterialApp(
      title: 'All-in-One v5',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A2342)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A2342), brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: mode,
      home: Scaffold(
        appBar: AppBar(title: const Text('All-in-One v5')),
        body: pages[index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
            NavigationDestination(icon: Icon(Icons.mail_outline), label: 'Mail'),
            NavigationDestination(icon: Icon(Icons.event_available_outlined), label: 'Calend'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Contatti'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Impost.'),
          ],
        ),
      ),
    );
  }
}
