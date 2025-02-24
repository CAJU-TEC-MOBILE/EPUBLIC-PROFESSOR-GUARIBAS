class Autorizacao {
  final String id;
  final String pedidoID;
  final String instrutorDisciplinaTurmaID;
  final String etapaID;
  final String userSolicitante;
  final String userAprovador;
  final String observacoes;
  final String dataExpiracao;
  final String status;

  Autorizacao(
      {required this.id,
      required this.pedidoID,
      required this.instrutorDisciplinaTurmaID,
      required this.etapaID,
      required this.userSolicitante,
      required this.userAprovador,
      required this.observacoes,
      required this.dataExpiracao,
      required this.status});

  factory Autorizacao.fromJson(Map<dynamic, dynamic> json) {
    return Autorizacao(
        id: json['id']?.toString() ?? '',
        pedidoID: json['pedido_id']?.toString() ?? '',
        instrutorDisciplinaTurmaID:
            json['instrutorDisciplinaTurma_id']?.toString() ?? '',
        etapaID: json['etapa_id']?.toString() ?? '',
        userSolicitante: json['user_solicitante']?.toString() ?? '',
        userAprovador: json['user_aprovador']?.toString() ?? '',
        observacoes: json['observacoes']?.toString() ?? '',
        dataExpiracao: json['data_expiracao']?.toString() ?? '',
        status: json['status']?.toString() ?? '');
  }
}
