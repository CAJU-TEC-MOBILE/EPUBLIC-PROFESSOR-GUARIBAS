import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/models/aula_sistema_bncc_model.dart';
import 'package:professor_acesso_notifiq/models/sistema_bncc_model.dart';

class AulaSistemaBnccServiceAdapter {
  Future<List<AulaSistemaBncc>> listarDeAulaEspecifica(
      {required String aulaOfflineId}) async {
    Box<AulaSistemaBncc> aulaSistemaBnccBox =
        Hive.box('aula_sistema_bncc_offline');

    print('AULA BNCC BOX GERAL TOT: ' + aulaSistemaBnccBox.values.toString());

    aulaSistemaBnccBox.values.forEach((element) {
      print('${element.aula_id}-----${element.sistema_bncc_id}');
    });

    List<AulaSistemaBncc> aulaSistemaBnccSalvos = aulaSistemaBnccBox.values
        .where((aula) => aula.aula_id.toString() == aulaOfflineId.toString())
        .toList();
    print('aulaSistemaBnccSalvos: $aulaSistemaBnccSalvos');
    return aulaSistemaBnccSalvos;
  }

  Future<void> salvarVarios(
      {required List<SistemaBncc> sistemaBncc,
      required String aulaOfflineId}) async {
    Box<AulaSistemaBncc> aulaSistemaBnccBox =
        Hive.box('aula_sistema_bncc_offline');

    if (sistemaBncc.isNotEmpty) {
      // ignore: avoid_function_literals_in_foreach_calls
      sistemaBncc.forEach((sistema) {
        aulaSistemaBnccBox.add(AulaSistemaBncc(
            aula_id: aulaOfflineId.toString(),
            sistema_bncc_id: sistema.id.toString()));
      });
    }

    // ignore: unused_local_variable
    List<AulaSistemaBncc> aulaSistemaBnccSalvos =
        aulaSistemaBnccBox.values.toList();
  }

  Future<void> deletarDeAulaEspecifica({required String aulaOfflineID}) async {
    // ignore: no_leading_underscores_for_local_identifiers
    Box<AulaSistemaBncc> _aulaSistemaBnccBox =
        Hive.box('aula_sistema_bncc_offline');

    List<AulaSistemaBncc> aulaSistemaBnccSalvos =
        _aulaSistemaBnccBox.values.toList();

    List<int> indexesToDelete = [];
    aulaSistemaBnccSalvos.asMap().forEach((index, sistema) {
      if (sistema.aula_id.toString() == aulaOfflineID.toString()) {
        indexesToDelete.add(index);
      }
    });

    for (int index in indexesToDelete.reversed) {
      _aulaSistemaBnccBox.deleteAt(index);
    }
  }
}
