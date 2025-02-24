import 'package:professor_acesso_notifiq/services/adapters/gestoes_service_adpater.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:collection/collection.dart';

List<dynamic> filtrarQuantidadeDeDisciplinasPorTurmaDaFraquiaSelecionada(
    {required bool todasAsFranquias}) {
  Box _gestaoAtivaBox = Hive.box('gestao_ativa');

  Map<dynamic, dynamic> _gestaoAtivaData = _gestaoAtivaBox.get('gestao_ativa');
  List<dynamic> gestoesDeTodasAsFranquias = GestoesService().listar();

  List<dynamic> gestoesPorFranquias = [];

  for (var i = 0; i < gestoesDeTodasAsFranquias.length; i++) {
    var gestoesList = gestoesDeTodasAsFranquias[i];
    for (var j = 0; j < gestoesList.length; j++) {
      var gestao = gestoesList[j];

      if (!todasAsFranquias) {
        if (_gestaoAtivaData['configuracao_id'].toString() ==
            gestao['configuracao_id'].toString()) {
          gestoesPorFranquias.add(gestao);
        }
      } else {
        gestoesPorFranquias.add(gestao);
      }
    }
  }

  final grupos = groupBy(
    gestoesPorFranquias,
    (obj) => obj['idt_disciplina_id'].toString(),
  );

  List<dynamic> arraysAgrupados = grupos.values.toList();

  return arraysAgrupados;
}
