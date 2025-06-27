import 'package:professor_acesso_notifiq/models/relacao_dia_horario_model.dart';

List<RelacaoDiaHorario>? removeHorariosRepetidos(
    {required List<RelacaoDiaHorario> listaOriginal}) {
  if (listaOriginal.isEmpty || listaOriginal.isEmpty) return null;

  List<RelacaoDiaHorario>? listaFiltrada = [];

  for (var item in listaOriginal) {
    bool exists =
        listaFiltrada.any((element) => element.horario.id == item.horario.id);

    if (!exists) {
      listaFiltrada.add(item);
    }
  }

  return listaFiltrada;
}
