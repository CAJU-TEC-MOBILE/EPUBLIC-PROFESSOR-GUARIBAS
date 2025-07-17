import 'package:hive_flutter/hive_flutter.dart';
import '../../models/autorizacao_model.dart';

class AutorizacaoAdapter extends TypeAdapter<AutorizacaoModel> {
  @override
  final typeId = 48;

  @override
  AutorizacaoModel read(BinaryReader reader) {
    return AutorizacaoModel(
      id: reader.readString(),
      pedidoId: reader.readString(),
      instrutorDisciplinaTurmaId: reader.readString(),
      etapaId: reader.readString(),
      userSolicitante: reader.readString(),
      userAprovador: reader.readString(),
      observacoes: reader.readString(),
      dataExpiracao: reader.readString(),
      status: reader.readString(),
      data: reader.readString(),
      mobile: reader.readString(),
      userId: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, AutorizacaoModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.pedidoId);
    writer.writeString(obj.instrutorDisciplinaTurmaId);
    writer.writeString(obj.instrutorDisciplinaTurmaId);
    writer.writeString(obj.userSolicitante);
    writer.writeString(obj.userAprovador);
    writer.writeString(obj.observacoes);
    writer.writeString(obj.dataExpiracao);
    writer.writeString(obj.status);
    writer.writeString(obj.data);
    writer.writeString(obj.mobile);
    writer.writeString(obj.userId);
  }
}
