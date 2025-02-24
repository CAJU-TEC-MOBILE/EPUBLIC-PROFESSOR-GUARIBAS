// ignore_for_file: public_member_api_docs, sort_constructors_first
class Etapa {
  final String id;
  final String circuito_nota_id;
  final String curso_descricao;
  final String descricao;
  final String periodo_inicial;
  final String periodo_final;
  final String situacao_faltas;
  final String etapa_global;

  Etapa({
    required this.id,
    required this.circuito_nota_id,
    required this.curso_descricao,
    required this.descricao,
    required this.periodo_inicial,
    required this.periodo_final,
    required this.situacao_faltas,
    required this.etapa_global,
  });

  factory Etapa.fromJson(Map<dynamic, dynamic> etapaJson) {
    return Etapa(
      id: etapaJson['id'].toString(),
      curso_descricao: etapaJson['curso_descricao']  ?? '',
      circuito_nota_id: etapaJson['circuito_nota_id'].toString(),
      descricao: etapaJson['descricao'].toString(),
      periodo_inicial: etapaJson['periodo_inicial'].toString(),
      periodo_final: etapaJson['periodo_final'].toString(),
      situacao_faltas: etapaJson['situacao_faltas'].toString(),
      etapa_global: etapaJson['etapa_global'].toString(),
    );
  }

  @override
  String toString() {
    return 'Etapa(id: $id, circuito_nota_id: $circuito_nota_id, curso_descricao: $curso_descricao, descricao: $descricao, periodo_inicial: $periodo_inicial, periodo_final: $periodo_final, situacao_faltas: $situacao_faltas, etapa_global: $etapa_global)';
  }
}
