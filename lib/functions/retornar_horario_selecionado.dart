import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

Future<String> retornarHorarioSelecionado({required String horarioID}) async {
  Box horarios = Hive.box('horarios');
  List<dynamic>? horariosBox;
  //  print('horarioID:: $horarioID');
  horariosBox = await horarios.get('horarios');

  var horarioSelecionado = await horariosBox?.firstWhere(
    (horario) => horario['id'].toString() == horarioID,
    orElse: () => '',
  );
  if (horarioSelecionado != '' && horarioSelecionado != null) {
    return horarioSelecionado['descricao'];
  }
  return 'Sem horário.';
}
