import 'package:hive_flutter/hive_flutter.dart';
import '../../models/etapa_model.dart';

class EtapaAdapter extends TypeAdapter<Etapa> {
  @override
  final typeId = 59;

  @override
  Etapa read(BinaryReader reader) {
    return Etapa(
      id: reader.readString(),
      circuito_nota_id: reader.readString(),
      curso_descricao: reader.readString(),
      descricao: reader.readString(),
      periodo_inicial: reader.readString(),
      periodo_final: reader.readString(),
      situacao_faltas: reader.readString(),
      etapa_global: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Etapa obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.circuito_nota_id);
    writer.writeString(obj.curso_descricao);
    writer.writeString(obj.descricao);
    writer.writeString(obj.periodo_inicial);
    writer.writeString(obj.periodo_final);
    writer.writeString(obj.situacao_faltas);
    writer.writeString(obj.etapa_global);
  }
}
