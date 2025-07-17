import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:professor_acesso_notifiq/data/database/database_hive.dart';
import 'package:professor_acesso_notifiq/main.dart';
import 'package:professor_acesso_notifiq/pages/home_page.dart';
import 'package:professor_acesso_notifiq/services/shared_preference_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Teste completo de login', (tester) async {
    final preferenceService = SharedPreferenceService();

    await initializeDateFormatting('pt_BR');

    await preferenceService.init();

    await preferenceService.limparDados();

    String route = await preferenceService.nextRoute();

    await HiveConfig.start();

    await tester.pumpWidget(MyApp(
      nextRoute: route,
    ));

    await tester.pumpAndSettle();
    final cpfField = find.byKey(const Key('cpf_field'));
    await tester.enterText(cpfField, '77777777777');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    final senhaField = find.byKey(const Key('senha_field'));
    await tester.enterText(senhaField, '01012000');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    final loginButton = find.byKey(const Key('btn_login'));
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(HomePage), findsOneWidget);

    final sucessoMessage = find.text('Logado com sucesso!');
    expect(sucessoMessage, findsOneWidget);
  });
}
