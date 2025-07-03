import 'package:flutter/material.dart';

import '../componentes/dialogs/custom_snackbar.dart';
import '../componentes/global/preloader.dart';
import '../enums/status_console.dart';
import '../helpers/console_log.dart';
import '../services/connectivity/internet_connectivity_service.dart';
import 'auth_repository.dart';
import 'totalizador_repository.dart';

class SincronizarRepository {
  final totalizadorRepository = TotalizadorRepository();
  final authRepository = AuthRepository();

  Future<bool> geral({required BuildContext context}) async {
    try {
      showLoading(context);
      bool isConnected = await InternetConnectivityService.isConnected();
      if (!isConnected) {
        CustomSnackBar.showErrorSnackBar(
          context,
          'Você está offline no momento. Verifique sua conexão com a internet.',
        );
        hideLoading(context);
        return false;
      }

      await totalizadorRepository.syncAulaTotalizador(context: context);
      debugPrint("\n✅ Download de totalizador completo!");
      await authRepository.baixar();
      hideLoading(context);
      return true;
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'sincronizar-geral-repository',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
      return false;
    }
  }
}
