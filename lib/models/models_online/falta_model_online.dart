class FaltaModelOnline {
  String id;
  String justificativa_id;
  String matricula_id;
  String aula_id;
  bool? status;
  String? justificativa_descricao;
  bool? existe_anexo;

  FaltaModelOnline({
    required this.id,
    required this.justificativa_id,
    required this.matricula_id,
    required this.aula_id,
    this.justificativa_descricao,
    this.status,
    this.existe_anexo,
  });

  factory FaltaModelOnline.fromJson(Map<String, dynamic> justificativaJson) {
    return FaltaModelOnline(
      id: justificativaJson['id'].toString(),
      justificativa_id: justificativaJson['justificativa_id'].toString(),
      matricula_id: justificativaJson['matricula_id'].toString(),
      aula_id: justificativaJson['aula_id'].toString(),
      justificativa_descricao: (justificativaJson['justificativa'] != null &&
              justificativaJson['justificativa']['descricao'] != null)
          ? justificativaJson['justificativa']['descricao'].toString()
          : '',
      status: !justificativaJson['status'] ? false : true,
      existe_anexo: justificativaJson['existe_anexo'] != null ? true : false,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'justificativa_id': justificativa_id,
      'matricula_id': matricula_id,
      'aula_id': aula_id,
      'justificativa_descricao': justificativa_descricao,
      'status': status ?? false,
      'existe_anexo': existe_anexo ?? false,
    };
  }

  @override
  String toString() {
    return 'FaltaModelOnline(id: $id, justificativa_id: $justificativa_id, existe_anexo: $existe_anexo, matricula_id: $matricula_id, aula_id: $aula_id, justificativa_descricao: $justificativa_descricao status: $status)';
  }
}
