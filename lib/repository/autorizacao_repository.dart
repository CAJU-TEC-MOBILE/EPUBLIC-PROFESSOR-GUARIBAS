import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/models/auth_model.dart';
import '../componentes/dialogs/custom_snackbar.dart';
import '../enums/status_console.dart';
import '../helpers/console_log.dart';
import '../models/autorizacao_model.dart';
import '../services/controller/auth_controller.dart';
import '../services/controller/autorizacao_controller.dart';
import '../services/http/autorizacoes/autorizacoes_salvar_service.dart';
import '../services/shared_preference_service.dart';

class AutorizacaoRepository {
  final autorizacaoHttp = AutorizacaoHttp();
  final authController = AuthController();
  final preference = SharedPreferenceService();
  Future<bool> addLocal({
    required BuildContext context,
    required AutorizacaoModel model,
  }) async {
    try {
      final controller = AutorizacaoController();
      await controller.init();
      await controller.add(model);
      await controller.visualizar();
      return true;
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'autorizacao-add-local-repository',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
      return false;
    }
  }

  Future<List<AutorizacaoModel>> getPeloUserId() async {
    try {
      final controller = AutorizacaoController();
      await authController.init();
      await controller.init();

      AuthModel auth = await authController.authFirst();

      return await controller.autorizacaoPeloUserId(
        userId: auth.id,
      );
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'get-pelo-instrutorId-repository',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
      return [];
    }
  }

  Future<AutorizacaoModel> enviarAutorizacao(
      {required BuildContext context, required AutorizacaoModel model}) async {
    try {
      final response = await autorizacaoHttp.executar(model: model);
      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode != 201) {
        String? message = data['error']?['message'].toString();

        if (response.statusCode == 401) {
          await preference.init();
          await preference.limparDados();
          CustomSnackBar.showInfoSnackBar(
            context,
            'Token de acesso expirado. Faça login novamente.',
          );
          await Navigator.pushReplacementNamed(context, '/login');
          return AutorizacaoModel.vazio();
        }
        CustomSnackBar.showSuccessSnackBar(
          context,
          message.toString(),
        );

        return AutorizacaoModel.vazio();
      }

      CustomSnackBar.showSuccessSnackBar(
        context,
        data['message'].toString(),
      );

      return AutorizacaoModel.fromJson(data['autorizacao']);
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'enviar-autorizacao',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
      return AutorizacaoModel.vazio();
    }
  }

  Future<List<AutorizacaoModel>> secronizar(
      {required BuildContext context}) async {
    try {
      final controller = AutorizacaoController();

      await authController.init();

      final auth = await authController.authFirst();

      final response = await autorizacaoHttp.autorizacoesUser(userId: auth.id);
      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode != 200) {
        String? message = data['error']?['message'].toString();

        if (response.statusCode == 401) {
          await preference.init();
          await preference.limparDados();
          CustomSnackBar.showInfoSnackBar(
            context,
            'Token de acesso expirado. Faça login novamente.',
          );
          await Navigator.pushReplacementNamed(context, '/login');
          return [];
        }
        CustomSnackBar.showInfoSnackBar(
          context,
          message.toString(),
        );

        return [];
      }

      final List<dynamic> autorizacoes = data['autorizacoes'];
      await controller.init();

      for (final item in autorizacoes) {
        final model = AutorizacaoModel.fromJson(item);
        await controller.update(model);
      }
      return await controller.autorizacaoPeloUserId(userId: auth.id);
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'secronizar-repository',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
      return [];
    }
  }
}
