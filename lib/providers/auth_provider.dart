import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../componentes/dialogs/custom_snackbar.dart';
import '../componentes/global/preloader.dart';
import '../enums/status_console.dart';
import '../helpers/console_log.dart';
import '../repository/auth_repository.dart';
import '../services/connectivity/internet_connectivity_service.dart';

class AuthProvider with ChangeNotifier {
  bool enabledTextFormField = true;
  String appVerso = '';
  bool isLoading = false;

  Future<bool> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      final authRepository = AuthRepository();

      showLoading(context);
      enabledTextFormField = false;
      isLoading = true;

      notifyListeners();

      bool isConnected = await InternetConnectivityService.isConnected();

      if (!isConnected) {
        Future.microtask(() {
          CustomSnackBar.showErrorSnackBar(
            context,
            'Erro ao estabelecer a conexão. Verifique sua conexão com a internet.',
          );
        });
        enabledTextFormField = true;
        isLoading = false;
        notifyListeners();
        hideLoading(context);
        return false;
      }

      final success = await authRepository.login(
        context: context,
        email: email,
        password: password,
      );

      hideLoading(context);

      if (!success) {
        enabledTextFormField = true;
        isLoading = false;
        notifyListeners();
        hideLoading(context);
        return false;
      }

      enabledTextFormField = true;
      isLoading = false;
      notifyListeners();
      CustomSnackBar.showSuccessSnackBar(context, 'Logado com sucesso!');
      Navigator.pushReplacementNamed(context, '/home');
      return true;
    } catch (error) {
      enabledTextFormField = true;
      isLoading = false;
      ConsoleLog.mensagem(
        titulo: 'auth-provider-login',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );

      notifyListeners();
      return false;
    }
  }

  Future<void> configuracaoEnv() async {
    appVerso = dotenv.env['VERSAO'] ?? 'Default Verso';
    notifyListeners();
  }
}
