import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../enums/status_console.dart';
import '../../../helpers/console_log.dart';
import '../../../models/auth_model.dart';
import '../../../models/gestao_ativa_model.dart';
import '../../../models/professor_model.dart';
import '../../../services/adapters/auth_service_adapter.dart';
import '../../../services/adapters/gestao_ativa_service_adapter.dart';
import '../../../services/controller/auth_controller.dart';
import '../../../services/controller/professor_controller.dart';
import '../../../services/http/professor/professor_http.dart';
import '../../dialogs/custom_snackbar.dart';

class CustomCardPerfilController {
  final AuthServiceAdapter _authServiceAdapter;
  final GestaoAtivaServiceAdapter _gestaoAtivaServiceAdapter;
  final authController = AuthController();

  ValueNotifier<AuthModel?> authModel = ValueNotifier(null);
  ValueNotifier<GestaoAtiva?> gestaoAtivaModel = ValueNotifier(null);
  Professor? professor;

  CustomCardPerfilController({
    required AuthServiceAdapter authServiceAdapter,
    required GestaoAtivaServiceAdapter gestaoAtivaServiceAdapter,
  })  : _authServiceAdapter = authServiceAdapter,
        _gestaoAtivaServiceAdapter = gestaoAtivaServiceAdapter;

  Future<void> fetchInformacoes() async {
    try {
      final auth = _authServiceAdapter.exibirAuth();
      authModel.value = auth;

      final gestaoAtiva =
          await _gestaoAtivaServiceAdapter.getExibirGestaoAtiva();
      if (gestaoAtiva == null) {
        throw Exception('Gestão Ativa não carregada');
      }
      gestaoAtivaModel.value = gestaoAtiva;
    } catch (e) {
      debugPrint('Erro ao carregar informações: $e');
      throw Exception('Erro ao carregar informações');
    }
  }

  Future<void> fetchInformacoesProfessor() async {
    try {
      await authController.init();
      Professor professorData = await authController.authProfessorFirst();
      if (professorData.id == '') {
        debugPrint('Nenhum dado disponível para o professor.');
        return;
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados do professor: $e');
      throw Exception('Erro ao carregar dados do professor');
    }
  }

  Future<Professor?> getProfessor() async {
    try {
      final professorController = ProfessorController();
      await professorController.init();
      Professor? dataProfessor = await professorController.getProfessor();
      professor = dataProfessor;
      return professor;
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'get-professor',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
    }
    return null;
  }

  Future<bool> fetchAtualizar(
      Map<String, dynamic> data, String id, BuildContext context) async {
    try {
      final professorHttp = ProfessorHttp();

      final response = await professorHttp.atualizar(data: data, id: id);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        final professorMap = responseBody['data'];

        final professorController = ProfessorController();

        await professorController.init();

        await professorController.update(professorMap);

        CustomSnackBar.showSuccessSnackBar(
          // ignore: use_build_context_synchronously
          context,
          'Informações atualizadas com sucesso!',
        );
        return true;
      }

      CustomSnackBar.showErrorSnackBar(
        context,
        'Falha ao atualizar as informações. Tente novamente.',
      );
      return false;
    } catch (e) {
      debugPrint('Erro ao atualizar informações: $e');
      CustomSnackBar.showErrorSnackBar(
        // ignore: use_build_context_synchronously
        context,
        'Erro inesperado. Tente novamente.',
      );
      return false;
    }
  }
}
