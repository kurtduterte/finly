import 'package:finly/features/auth/presentation/providers/auth_providers.dart';
import 'package:finly/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:finly/features/home/presentation/screens/home_screen.dart';
import 'package:finly/features/model_setup/presentation/widgets/gemma_status_icon.dart';
import 'package:finly/features/scan/presentation/screens/scan_screen.dart';
import 'package:finly/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _destinations = [
  NavigationDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
    label: 'Home',
  ),
  NavigationDestination(
    icon: Icon(Icons.receipt_long_outlined),
    selectedIcon: Icon(Icons.receipt_long),
    label: 'Expenses',
  ),
  NavigationDestination(
    icon: Icon(Icons.document_scanner_outlined),
    selectedIcon: Icon(Icons.document_scanner),
    label: 'Scan',
  ),
  NavigationDestination(
    icon: Icon(Icons.settings_outlined),
    selectedIcon: Icon(Icons.settings),
    label: 'Settings',
  ),
];

const _titles = ['Finly', 'Expenses', 'Scan Receipt', 'Settings'];

const _pages = [
  HomeScreen(),
  ExpensesScreen(),
  ScanScreen(),
  SettingsScreen(),
];

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          const GemmaStatusIcon(),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () =>
                ref.read(authNotifierProvider.notifier).signOut(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _destinations,
      ),
    );
  }
}
