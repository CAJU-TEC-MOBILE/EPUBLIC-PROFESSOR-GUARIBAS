import 'package:flutter/material.dart';
import '../../models/faltas_model.dart';
import '../../models/justificativa_model.dart';
import '../../models/matricula_model.dart';
import '../adapters/faltas_offlines_service_adapter.dart';
import '../adapters/justificativas_service_adapter.dart';
import '../adapters/matriculas_da_turma_ativa_service_adapter.dart';

class FaltaController {
  Future<List<Matricula>> _getMatriculasComFaltas(
      {required String aula_id}) async {
    List<Falta> faltas = await FaltasOfflinesServiceAdapter().listar();
    List<Matricula> matriculas =
        await MatriculasDaTurmaAtivaServiceAdapter().listar();
    List<Justificativa> justificativas =
        await JustificativasServiceAdapter().listar();
    bool frequenciaJaCriada = faltas.any((falta) => falta.aula_id == aula_id);
    return matriculas.map((matricula) {
      Falta? faltaCorrespondente = faltas.firstWhere(
        (falta) =>
            falta.matricula_id == matricula.matricula_id &&
            falta.aula_id == aula_id,
        orElse: () => Falta(
          aula_id: '',
          matricula_id: '',
          justificativa_id: '',
          aluno_nome: '',
          observacao: '',
          document: '',
          status_falta: frequenciaJaCriada,
          existe_anexo: false,
        ),
      );
      Justificativa? justificativaCorrespondente = justificativas.firstWhere(
        (justificativa) =>
            justificativa.id == faltaCorrespondente.justificativa_id,
        orElse: () => Justificativa(id: '0', descricao: ''),
      );
      return Matricula(
        matricula_id: matricula.matricula_id,
        turma_id: matricula.turma_id,
        aluno_id: matricula.aluno_id,
        aluno_nome: matricula.aluno_nome,
        existe_anexo: faltaCorrespondente.existe_anexo ?? false,
        codigo: 0,
        justificativa: matricula.justificativa,
        justificativa_id: matricula.justificativa_id,
        matricula_situacao: '0',
      );
    }).toList();
  }

  Future<List<Matricula>> getFaltaPorAulaId({required String? aula_id}) async {
    if (aula_id == null || aula_id.isEmpty) return [];
    List<Matricula> matriculasComFaltas =
        await _getMatriculasComFaltas(aula_id: aula_id);
    for (var matricula in matriculasComFaltas) {
      if (matricula.justificativa_id != null &&
          matricula.justificativa_id! > 0) {
        print("========================================================");
        debugPrint("matricula_id: ${matricula.matricula_id}");
        debugPrint("turma_id: ${matricula.turma_id}");
        debugPrint("aluno_id: ${matricula.aluno_id}");
        debugPrint("aluno_nome: ${matricula.aluno_nome}");
        debugPrint("existe_anexo: ${matricula.existe_anexo}");
        debugPrint("justificativa: ${matricula.justificativa}");
        debugPrint("justificativa_id: ${matricula.justificativa_id}");
      }
    }
    return matriculasComFaltas;
  }
}
