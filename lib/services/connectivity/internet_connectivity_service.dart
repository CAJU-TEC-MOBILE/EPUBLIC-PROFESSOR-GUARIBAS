import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../enums/status_console.dart';
import '../../helpers/console_log.dart';

class InternetConnectivityService {
  static Future<bool> isConnected() async {
    final bool isConnected =
        await InternetConnectionChecker.instance.hasConnection;
    if (isConnected) {
      ConsoleLog.mensagem(
        titulo: 'internet-connectivity-service',
        mensagem: 'O dispositivo está conectado à internet.',
        tipo: StatusConsole.sucesso,
      );
      return true;
    }

    ConsoleLog.mensagem(
      titulo: 'internet-connectivity-service',
      mensagem: 'O dispositivo não está conectado à Internet',
      tipo: StatusConsole.error,
    );
    return false;
  }
}
