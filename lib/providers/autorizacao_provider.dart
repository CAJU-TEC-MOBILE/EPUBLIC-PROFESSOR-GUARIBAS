import 'package:flutter/material.dart';
import '../componentes/dialogs/custom_snackbar.dart';
import '../componentes/global/preloader.dart';
import '../enums/status_console.dart';
import '../functions/aplicativo/verificar_conexao_com_internet.dart';
import '../helpers/console_log.dart';
import '../models/autorizacao_model.dart';
import '../repository/autorizacao_repository.dart';
import '../services/controller/auth_controller.dart';
import '../utils/datetime_utils.dart';

class AutorizacaoProvider with ChangeNotifier {
  List<AutorizacaoModel> autorizacoes = [];
  Future<bool> solicitar({
    required BuildContext context,
    required String etapaId,
    required String pedidoId,
    required String userAprovador,
    required String observacoes,
    required String instrutorDisciplinaTurmaId,
  }) async {
    try {
      showLoading(context);
      final bool isConnected = await checkInternetConnection();
      if (!isConnected) {
        hideLoading(context);
        CustomSnackBar.showErrorSnackBar(context, 'Sem conexão com a internet');
        return false;
      }
      final repository = AutorizacaoRepository();
      final authController = AuthController();
      await authController.init();
      final auth = await authController.authFirst();

      AutorizacaoModel model = AutorizacaoModel(
        id: '',
        etapaId: etapaId,
        pedidoId: pedidoId,
        instrutorDisciplinaTurmaId: instrutorDisciplinaTurmaId,
        dataExpiracao: '',
        observacoes: observacoes,
        status: 'PENDENTE',
        userAprovador: userAprovador,
        userSolicitante: auth.id,
        data: DateTimeUtils.date,
        mobile: '1',
        userId: auth.id,
      );

      final response = await repository.enviarAutorizacao(
        context: context,
        model: model,
      );

      if (response.id.isNotEmpty) {
        model = response;
        await repository.addLocal(context: context, model: model);
      }
      hideLoading(context);
      notifyListeners();
      return true;
    } catch (error) {
      hideLoading(context);

      ConsoleLog.mensagem(
        titulo: 'appbar-auth-provider',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> listarAutorizacoes() async {
    try {
      final repository = AutorizacaoRepository();
      autorizacoes = await repository.getPeloUserId();
      notifyListeners();
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'listar-autorizacoes-provider',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
      notifyListeners();
    }
  }

  Future<void> secronizar({required BuildContext context}) async {
    try {
      showLoading(context);
      final bool isConnected = await checkInternetConnection();
      if (!isConnected) {
        hideLoading(context);
        CustomSnackBar.showErrorSnackBar(context, 'Sem conexão com a internet');
        notifyListeners();
        return;
      }
      final repository = AutorizacaoRepository();
      autorizacoes = await repository.secronizar(context: context);
      hideLoading(context);
      notifyListeners();
    } catch (error) {
      hideLoading(context);

      ConsoleLog.mensagem(
        titulo: 'secronizar-provider',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
      notifyListeners();
    }
  }
}
