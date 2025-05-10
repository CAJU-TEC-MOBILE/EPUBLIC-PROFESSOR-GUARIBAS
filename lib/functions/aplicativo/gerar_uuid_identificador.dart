import 'package:uuid/uuid.dart';

String gerarUuidIdentification() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;

  final uuid = const Uuid().v4();

  final codigoUnico = '$timestamp-$uuid';

  return codigoUnico;
}
