import 'package:uuid/uuid.dart';

String gerarUuidIdentification() {
  // Obter o timestamp atual em milissegundos
  final timestamp = DateTime.now().millisecondsSinceEpoch;

  // Gerar um identificador único
  final uuid = Uuid().v4();

  // Concatenar o timestamp e o UUID para criar o código único
  final codigoUnico = '$timestamp-$uuid';

  return codigoUnico;
}
