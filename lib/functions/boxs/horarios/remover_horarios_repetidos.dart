import 'package:professor_acesso_notifiq/models/relacao_dia_horario_model.dart';

List<RelacaoDiaHorario>? removeHorariosRepetidos(
    {required List<RelacaoDiaHorario> listaOriginal}) {
  if (listaOriginal.length == 0 || listaOriginal.isEmpty) return null;

  List<RelacaoDiaHorario>? listaFiltrada = [];

  listaOriginal.forEach((item) {
    // Verifica se o item já existe na lista filtrada
    bool exists =
        listaFiltrada.any((element) => element.horario.id == item.horario.id);

    // Se não existe, adiciona na lista filtrada
    if (!exists) {
      listaFiltrada.add(item);
    }
  });

  return listaFiltrada;
}
