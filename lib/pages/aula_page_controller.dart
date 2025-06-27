import 'package:flutter/material.dart';
import '../services/adapters/gestao_ativa_service_adapter.dart';
import 'aulas/sem_relacao_dia_horario_para_criar_aula.dart';

class AulaPageController {
  Future<void> setAula({
    required BuildContext context,
  }) async {
    final gestaoAtivaModel =
        await GestaoAtivaServiceAdapter().getExibirGestaoAtiva();

    if (gestaoAtivaModel == null) {
      return;
    }

    final hasRelacoesDiasHorarios =
        gestaoAtivaModel.relacoesDiasHorarios.isNotEmpty;
    final isInfantil = gestaoAtivaModel.is_infantil == true;

    String route = hasRelacoesDiasHorarios
        ? (isInfantil ? '/criarAulaInfantil' : '/criarAula')
        : '/semRelacaoDiaHorarioParaCriar';

    final arguments = hasRelacoesDiasHorarios
        ? {
            'instrutorDisciplinaTurmaId': gestaoAtivaModel.idt_id,
          }
        : null;

    if (route == '/semRelacaoDiaHorarioParaCriar') {
      _navigateToSemRelacao(context);
    } else {
      _navigateToNamedRoute(context, route, arguments);
    }
  }

  void _navigateToSemRelacao(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SemRelacaoDiaHorarioParaCriar(),
      ),
    );
  }

  void _navigateToNamedRoute(
      BuildContext context, String route, Map<String, dynamic>? arguments) {
    Navigator.pushNamed(
      context,
      route,
      arguments: arguments,
    );
  }

  Future<void> gestaoAtivaLista({
    required BuildContext context,
  }) async {
    final gestaoAtiva =
        await GestaoAtivaServiceAdapter().getExibirGestaoAtiva();

    if (gestaoAtiva == null) {
      return;
    }
    Navigator.pushNamed(
      context,
      gestaoAtiva.is_infantil == true
          ? '/index-infantil'
          : '/index-fundamental',
      arguments: {'instrutorDisciplinaTurmaId': gestaoAtiva.idt_id.toString()},
    );
  }
}
