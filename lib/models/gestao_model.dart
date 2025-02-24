class Gestao {
  String? turmaId;

  Gestao({
    this.turmaId,
  });

  factory Gestao.fromJson(Map<String, dynamic> json) {
    return Gestao(
      turmaId: json['turma_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['turma_id'] = turmaId;
    return data;
  }

  @override
  String toString() {
    return 'Gestao(turmaId: $turmaId)';
  }
}
