import 'package:hive_flutter/hive_flutter.dart';

class GestaoCotnroller {
  late Box box;

  Future<void> init() async {
    await Hive.initFlutter();

    box = await Hive.openBox('gestoes');
  }

  Future<dynamic> getFirstOrEmpty() async {
    List<dynamic> result = box.values.toList();
    return result.isEmpty ? [] : result[0];
  }

  Future<dynamic> getFirstOrEmptyAno({required String anoDescricao}) async {
    List<dynamic> result = box.values.toList();
    result = result
        .where((item) =>
            item['ano_descricao'].toString() == anoDescricao.toString())
        .toList();
    return result.isEmpty ? [] : result[0];
  }

  Future<String?> getPeloId({
    required String id,
    required String instrutorDisciplinaTurmaID,
  }) async {
    try {
      Box box = await Hive.openBox('gestoes');

      List<dynamic> result = box.values.toList().first;

      String? foundItem;

      for (var item in result) {
        for (var gestao in item) {
          if (gestao['idt_id'].toString() == instrutorDisciplinaTurmaID) {
            if (gestao['circuito'] != null) {
              for (var etapa in gestao['circuito']['etapas']) {
                if (etapa['id'].toString() == id.toString()) {
                  foundItem = etapa['descricao'].toString();
                }
              }
            }
          }
        }
      }

      return foundItem;
    } catch (e) {
      print('Erro ao buscar pelo ID: $e');
      return null;
    }
  }

  Future<bool> getStatusPeloId({
    required String id,
    required String instrutorDisciplinaTurmaID,
  }) async {
    try {
      Box box = await Hive.openBox('gestoes');

      List<dynamic> result = box.values.toList().first;

      String? foundItem;

      for (var item in result) {
        for (var gestao in item) {
          if (gestao['idt_id'].toString() == instrutorDisciplinaTurmaID) {
            if (gestao['circuito'] != null) {
              for (var etapa in gestao['circuito']['etapas']) {
                if (etapa['id'].toString() == id.toString()) {
                  foundItem = etapa['descricao'].toString();
                }
              }
            }
          }
        }
      }
      if (foundItem == null) return false;
      return true;
    } catch (e) {
      print('Erro ao buscar pelo ID: $e');
      return false;
    }
  }

  Future<void> clear() async {
    await box.clear();
  }
}