import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/models/sistema_bncc_model.dart';

class SistemaBnccServiceAdapter {
  Future<void> salvar(List<dynamic> sistema_bncc) async {
    Box _sistema_bnccBox = Hive.box('sistema_bncc');

    _sistema_bnccBox.put('sistema_bncc', sistema_bncc);

    List<dynamic> sistema_bnccSalvos = _sistema_bnccBox.get('sistema_bncc');
    print('------------SALVANDO SISTEMA BNCC----------------');
    print('TOTAL DO SISTEMA BNCC: ${sistema_bnccSalvos.length}');
    listar();
  }

  List<SistemaBncc> listar() {
    Box _sistema_bnccBox = Hive.box('sistema_bncc');
    List<dynamic> sistema_bnccSalvos = _sistema_bnccBox.get('sistema_bncc');

    List<SistemaBncc> sistema_bnccListModel = sistema_bnccSalvos
        .map((sistema) => SistemaBncc.fromJson(sistema))
        .toList();
    return sistema_bnccListModel;
  }
}
