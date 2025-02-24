import 'dart:convert';
import 'remetente_model.dart';
import 'destinatario_model.dart';

class Notificacao {
  final int id;
  final int remetenteId;
  final int destinatarioId;
  final DateTime dataEnvio;
  final DateTime? dataRecebido;
  final DateTime? dataVisualizacao;
  final String titulo;
  final String corpo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool statusDestinatarioAluno;
  final bool statusVisualizacao;
  final bool statusRecebido;
  final bool statusEnviado;
  final Remetente remetente;
  final Destinatario destinatario;

  Notificacao({
    required this.id,
    required this.remetenteId,
    required this.destinatarioId,
    required this.dataEnvio,
    this.dataRecebido,
    this.dataVisualizacao,
    required this.titulo,
    required this.corpo,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.statusDestinatarioAluno,
    required this.statusVisualizacao,
    required this.statusRecebido,
    required this.statusEnviado,
    required this.remetente,
    required this.destinatario,
  });

  factory Notificacao.fromJson(Map<String, dynamic> json) {
    return Notificacao(
      id: json['id'],
      remetenteId: json['remetente_id'],
      destinatarioId: json['destinatario_id'],
      dataEnvio: DateTime.parse(json['data_envio']),
      dataRecebido: json['data_recebido'] != null
          ? DateTime.parse(json['data_recebido'])
          : null,
      dataVisualizacao: json['data_visualizacao'] != null
          ? DateTime.parse(json['data_visualizacao'])
          : null,
      titulo: json['titulo'],
      corpo: json['corpo'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      statusDestinatarioAluno: json['status_destinatario_aluno'],
      statusVisualizacao: json['status_visualizacao'],
      statusRecebido: json['status_recebido'],
      statusEnviado: json['status_enviado'],
      remetente: Remetente.fromJson(json['remetente']),
      destinatario: Destinatario.fromJson(json['destinatario']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'remetente_id': remetenteId,
      'destinatario_id': destinatarioId,
      'data_envio': dataEnvio.toIso8601String(),
      'data_recebido': dataRecebido?.toIso8601String(),
      'data_visualizacao': dataVisualizacao?.toIso8601String(),
      'titulo': titulo,
      'corpo': corpo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'status_destinatario_aluno': statusDestinatarioAluno,
      'status_visualizacao': statusVisualizacao,
      'status_recebido': statusRecebido,
      'status_enviado': statusEnviado,
      'remetente': remetente.toJson(),
      'destinatario': destinatario.toJson(),
    };
  }

  // Método de comparação para verificar igualdade entre objetos Notificacao
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Notificacao) return false;
    return other.id == id &&
        other.remetenteId == remetenteId &&
        other.destinatarioId == destinatarioId;
  }

  @override
  int get hashCode => id.hashCode ^ remetenteId.hashCode ^ destinatarioId.hashCode;
}
