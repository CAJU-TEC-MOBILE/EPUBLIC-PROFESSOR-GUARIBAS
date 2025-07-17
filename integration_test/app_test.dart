import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/pages/login_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Verifica se o texto "Login" aparece na tela', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });
}
