class SistemaBncc {
  final String id;
  final String parent_id;
  final String descricao;
  final String apelido;

  SistemaBncc({
    required this.id,
    required this.parent_id,
    required this.descricao,
    required this.apelido,
  });

  factory SistemaBncc.fromJson(Map<dynamic, dynamic> gestaoJson) {
    return SistemaBncc(
      id: gestaoJson['id']?.toString() ?? '',
      parent_id: gestaoJson['parent_id']?.toString() ?? '',
      descricao: gestaoJson['descricao']?.toString() ?? '',
      apelido: gestaoJson['apelido']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'SistemaBncc{id: $id, parent_id: $parent_id, descricao: $descricao, apelido: $apelido}';
  }
}
