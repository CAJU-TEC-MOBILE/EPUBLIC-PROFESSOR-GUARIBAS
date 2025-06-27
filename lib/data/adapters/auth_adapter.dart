import 'package:hive_flutter/hive_flutter.dart';
import '../../models/auth_model.dart';

class AuthAdapter extends TypeAdapter<AuthModel> {
  @override
  final typeId = 5;

  @override
  AuthModel read(BinaryReader reader) {
    return AuthModel(
      id: reader.readString(),
      anoId: reader.readString(),
      configuracaoId: reader.readString(),
      email: reader.readString(),
      name: reader.readString(),
      tokenAtual: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, AuthModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.anoId);
    writer.writeString(obj.configuracaoId);
    writer.writeString(obj.email);
    writer.writeString(obj.name);
    writer.writeString(obj.tokenAtual);
  }
}
