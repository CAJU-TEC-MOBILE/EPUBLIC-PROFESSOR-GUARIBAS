// helpers/console_log.dart
import 'package:flutter/material.dart';

import '../../enums/status_console.dart';

class ConsoleLog {
  static void mensagem({
    required String titulo,
    required String mensagem,
    required StatusConsole tipo,
  }) {
    String colorCode = tipo.getCor();
    String resetColor = '\x1B[0m';
    debugPrint(
      '================\n$colorCode$titulo: \n $mensagem$resetColor\n================',
    );
  }

  static void logError({
    required Object error,
    required StackTrace stackTrace,
    String? className,
    String? methodName,
  }) {
    final errorMessage = '''
Ocorreu um erro ao processar a solicitação.
Classe: ${className ?? 'Desconhecida'}
Método: ${methodName ?? 'Desconhecido'}
Erro: $error
StackTrace: $stackTrace
''';

    mensagem(titulo: 'Erro', mensagem: errorMessage, tipo: StatusConsole.error);
  }
}
