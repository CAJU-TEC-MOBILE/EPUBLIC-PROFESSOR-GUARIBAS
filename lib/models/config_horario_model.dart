class ConfigHorarioModel {
  final String id;
  final String? turnoId;
  final String? configuracaoId;
  final String? tipoHorario;
  final String? descricao;
  final String? inicio;
  final String? fim;

  ConfigHorarioModel({
    required this.id,
    this.turnoId,
    this.configuracaoId,
    this.tipoHorario,
    this.descricao,
    this.inicio,
    this.fim,
  });

  factory ConfigHorarioModel.fromJson(Map<String, dynamic> json) {
    return ConfigHorarioModel(
      id: json['id'].toString(),
      turnoId: json['turno_id'].toString(),
      configuracaoId: json['configuracao_id'].toString(),
      tipoHorario: json['tipo_horario'],
      descricao: json['descricao'],
      inicio: json['inicio'],
      fim: json['final'],
    );
  }

  factory ConfigHorarioModel.vazio() {
    return ConfigHorarioModel(
      id: '',
      turnoId: '',
      configuracaoId: '',
      tipoHorario: '',
      descricao: '',
      inicio: '',
      fim: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'turno_id': turnoId,
      'configuracao_id': configuracaoId,
      'tipo_horario': tipoHorario,
      'descricao': descricao,
      'inicio': inicio,
      'final': fim,
    };
  }

  @override
  String toString() {
    return 'ConfigHorarioModel(id: $id, turnoId: $turnoId, configuracaoId: $configuracaoId, '
        'tipoHorario: $tipoHorario, descricao: $descricao, inicio: $inicio, fim: $fim)';
  }
}
