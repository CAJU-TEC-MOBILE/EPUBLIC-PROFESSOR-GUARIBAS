import 'package:professor_acesso_notifiq/models/autorizacao_model.dart';
import 'package:professor_acesso_notifiq/models/gestao_ativa_model.dart';
import 'package:professor_acesso_notifiq/services/adapters/gestao_ativa_service_adapter.dart';

class ListarUnicaAutorizacaoPorEtapaEGestaoEultimoItemRegraLogica {
  GestaoAtiva? gestaoAtivaModel =
      GestaoAtivaServiceAdapter().exibirGestaoAtiva();
  List<AutorizacaoModel>? autorizacoesFiltro;

  AutorizacaoModel executar({
    required List<AutorizacaoModel>? autorizacoes,
    required String etapaID,
  }) {
    List<AutorizacaoModel> autorizacoesFiltro = [];

    autorizacoes?.forEach((autorizacao) {
      if (autorizacao.instrutorDisciplinaTurmaId == gestaoAtivaModel!.idt_id &&
          autorizacao.etapaId == etapaID) {
        autorizacoesFiltro.add(autorizacao);
      }
    });

    if (autorizacoesFiltro.isEmpty) {
      return AutorizacaoModel.vazio();
    }
    return autorizacoesFiltro.reduce((anterior, atual) =>
        int.parse(atual.id) > int.parse(anterior.id) ? atual : anterior);
  }
}
