// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/models/auth_model.dart';

import '../services/adapters/auth_service_adapter.dart';
import '../services/adapters/pedidos_service_adapter.dart';
import '../services/adapters/usuarios_service_adapter.dart';
import '../services/controller/gestoes_controller.dart';

class Pedido {
  String id;
  String? descricao;
  String solicitante_id;
  String avaliador_id;
  String? etapa_id;
  String situacao;
  String validade;
  String pedido_id;
  String instrutorDisciplinaTurmaID;
  String observacao;
  String data_expiracao;
  String data;
  String? user_id;
  String? data_fim_etapa;
  String? circuito_id;

  Pedido({
    required this.id,
    this.descricao,
    required this.solicitante_id,
    required this.avaliador_id,
    this.etapa_id,
    required this.situacao,
    required this.validade,
    required this.pedido_id,
    required this.instrutorDisciplinaTurmaID,
    required this.observacao,
    required this.data_expiracao,
    required this.data,
    this.user_id,
    this.data_fim_etapa,
    this.circuito_id,
  });

  factory Pedido.vazio() {
    return Pedido(
      id: '-1',
      solicitante_id: '-1',
      avaliador_id: '-1',
      etapa_id: '-1',
      instrutorDisciplinaTurmaID: '',
      descricao: 'Sem descrição',
      situacao: 'SEM-SISUACAO',
      validade: '',
      pedido_id: '-1',
      observacao: '',
      data_expiracao: '',
      data: '',
      user_id: '-1',
      circuito_id: '-1',
      data_fim_etapa: '',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'descricao': descricao,
      'solicitante_id': solicitante_id,
      'avaliador_id': avaliador_id,
      'etapa_id': etapa_id,
      'situacao': situacao,
      'validade': validade,
      'pedido_id': pedido_id,
      'instrutorDisciplinaTurmaID': instrutorDisciplinaTurmaID,
      'observacao': observacao,
      'data_expiracao': data_expiracao,
      'data': data,
      'user_id': user_id,
      'data_fim_etapa': data_fim_etapa,
      'circuito_id': circuito_id,
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'].toString(),
      descricao: map['descricao'] != null ? map['descricao'].toString() : null,
      solicitante_id: map['solicitante_id'].toString(),
      avaliador_id: map['avaliador_id'].toString(),
      etapa_id: map['etapa_id'] != null ? map['etapa_id'].toString() : null,
      situacao: map['situacao'].toString(),
      validade: map['validade'].toString(),
      pedido_id: map['pedido_id'].toString(),
      instrutorDisciplinaTurmaID: map['instrutorDisciplinaTurmaID'].toString(),
      observacao: map['observacao'].toString(),
      data_expiracao: map['data_expiracao'].toString(),
      data: map['data'].toString(),
      user_id: map['user_id'] != null ? map['user_id'].toString() : null,
      data_fim_etapa: map['data_fim_etapa'] != null
          ? map['data_fim_etapa'].toString()
          : null,
      circuito_id:
          map['circuito_id'] != null ? map['circuito_id'].toString() : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Pedido.fromJson(String source) =>
      Pedido.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Pedido(id: $id, descricao: $descricao, solicitante_id: $solicitante_id, avaliador_id: $avaliador_id, etapa_id: $etapa_id, situacao: $situacao, validade: $validade, pedido_id: $pedido_id, instrutorDisciplinaTurmaID: $instrutorDisciplinaTurmaID, observacao: $observacao, data_expiracao: $data_expiracao, data: $data, user_id: $user_id, data_fim_etapa: $data_fim_etapa, circuito_id: $circuito_id)';
  }

  Pedido copyWith({
    String? id,
    String? descricao,
    String? solicitante_id,
    String? avaliador_id,
    String? etapa_id,
    String? situacao,
    String? validade,
    String? pedido_id,
    String? instrutorDisciplinaTurmaID,
    String? observacao,
    String? data_expiracao,
    String? data,
    String? user_id,
    String? data_fim_etapa,
    String? circuito_id,
  }) {
    return Pedido(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      solicitante_id: solicitante_id ?? this.solicitante_id,
      avaliador_id: avaliador_id ?? this.avaliador_id,
      etapa_id: etapa_id ?? this.etapa_id,
      situacao: situacao ?? this.situacao,
      validade: validade ?? this.validade,
      pedido_id: pedido_id ?? this.pedido_id,
      instrutorDisciplinaTurmaID:
          instrutorDisciplinaTurmaID ?? this.instrutorDisciplinaTurmaID,
      observacao: observacao ?? this.observacao,
      data_expiracao: data_expiracao ?? this.data_expiracao,
      data: data ?? this.data,
      user_id: user_id ?? this.user_id,
      data_fim_etapa: data_fim_etapa ?? this.data_fim_etapa,
      circuito_id: circuito_id ?? this.circuito_id,
    );
  }

  @override
  bool operator ==(covariant Pedido other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.descricao == descricao &&
        other.solicitante_id == solicitante_id &&
        other.avaliador_id == avaliador_id &&
        other.etapa_id == etapa_id &&
        other.situacao == situacao &&
        other.validade == validade &&
        other.pedido_id == pedido_id &&
        other.instrutorDisciplinaTurmaID == instrutorDisciplinaTurmaID &&
        other.observacao == observacao &&
        other.data_expiracao == data_expiracao &&
        other.data == data &&
        other.user_id == user_id &&
        other.data_fim_etapa == data_fim_etapa &&
        other.circuito_id == circuito_id;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        descricao.hashCode ^
        solicitante_id.hashCode ^
        avaliador_id.hashCode ^
        etapa_id.hashCode ^
        situacao.hashCode ^
        validade.hashCode ^
        pedido_id.hashCode ^
        instrutorDisciplinaTurmaID.hashCode ^
        observacao.hashCode ^
        data_expiracao.hashCode ^
        data.hashCode ^
        user_id.hashCode ^
        data_fim_etapa.hashCode ^
        circuito_id.hashCode;
  }

  Future<String>? get descricaoTipo async {
    final pedidosServiceAdapter = PedidosServiceAdapter();
    String? descricao = await pedidosServiceAdapter.getPeloId(id: pedido_id);
    return descricao ?? '';
  }

  Future<String>? get solicitante async {
    Auth authModel = AuthServiceAdapter().exibirAuth();
    return authModel.name;
  }

  Future<String>? get avaliador async {
    final UusuariosServiceAdapter = UsuariosServiceAdapter();
    String? nome =
        await UusuariosServiceAdapter.getNomePeloId(id: avaliador_id);
    return nome ?? '';
  }

  Future<String?> get etapa async {
    final cotnroller = GestaoCotnroller();
    return cotnroller.getPeloId(
      id: etapa_id!,
      instrutorDisciplinaTurmaID: instrutorDisciplinaTurmaID,
    );
  }

  String get dataBr {
    try {
      if (data.isEmpty) return '';
      DateTime parsedDate = DateTime.parse(data);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return '';
    }
  }

  Color get corSituacao {
    switch (situacao) {
      case 'PENDENTE':
        return AppTema.primaryAmarelo;
      case 'RECUSADO':
        return AppTema.error;
      case 'APROVADO':
        return AppTema.success;
      default:
        return Colors.grey;
    }
  }
}

class PedidoAdapter extends TypeAdapter<Pedido> {
  @override
  final int typeId = 50;

