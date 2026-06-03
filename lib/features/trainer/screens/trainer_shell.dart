import 'package:flutter/material.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/features/trainer/screens/trainer_home_screen.dart';
import 'package:groove_app/features/trainer/screens/trainer_profile_screen.dart';
import 'package:groove_app/features/trainer/screens/trainer_schedule_edit_screen.dart';

class TrainerShell extends StatefulWidget {
  const TrainerShell({super.key});

  @override
  State<TrainerShell> createState() => _TrainerShellState();
}

class _TrainerShellState extends State<TrainerShell> {
  int _currentIndex = 0;

  static const _titles = ['Главная', 'Заполнение расписания', 'Профиль'];

  final _screens = [
    TrainerHomeScreen(),
    TrainerScheduleEditScreen(),
    TrainerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        color: ElementsPurple,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: ElementsPurple,
          selectedItemColor: ProcessYellow,
          unselectedItemColor: Colors.white.withValues(alpha: 0.75),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_calendar),
              label: 'Заполнение расписания',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}
