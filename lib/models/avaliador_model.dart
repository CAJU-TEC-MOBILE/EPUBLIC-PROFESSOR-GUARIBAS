import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../enums/status_console.dart';
import '../../helpers/console_log.dart';

class AvaliadorModel {
  String id;
  String? name;
  String? anoId;
  String? configuracaoId;
  List<int>? franquiasPermitidas;

  AvaliadorModel({
    required this.id,
    this.name,
    this.anoId,
    this.configuracaoId,
    this.franquiasPermitidas,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'anoId': anoId,
      'configuracaoId': configuracaoId,
      'franquiasPermitidas': franquiasPermitidas,
    };
  }

  factory AvaliadorModel.vazio() {
    return AvaliadorModel(
      id: '',
      name: '',
      anoId: '',
      configuracaoId: '',
      franquiasPermitidas: [],
    );
  }

  String toJson() => json.encode(toMap());

  factory AvaliadorModel.fromJson(Map<String, dynamic> source) {
    try {
      var franquiasData = source['franquias_permitidas'];
      List<int> franquiasList = [];

      if (franquiasData is List) {
        franquiasList = franquiasData.map((item) => item as int).toList();
      }

      return AvaliadorModel(
        id: source['id']?.toString() ?? '',
        name: source['name']?.toString() ?? '',
        anoId: source['ano_id']?.toString() ?? '',
        configuracaoId: source['configuracao_id']?.toString() ?? '',
        franquiasPermitidas: franquiasList,
      );
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'avaliado-model-fromJson',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
      return AvaliadorModel.vazio();
    }
  }

  @override
  String toString() {
    return 'AvaliadorModel(id: $id, name: $name, anoId: $anoId, configuracaoId: $configuracaoId, franquiasPermitidas: $franquiasPermitidas)';
  }

  @override
  bool operator ==(covariant AvaliadorModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.anoId == anoId &&
        other.configuracaoId == configuracaoId &&
        listEquals(other.franquiasPermitidas, franquiasPermitidas);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        anoId.hashCode ^
        configuracaoId.hashCode ^
        franquiasPermitidas.hashCode;
  }
}
