class Horario {
  final String id;
  final String turnoID;
  final String descricao;
  final String inicio;
  final String fim;

  Horario({
    required this.id,
    required this.turnoID,
    required this.descricao,
    required this.inicio,
    required this.fim,
  });

  factory Horario.fromJson(Map<dynamic, dynamic> json) {
    return Horario(
        id: json['id']?.toString() ?? '',
        turnoID: json['turno_id']?.toString() ?? '',
        descricao: json['descricao']?.toString() ?? '',
        inicio: json['inicio']?.toString() ?? '',
        fim: json['final']?.toString() ?? '');
  }

  @override
  String toString() {
    return 'Horario(id: $id, turnoID: $turnoID, descricao: $descricao, inicio: $inicio, fim: $fim)';
  }
}
