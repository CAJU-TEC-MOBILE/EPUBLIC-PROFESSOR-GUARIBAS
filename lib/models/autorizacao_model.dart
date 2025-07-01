import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_tema.dart';
import '../services/adapters/auth_service_adapter.dart';
import '../services/adapters/pedidos_service_adapter.dart';
import '../services/adapters/usuarios_service_adapter.dart';
import '../services/controller/gestoes_controller.dart';
import 'auth_model.dart';

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
  String userId;

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
    required this.userId,
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
        userId: json['user_id'] ?? '',
      );
    } catch (error) {
      return AutorizacaoModel.vazio();
    }
  }

  factory AutorizacaoModel.vazio() {
    return AutorizacaoModel(
      id: '',
      userId: '',
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
    switch (status) {
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

  Future<String>? get descricaoTipo async {
    final pedidosServiceAdapter = PedidosServiceAdapter();
    String? descricao = await pedidosServiceAdapter.getPeloId(id: pedidoId);
    return descricao ?? '';
  }

  Future<String>? get solicitante async {
    AuthModel authModel = AuthServiceAdapter().exibirAuth();
    return authModel.name;
  }

  Future<String>? get avaliador async {
    final UusuariosServiceAdapter = UsuariosServiceAdapter();
    String? nome = UusuariosServiceAdapter.getNomePeloId(id: userSolicitante);
    return nome ?? '';
  }

  Future<String?> get etapa async {
    final cotnroller = GestaoCotnroller();
    return cotnroller.getPeloId(
      id: etapaId,
      instrutorDisciplinaTurmaID: instrutorDisciplinaTurmaId,
    );
  }

  @override
  String toString() {
    return 'AutorizacaoModel(id: $id, userId: $userId, pedidoId: $pedidoId, instrutorDisciplinaTurmaId: $instrutorDisciplinaTurmaId, etapaId: $etapaId, userSolicitante: $userSolicitante, userAprovador: $userAprovador, observacoes: $observacoes, dataExpiracao: $dataExpiracao, status: $status, data: $data, mobile: $mobile)';
  }
}
