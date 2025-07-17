import 'dart:convert';

import 'package:flutter/material.dart';
import '../componentes/dialogs/custom_snackbar.dart';
import '../enums/status_console.dart';
import '../helpers/console_log.dart';
import '../models/aula_totalizador_model.dart';
import '../models/professor_model.dart';
import '../services/controller/aula_totalizador_controller.dart';
import '../services/controller/auth_controller.dart';
import '../services/http/aulas/aula_totalizador_http.dart';
import '../services/shared_preference_service.dart';
import 'auth_repository.dart';

class TotalizadorRepository {
  final totalizadorController = AulaTotalizadorController();
  final preference = SharedPreferenceService();
  final authController = AuthController();
  final authRepository = AuthRepository();
  final totalizadorHttp = AulaTotalizadorHttp();
  AulaTotalizador totalizadorAula = AulaTotalizador.vazio();
  Professor professor = Professor.vazio();

  Future<AulaTotalizador> syncAulaTotalizador(
      {required BuildContext context}) async {
    try {
      await totalizadorController.init();
      await authController.init();

      professor = await authController.authProfessorFirst();

      if (professor.id.isEmpty) {
        ConsoleLog.mensagem(
          titulo: 'Autenticação',
          mensagem:
              'Não foi possível obter dados vinculados ao professor autenticado.',
          tipo: StatusConsole.error,
        );

        return AulaTotalizador.vazio();
      }

      final response = await totalizadorHttp.getAulasTotalizadas(
        id: professor.id,
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode != 200) {
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
            return AulaTotalizador.vazio();
          }
          CustomSnackBar.showSuccessSnackBar(
            context,
            message.toString(),
          );
          return AulaTotalizador.vazio();
        }
      }

      AulaTotalizador model = AulaTotalizador.fromJson(data);
      await totalizadorController.clear();
      await totalizadorController.add(model);
      totalizadorAula = await totalizadorController.totalizador();
      return totalizadorAula;
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'sincronizacao',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
      return AulaTotalizador.vazio();
    }
  }
}
