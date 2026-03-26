import 'package:finly/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app smoke test', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FinlyApp()),
    );
    await tester.pump();
  });
}
