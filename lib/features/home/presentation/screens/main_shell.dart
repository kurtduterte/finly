import 'package:finly/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:finly/features/home/presentation/screens/home_screen.dart';
import 'package:finly/features/scan/presentation/screens/scan_screen.dart';
import 'package:finly/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';

const _destinations = [
  NavigationDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home_rounded),
    label: 'Home',
  ),
  NavigationDestination(
    icon: Icon(Icons.receipt_long_outlined),
    selectedIcon: Icon(Icons.receipt_long_rounded),
    label: 'Expenses',
  ),
  NavigationDestination(
    icon: Icon(Icons.document_scanner_outlined),
    selectedIcon: Icon(Icons.document_scanner_rounded),
    label: 'Scan',
  ),
  NavigationDestination(
    icon: Icon(Icons.person_outline_rounded),
    selectedIcon: Icon(Icons.person_rounded),
    label: 'Profile',
  ),
];

const List<Widget> _pages = [
  HomeScreen(),
  ExpensesScreen(),
  ScanScreen(),
  SettingsScreen(),
];

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _destinations,
      ),
    );
  }
}
