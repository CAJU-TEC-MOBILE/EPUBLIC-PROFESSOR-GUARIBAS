class AutorizacaoModel {
  String id;
  String pedidoId;
  String instrutorDisciplinaTurmaId;
  String etapaId;
  String userSolicitante;
  String userAprovador;
  String observacoes;
  String dataExpiracao;
  String status;
  String data;
  String mobile;

  AutorizacaoModel({
    required this.id,
    required this.pedidoId,
    required this.instrutorDisciplinaTurmaId,
    required this.etapaId,
    required this.userSolicitante,
    required this.userAprovador,
    required this.observacoes,
    required this.dataExpiracao,
    required this.status,
    required this.data,
    required this.mobile,
  });

  factory AutorizacaoModel.fromJson(Map<dynamic, dynamic> json) {
    try {
      return AutorizacaoModel(
        id: json['id']?.toString() ?? '',
        pedidoId: json['pedido_id']?.toString() ?? '',
        instrutorDisciplinaTurmaId:
            json['instrutorDisciplinaTurma_id']?.toString() ?? '',
        etapaId: json['etapa_id']?.toString() ?? '',
        userSolicitante: json['user_solicitante']?.toString() ?? '',
        userAprovador: json['user_aprovador']?.toString() ?? '',
        observacoes: json['observacoes']?.toString() ?? '',
        dataExpiracao: json['data_expiracao']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        data: json['data'] ?? '',
        mobile: json['mobile'] ?? '',
      );
    } catch (error) {
      return AutorizacaoModel.vazio();
    }
  }

  factory AutorizacaoModel.vazio() {
    return AutorizacaoModel(
      id: '',
      pedidoId: '',
      instrutorDisciplinaTurmaId: '',
      etapaId: '',
      userSolicitante: '',
      userAprovador: '',
      observacoes: '',
      dataExpiracao: '',
      status: '',
      data: '',
      mobile: '',
    );
  }

  @override
  String toString() {
    return 'AutorizacaoModel(id: $id, pedidoId: $pedidoId, instrutorDisciplinaTurmaId: $instrutorDisciplinaTurmaId, etapaId: $etapaId, userSolicitante: $userSolicitante, userAprovador: $userAprovador, observacoes: $observacoes, dataExpiracao: $dataExpiracao, status: $status, data: $data, mobile: $mobile)';
  }
}
