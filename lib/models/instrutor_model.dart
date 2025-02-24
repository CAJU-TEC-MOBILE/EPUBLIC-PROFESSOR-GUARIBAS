import 'package:hive_flutter/hive_flutter.dart';

class Instrutor {
  var id;
  var nome;
  var anoId;
  var token;

  Instrutor({this.id = '', required this.nome, this.anoId, this.token});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome, 'anoId': anoId, 'token': token};
  }

  factory Instrutor.fromJson(Map<String, dynamic> json) {
    return Instrutor(
        id: json['id'].toString(),
        nome: json['nome'].toString(),
        anoId: json['ano_id'].toString(),
        token: json['token'].toString());
  }

  @override
  String toString() {
    return 'Instrutor(id: $id, nome: $nome, anoId: $anoId, token: $token)';
  }
}

class InstrutorAdapter extends TypeAdapter<Instrutor> {
  @override
  final typeId = 10;

  @override
  Instrutor read(BinaryReader reader) {
    return Instrutor(
      id: reader.readString(),
      nome: reader.readString(),
      anoId: reader.readString(),
      token: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Instrutor obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.nome);
    writer.writeString(obj.anoId);
    writer.writeString(obj.token);
  }
}