  @override
  Pedido read(BinaryReader reader) {
    return Pedido(
      id: reader.readString(),
      descricao: reader.readString(),
      solicitante_id: reader.readString(),
      avaliador_id: reader.readString(),
      etapa_id: reader.readString(),
      situacao: reader.readString(),
      validade: reader.readString(),
      pedido_id: reader.readString(),
      instrutorDisciplinaTurmaID: reader.readString(),
      observacao: reader.readString(),
      data_expiracao: reader.readString(),
      data: reader.readString(),
      user_id: reader.readString(),
      data_fim_etapa: reader.readString(),
      circuito_id: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Pedido obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.descricao ?? '');
    writer.writeString(obj.solicitante_id);
    writer.writeString(obj.avaliador_id);
    writer.writeString(obj.etapa_id ?? '');
    writer.writeString(obj.situacao);
    writer.writeString(obj.validade);
    writer.writeString(obj.pedido_id);
    writer.writeString(obj.instrutorDisciplinaTurmaID);
    writer.writeString(obj.observacao);
    writer.writeString(obj.data_expiracao);
    writer.writeString(obj.data);
    writer.writeString(obj.user_id ?? '');
    writer.writeString(obj.data_fim_etapa ?? '');
    writer.writeString(obj.circuito_id ?? '');
  }
}