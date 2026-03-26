import 'package:finly/ai/gemma_service.dart';
import 'package:finly/features/ai_test/presentation/screens/ai_test_screen.dart';
import 'package:finly/features/model_setup/presentation/screens/model_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterGemma.initialize();
  runApp(const ProviderScope(child: FinlyApp()));
}

class FinlyApp extends StatelessWidget {
  const FinlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _StartupRouter(),
    );
  }
}

// Checks if the model is already loaded; routes accordingly
class _StartupRouter extends StatefulWidget {
  @override
  State<_StartupRouter> createState() => _StartupRouterState();
}

class _StartupRouterState extends State<_StartupRouter> {
  final _gemmaService = GemmaService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _gemmaService.isModelReady(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data!) {
          return AiTestScreen(gemmaService: _gemmaService);
        }
        return ModelSetupScreen(gemmaService: _gemmaService);
      },
    );
  }
}
