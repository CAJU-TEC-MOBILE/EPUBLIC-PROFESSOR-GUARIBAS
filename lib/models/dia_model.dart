class Dia {
  final String id;
  final String descricao;

  Dia({required this.id, required this.descricao});

  factory Dia.fromJson(Map<dynamic, dynamic> json) {
    return Dia(
      id: json['id']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
    );
  }
  
  @override
  String toString() {
    return 'Dia('
        'id: $id, '
        'descricao: $descricao'
        ')';
  }
}
