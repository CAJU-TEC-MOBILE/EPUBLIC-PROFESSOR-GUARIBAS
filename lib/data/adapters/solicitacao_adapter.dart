import 'package:hive_flutter/hive_flutter.dart';
import '../../models/solicitacao_model.dart';

class SolicitacaoAdapter extends TypeAdapter<SolicitacaoModel> {
  @override
  final typeId = 51;
  @override
  SolicitacaoModel read(BinaryReader reader) {
    return SolicitacaoModel(
      id: reader.readString(),
      descricao: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, SolicitacaoModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.descricao ?? '');
  }
}
