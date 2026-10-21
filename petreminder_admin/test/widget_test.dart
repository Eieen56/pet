import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petreminder_admin/features/users/presentation/widgets/status_badge.dart';

void main() {
  testWidgets('shows the active account status', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: StatusBadge(active: true))),
    );

    expect(find.text('Activa'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });

  testWidgets('shows the disabled account status', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: StatusBadge(active: false))),
    );

    expect(find.text('Deshabilitada'), findsOneWidget);
    expect(find.byIcon(Icons.block_outlined), findsOneWidget);
  });
}
