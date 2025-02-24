import 'package:hive_flutter/hive_flutter.dart';

class HorarioConfiguracao {
  final String id;
  final String turnoID;
  final String descricao;
  final String inicio;
  final String fim;

  HorarioConfiguracao({
    required this.id,
    required this.turnoID,
    required this.descricao,
    required this.inicio,
    required this.fim,
  });

  factory HorarioConfiguracao.fromJson(Map<dynamic, dynamic> json) {
    return HorarioConfiguracao(
      id: json['id']?.toString() ?? '',
      turnoID: json['turno_id']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
      inicio: json['inicio']?.toString() ?? '',
      fim: json['final']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'HorarioConfiguracao(id: $id, turnoID: $turnoID, descricao: $descricao, inicio: $inicio, fim: $fim)';
  }
}

class HorarioConfiguracaoAdapter extends TypeAdapter<HorarioConfiguracao> {
  @override
  final int typeId = 20;

  @override
  HorarioConfiguracao read(BinaryReader reader) {
    return HorarioConfiguracao(
      id: reader.readString(),
      turnoID: reader.readString(),
      descricao: reader.readString(),
      inicio: reader.readString(),
      fim: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, HorarioConfiguracao obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.turnoID);
    writer.writeString(obj.descricao);
    writer.writeString(obj.inicio);
    writer.writeString(obj.fim);
  }
}
