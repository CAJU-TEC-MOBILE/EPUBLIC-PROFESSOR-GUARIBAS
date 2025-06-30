import 'package:hive_flutter/hive_flutter.dart';
import '../../models/config_horario_model.dart';

class ConfigHorarioAdapter extends TypeAdapter<ConfigHorarioModel> {
  @override
  final typeId = 47;

  @override
  ConfigHorarioModel read(BinaryReader reader) {
    return ConfigHorarioModel(
      id: reader.readString(),
      turnoId: reader.readString(),
      configuracaoId: reader.readString(),
      tipoHorario: reader.readString(),
      descricao: reader.readString(),
      inicio: reader.readString(),
      fim: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, ConfigHorarioModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.turnoId ?? '');
    writer.writeString(obj.configuracaoId ?? '');
    writer.writeString(obj.tipoHorario ?? '');
    writer.writeString(obj.descricao ?? '');
    writer.writeString(obj.inicio ?? '');
    writer.writeString(obj.fim ?? '');
  }
}
