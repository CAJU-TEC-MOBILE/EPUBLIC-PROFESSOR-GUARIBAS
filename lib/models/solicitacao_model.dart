import 'dart:convert';

class SolicitacaoModel {
  String id;
  String? descricao;

  SolicitacaoModel({required this.id, this.descricao});

  SolicitacaoModel copyWith({String? id, String? descricao}) {
    return SolicitacaoModel(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'descricao': descricao};
  }

  factory SolicitacaoModel.fromMap(Map<String, dynamic> map) {
    return SolicitacaoModel(
      id: map['id'].toString(),
      descricao: map['descricao'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SolicitacaoModel.fromJson(String source) =>
      SolicitacaoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'SolicitacaoModel(id: $id, descricao: $descricao)';

  @override
  bool operator ==(covariant SolicitacaoModel other) {
    if (identical(this, other)) return true;

    return other.id == id && other.descricao == descricao;
  }

  @override
  int get hashCode => id.hashCode ^ descricao.hashCode;
}
