import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/models/gestao_ativa_model.dart';

class GestaoAtivaServiceAdapter {
  // ignore: non_constant_identifier_names
  static String? instrutorDisciplinaTurma_id;

  GestaoAtiva? exibirGestaoAtiva() {
    try {
      final Box gestaoAtivaBox = Hive.box('gestao_ativa');

      final gestaoAtivaData =
          gestaoAtivaBox.get('gestao_ativa') as Map<dynamic, dynamic>?;

      if (gestaoAtivaData == null) {
        print('Dados de gestão ativa não encontrados.');
        return null;
      }

      final gestaoAtivaModel = GestaoAtiva.fromJson(gestaoAtivaData);

      if (instrutorDisciplinaTurma_id != null) {
        gestaoAtivaData['instrutorDisciplinaTurma_id'] =
            instrutorDisciplinaTurma_id;
      }

      return gestaoAtivaModel;
    } catch (e) {
      print('Erro ao acessar dados de gestão ativa: $e');
      return null;
    }
  }

  // Future<GestaoAtiva> getExibirGestaoAtiva() async {
  //   Box gestaoAtivaBox = Hive.box('gestao_ativa');
  //   Map<dynamic, dynamic> gestaoAtivaData =
  //       await gestaoAtivaBox.get('gestao_ativa');
  //   GestaoAtiva gestaoAtivaModel = GestaoAtiva.fromJson(gestaoAtivaData);
  //   if (instrutorDisciplinaTurma_id != null) {
  //     gestaoAtivaData['instrutorDisciplinaTurma_id'] =
  //         instrutorDisciplinaTurma_id.toString();
  //   }
  //   return gestaoAtivaModel;
  // }

  Future<GestaoAtiva?> getExibirGestaoAtiva() async {
    try {
      Box gestaoAtivaBox = Hive.box('gestao_ativa');

      Map<dynamic, dynamic>? gestaoAtivaData =
          await gestaoAtivaBox.get('gestao_ativa');

      if (gestaoAtivaData == null || gestaoAtivaData.isEmpty) {
        debugPrint(
            'Nenhum dado encontrado na caixa do Hive para a chave: gestao_ativa');
        return null;
      }

      GestaoAtiva gestaoAtivaModel = GestaoAtiva.fromJson(gestaoAtivaData);

      if (instrutorDisciplinaTurma_id != null) {
        gestaoAtivaData['instrutorDisciplinaTurma_id'] =
            instrutorDisciplinaTurma_id.toString();
      }

      return gestaoAtivaModel;
    } catch (e) {
      print('Erro em getExibirGestaoAtiva: $e');
      return null;
    }
  }
}
