import 'package:professor_acesso_notifiq/models/autorizacao_model.dart';
import 'package:professor_acesso_notifiq/models/gestao_ativa_model.dart';
import 'package:professor_acesso_notifiq/services/adapters/gestao_ativa_service_adapter.dart';

class ListarUnicaAutorizacaoPorEtapaEGestaoEultimoItemRegraLogica {
  GestaoAtiva? gestaoAtivaModel = GestaoAtivaServiceAdapter().exibirGestaoAtiva();
  List<Autorizacao>? autorizacoesFiltro;

  Autorizacao executar({
    required List<Autorizacao>? autorizacoes,
    required String etapaID,
  }) {
    List<Autorizacao> autorizacoesFiltro = [];

    autorizacoes?.forEach((autorizacao) {
      if (autorizacao.instrutorDisciplinaTurmaID == gestaoAtivaModel!.idt_id &&
          autorizacao.etapaID == etapaID) {
        autorizacoesFiltro.add(autorizacao);
      }
    });

    if (autorizacoesFiltro.isEmpty) {
      return Autorizacao(
        id: '',
        pedidoID: '',
        instrutorDisciplinaTurmaID: '',
        etapaID: '',
        userSolicitante: '',
        userAprovador: '',
        observacoes: '',
        dataExpiracao: '',
        status: '',
      ); // Valor padrão quando nenhum item é encontrado
    }
    return autorizacoesFiltro.reduce((anterior, atual) =>
        int.parse(atual.id) > int.parse(anterior.id) ? atual : anterior);
  }
}
