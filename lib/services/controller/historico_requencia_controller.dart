import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';

import '../../models/historico_requencia_model.dart';

class HistoricoPresencaController {
  late Box<HistoricoPresenca> box;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(HistoricoPresencaAdapter().typeId)) {
      Hive.registerAdapter(HistoricoPresencaAdapter());
    }

    box = await Hive.openBox<HistoricoPresenca>('historico_presencas');
  }

  Future<List<HistoricoPresenca>> getAll() async {
    return box.values.toList();
  }

  Future<void> create(HistoricoPresenca model) async {
    await box.add(model);
    await getDebugPrint();
  }

  Future<void> close() async {
    await box.close();
  }

  Future<void> clear() async {
    await box.clear();
  }

  Future<List<HistoricoPresenca>> getDebugPrint() async {
    debugPrint(
        'Obtendo todos os registros de HistoricoPresenca. Total de itens: ${box.length}');

    for (var value in box.values) {
      print('Item na caixa: $value');
    }

    List<HistoricoPresenca> historicos = box.values.toList();

    print('Historicos carregados: $historicos');

    return historicos;
  }

  Future<bool> existeFileAulaPorAula(
    String? criadaPeloCelular,
    String? alunoId,
  ) async {
    return box.values.any(
      (item) =>
          item.criadaPeloCelular == criadaPeloCelular &&
          item.alunoId == alunoId,
    );
  }

  Future<void> deleteFileAulaPorAula(
    String? criadaPeloCelular,
    String? alunoId,
  ) async {
    var keysToDelete = box.keys.where((key) {
      var item = box.get(key);
      return item!.criadaPeloCelular == criadaPeloCelular &&
          item.alunoId == alunoId;
    }).toList();

    for (var key in keysToDelete) {
      await box.delete(key);
    }

    print("Total de registros deletados: ${keysToDelete.length}");
    await getDebugPrint();
  }

  Future<void> deletarAnexoPorAula(
      String? criadaPeloCelular, String? alunoId) async {
    try {
      // Filtrar os registros correspondentes
      List<HistoricoPresenca> data = box.values
          .where(
            (item) =>
                item.criadaPeloCelular == criadaPeloCelular &&
                item.alunoId == alunoId,
          )
          .toList();

      if (data.isNotEmpty) {
        for (var item in data) {
          int index = box.values.toList().indexOf(item);
          if (index != -1) {
            await box.deleteAt(index); // Deleta pelo índice
          }
        }
        debugPrint("Anexo(s) deletado(s) com sucesso.");
      } else {
        debugPrint("Nenhum anexo encontrado para deletar.");
      }
    } catch (e) {
      debugPrint("Erro ao deletar anexo: $e");
    }
  }

  Future<String?> getAnexoeAulaPorAula(
    String? criadaPeloCelular,
    String? alunoId,
  ) async {
    List<HistoricoPresenca> data = box.values
        .where(
          (item) =>
              item.criadaPeloCelular == criadaPeloCelular &&
              item.alunoId == alunoId,
        )
        .toList();

    return data.isNotEmpty ? data.first.anexo : null;
  }

  Future<List<HistoricoPresenca>> getHistoricoPresencaPeloCriadaPeloCelular(
    String? criadaPeloCelular,
  ) async {
    List<HistoricoPresenca> data = box.values
        .where((item) => item.criadaPeloCelular == criadaPeloCelular)
        .toList();

    return data.isNotEmpty ? data : [];
  }
}
