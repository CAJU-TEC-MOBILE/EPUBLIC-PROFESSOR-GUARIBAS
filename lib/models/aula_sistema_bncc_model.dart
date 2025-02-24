import 'package:hive/hive.dart';

class AulaSistemaBncc {
  final String aula_id;
  final String sistema_bncc_id;

  AulaSistemaBncc({
    required this.aula_id,
    required this.sistema_bncc_id,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'aula_id': aula_id,
      'sistema_bncc_id': sistema_bncc_id
    };
  }
}

class AulaSistemaBnccAdapter extends TypeAdapter<AulaSistemaBncc> {
  @override
  final typeId = 9;

  @override
  AulaSistemaBncc read(BinaryReader reader) {
    return AulaSistemaBncc(
      aula_id: reader.readString(),
      sistema_bncc_id: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, AulaSistemaBncc obj) {
    writer.writeString(obj.aula_id);
    writer.writeString(obj.sistema_bncc_id);
  }
}
