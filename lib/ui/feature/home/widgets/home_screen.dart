import 'package:finly/ui/core/ui/navbar.dart';
import 'package:finly/ui/feature/home/view_models/home_viewmodel.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Navbar(),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return const Center(
            child: Text(
              'Hello World',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
    );
  }
}
