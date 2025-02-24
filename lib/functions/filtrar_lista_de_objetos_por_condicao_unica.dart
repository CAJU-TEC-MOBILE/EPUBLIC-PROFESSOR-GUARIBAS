List<dynamic> filtrarListaDeObjetoPorCondicaoUnica(
    {required List<dynamic> lista_de_objetos, required var condicao}) {
  List<dynamic> listaFiltrada = lista_de_objetos
      .where((horario) => horario['turno_id'].toString() == condicao.toString())
      .toList();
  // print('total filter');
  // print(listaFiltrada.length);
  return listaFiltrada;
}
