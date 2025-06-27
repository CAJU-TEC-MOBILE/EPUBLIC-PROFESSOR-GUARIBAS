// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../enums/status_console.dart';
import '../../helpers/console_log.dart';
import 'professor_model.dart';

class AuthModel {
  String id;
  String anoId;
  String name;
  String email;
  String? situacao;
  String configuracaoId;
  String tokenAtual;
  Professor? professor;
  List<int>? franquias_permitidas;

  AuthModel({
    required this.id,
    required this.anoId,
    required this.name,
    required this.email,
    this.situacao,
    required this.configuracaoId,
    required this.tokenAtual,
    this.professor,
    this.franquias_permitidas,
  });

  factory AuthModel.fromJson(Map<dynamic, dynamic> json) {
    try {
      return AuthModel(
        id: json['id']?.toString() ?? '',
        anoId: json['ano_id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        situacao: json['situacao']?.toString() ?? '',
        configuracaoId: json['configuracao_id']?.toString() ?? '',
        tokenAtual: json['token_atual']?.toString() ?? '',
        professor: Professor.fromJson(json['professor'] ?? {}),
        franquias_permitidas: (json['franquias_permitidas'] as List<dynamic>?)
                ?.map((e) => int.tryParse(e.toString()) ?? 0)
                .toList() ??
            [],
      );
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'auth-model-fromJson',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
      return AuthModel.vazio();
    }
  }

  factory AuthModel.vazio() {
    return AuthModel(
      id: '-1',
      anoId: '-1',
      name: '',
      email: '',
      situacao: '',
      configuracaoId: '-1',
      tokenAtual: '',
      professor: Professor.vazio(),
      franquias_permitidas: [],
    );
  }

  factory AuthModel.fromMap(Map<String, dynamic> map) {
    return AuthModel(
      id: map['id'] as String,
      anoId: map['anoId'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      situacao: map['situacao'] != null ? map['situacao'] as String : null,
      configuracaoId: map['configuracaoId'] as String,
      tokenAtual: map['tokenAtual'] as String,
      professor: map['professor'] != null
          ? Professor.fromMap(map['professor'] as Map<String, dynamic>)
          : null,
      franquias_permitidas: map['franquias_permitidas'] != null
          ? List<int>.from((map['franquias_permitidas'] as List<int>))
          : [],
    );
  }

  String get descricao => name.toUpperCase();

  String get primeiroNome {
    List<String> partes = name.split(' ');
    if (partes.isNotEmpty) {
      return partes.first;
    }
    return '';
  }

  String get sobrenome {
    List<String> partes = name.split(' ');
    if (partes.length > 1) {
      return partes.sublist(1).join(' ');
    }
    return '';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'anoId': anoId,
      'name': name,
      'email': email,
      'situacao': situacao,
      'configuracaoId': configuracaoId,
      'tokenAtual': tokenAtual,
      'professor': professor?.toMap(),
      'franquias_permitidas': franquias_permitidas,
    };
  }

  AuthModel copyWith({
    String? id,
    String? anoId,
    String? name,
    String? email,
    String? situacao,
    String? configuracaoId,
    String? tokenAtual,
    Professor? professor,
    List<int>? franquias_permitidas,
  }) {
    return AuthModel(
      id: id ?? this.id,
      anoId: anoId ?? this.anoId,
      name: name ?? this.name,
      email: email ?? this.email,
      situacao: situacao ?? this.situacao,
      configuracaoId: configuracaoId ?? this.configuracaoId,
      tokenAtual: tokenAtual ?? this.tokenAtual,
      professor: professor ?? this.professor,
      franquias_permitidas: franquias_permitidas ?? this.franquias_permitidas,
    );
  }

  @override
  String toString() {
    return 'AuthModel(id: $id, anoId: $anoId, name: $name, email: $email, situacao: $situacao, configuracaoId: $configuracaoId, tokenAtual: $tokenAtual, professor: $professor, franquias_permitidas: $franquias_permitidas)';
  }

  String toJson() => json.encode(toMap());

  // factory AuthModel.fromJson(String source) => AuthModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant AuthModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.anoId == anoId &&
        other.name == name &&
        other.email == email &&
        other.situacao == situacao &&
        other.configuracaoId == configuracaoId &&
        other.tokenAtual == tokenAtual &&
        other.professor == professor &&
        listEquals(other.franquias_permitidas, franquias_permitidas);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        anoId.hashCode ^
        name.hashCode ^
        email.hashCode ^
        situacao.hashCode ^
        configuracaoId.hashCode ^
        tokenAtual.hashCode ^
        professor.hashCode ^
        franquias_permitidas.hashCode;
  }
}
