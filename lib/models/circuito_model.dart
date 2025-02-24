import 'package:professor_acesso_notifiq/models/etapa_model.dart';

class Circuito {
  final String id;
  final String anoId;
  final String descricao;
  final String configuracaoId;
  final String valorInicialAprovado;
  final String valorFinalAprovado;
  final String aprovadoCor;
  final String aprovadoTexto;
  final String valorInicialReprovado;
  final String valorFinalReprovado;
  final String reprovadoCor;
  final String reprovadoTexto;
  final String valorInicialRecuperacao;
  final String valorFinalRecuperacao;
  final String recuperacaoCor;
  final String recuperacaoTexto;
  final String tipo;
  final String deletedAt;
  final String createdAt;
  final String updatedAt;
  final List<Etapa> etapas;

  Circuito(
      {required this.id,
      required this.anoId,
      required this.descricao,
      required this.configuracaoId,
      required this.valorInicialAprovado,
      required this.valorFinalAprovado,
      required this.aprovadoCor,
      required this.aprovadoTexto,
      required this.valorInicialReprovado,
      required this.valorFinalReprovado,
      required this.reprovadoCor,
      required this.reprovadoTexto,
      required this.valorInicialRecuperacao,
      required this.valorFinalRecuperacao,
      required this.recuperacaoCor,
      required this.recuperacaoTexto,
      required this.tipo,
      required this.deletedAt,
      required this.createdAt,
      required this.updatedAt,
      required this.etapas});

  factory Circuito.fromJson(Map<dynamic, dynamic> circuitoJson) {
    final etapasJson = circuitoJson['etapas'] as List<dynamic>? ?? [];
    final etapas = etapasJson.map((etapa) => Etapa.fromJson(etapa)).toList();

    return Circuito(
      id: circuitoJson['id'].toString(),
      anoId: circuitoJson['ano_id'].toString(),
      descricao: circuitoJson['descricao'].toString(),
      configuracaoId: circuitoJson['configuracao_id'].toString(),
      valorInicialAprovado: circuitoJson['valor_inicial_aprovado'].toString(),
      valorFinalAprovado: circuitoJson['valor_final_aprovado'].toString(),
      aprovadoCor: circuitoJson['aprovado_cor'].toString(),
      aprovadoTexto: circuitoJson['aprovado_texto'].toString(),
      valorInicialReprovado: circuitoJson['valor_inicial_reprovado'].toString(),
      valorFinalReprovado: circuitoJson['valor_final_reprovado'].toString(),
      reprovadoCor: circuitoJson['reprovado_cor'].toString(),
      reprovadoTexto: circuitoJson['reprovado_texto'].toString(),
      valorInicialRecuperacao:
          circuitoJson['valor_inicial_recuperacao'].toString(),
      valorFinalRecuperacao: circuitoJson['valor_final_recuperacao'].toString(),
      recuperacaoCor: circuitoJson['recuperacao_cor'].toString(),
      recuperacaoTexto: circuitoJson['recuperacao_texto'].toString(),
      tipo: circuitoJson['tipo'].toString(),
      deletedAt: circuitoJson['deleted_at'].toString(),
      createdAt: circuitoJson['created_at'].toString(),
      updatedAt: circuitoJson['updated_at'].toString(),
      etapas: etapas,
    );
  }

  @override
  String toString() {
    return 'Circuito('
        'id: $id, '
        'anoId: $anoId, '
        'descricao: $descricao, '
        'configuracaoId: $configuracaoId, '
        'valorInicialAprovado: $valorInicialAprovado, '
        'valorFinalAprovado: $valorFinalAprovado, '
        'aprovadoCor: $aprovadoCor, '
        'aprovadoTexto: $aprovadoTexto, '
        'valorInicialReprovado: $valorInicialReprovado, '
        'valorFinalReprovado: $valorFinalReprovado, '
        'reprovadoCor: $reprovadoCor, '
        'reprovadoTexto: $reprovadoTexto, '
        'valorInicialRecuperacao: $valorInicialRecuperacao, '
        'valorFinalRecuperacao: $valorFinalRecuperacao, '
        'recuperacaoCor: $recuperacaoCor, '
        'recuperacaoTexto: $recuperacaoTexto, '
        'tipo: $tipo, '
        'deletedAt: $deletedAt, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'etapas: ${etapas.toString()}'
        ')';
  }
}
