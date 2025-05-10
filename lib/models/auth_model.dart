import 'package:professor_acesso_notifiq/models/professor_model.dart';

class Auth {
  final String id;
  final String anoId;
  String name;
  final String email;
  final String situacao;
  final String configuracaoId;
  final String tokenAtual;
  final Professor professor;

  Auth({
    required this.id,
    required this.anoId,
    required this.name,
    required this.email,
    required this.situacao,
    required this.configuracaoId,
    required this.tokenAtual,
    required this.professor,
  });

  factory Auth.fromJson(Map<dynamic, dynamic> json) {
    return Auth(
      id: json['id']?.toString() ?? '',
      anoId: json['ano_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      situacao: json['situacao']?.toString() ?? '',
      configuracaoId: json['configuracao_id']?.toString() ?? '',
      tokenAtual: json['token_atual']?.toString() ?? '',
      professor: Professor.fromJson(json['professor'] ?? {}),
    );
  }

  factory Auth.fromMap(Map<String, dynamic> map) {
    return Auth(
      id: map['id']?.toString() ?? '',
      anoId: map['ano_id']?.toString() ?? '',
      name: map['name'] ?? '',
      email: map['email']?.toString() ?? '',
      situacao: map['situacao']?.toString() ?? '',
      configuracaoId: map['configuracao_id']?.toString() ?? '',
      tokenAtual: map['token_atual'] ?? '',
      professor: map['professor'] != null
          ? Professor.fromJson(Map<String, dynamic>.from(map['professor']))
          : Professor.empty(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ano_id': anoId,
      'name': name,
      'email': email,
      'situacao': situacao,
      'configuracao_id': configuracaoId,
      'token_atual': tokenAtual,
      'professor': professor.toMap(),
    };
  }

  Auth copyWith({
    String? anoId,
    String? name,
    String? email,
    String? situacao,
    String? configuracaoId,
    String? tokenAtual,
    Professor? professor,
  }) {
    return Auth(
      id: id,
      anoId: anoId ?? this.anoId,
      name: name ?? this.name,
      email: email ?? this.email,
      situacao: situacao ?? this.situacao,
      configuracaoId: configuracaoId ?? this.configuracaoId,
      tokenAtual: tokenAtual ?? this.tokenAtual,
      professor: professor ?? this.professor,
    );
  }

  @override
  String toString() {
    return 'Auth{id: $id, anoId: $anoId, name: $name, email: $email, situacao: $situacao, configuracaoId: $configuracaoId, tokenAtual: $tokenAtual, professor: ${professor.toString()}}';
  }
}
