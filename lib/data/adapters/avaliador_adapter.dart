import 'package:hive_flutter/hive_flutter.dart';
import '../../models/avaliador_model.dart';

class AvaliadorAdapter extends TypeAdapter<AvaliadorModel> {
  @override
  final typeId = 49;

  @override
  AvaliadorModel read(BinaryReader reader) {
    return AvaliadorModel(
      id: reader.readString(),
      anoId: reader.readString(),
      configuracaoId: reader.readString(),
      name: reader.readString(),
      franquiasPermitidas: reader.readIntList(),
    );
  }

  @override
  void write(BinaryWriter writer, AvaliadorModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.anoId ?? '');
    writer.writeString(obj.configuracaoId ?? '');
    writer.writeString(obj.name ?? '');
    writer.writeIntList(obj.franquiasPermitidas ?? []);
  }
}
