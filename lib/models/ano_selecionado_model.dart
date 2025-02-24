import 'package:hive_flutter/hive_flutter.dart';
import 'ano_model.dart';

class AnoSelecionado {
  int id;
  Ano ano;

  AnoSelecionado({required this.id, required this.ano});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ano': ano.toMap(),
    };
  }

  // Convertendo de Map para AnoSelecionado
  static AnoSelecionado fromMap(Map<String, dynamic> map) {
    return AnoSelecionado(
      id: map['id'],
      ano: Ano.fromMap(map['ano']),
    );
  }

  @override
  String toString() {
    return 'AnoSelecionado{id: $id, ano: ${ano.toString()}}';
  }
}

class AnoSelecionadoAdapter extends TypeAdapter<AnoSelecionado> {
  @override
  final typeId = 42;

  @override
  AnoSelecionado read(BinaryReader reader) {
    int id = reader.readInt();
    Map<String, dynamic> anoMap = Map<String, dynamic>.from(reader.readMap());

    Ano ano = Ano.fromMap(anoMap);

    return AnoSelecionado(
      id: id,
      ano: ano,
    );
  }

  @override
  void write(BinaryWriter writer, AnoSelecionado obj) {
    writer.writeInt(obj.id);
    writer.writeMap(obj.ano.toMap());
  }
}
