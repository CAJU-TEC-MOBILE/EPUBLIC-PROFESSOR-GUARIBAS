import 'package:hive_flutter/hive_flutter.dart';
import '../../models/gestao_disciplina_model.dart';

class GestaoDisciplinaController {
  late Box<GestaoDisciplina> _gestaoDisciplinaBox;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(GestaoDisciplinaAdapter().typeId)) {
      Hive.registerAdapter(GestaoDisciplinaAdapter());
    }

    _gestaoDisciplinaBox =
        await Hive.openBox<GestaoDisciplina>('getaos_disciplinas');
  }

  Future<void> addGetaoDisciplina(GestaoDisciplina getaoDisciplinas) async {
    try {
      await _gestaoDisciplinaBox.add(getaoDisciplinas);
    } catch (e) {
      print('error-add-getao-disciplina: $e');
    }
  }

  Future<List<GestaoDisciplina>> getAll() async {
    final data = _gestaoDisciplinaBox.values.cast<GestaoDisciplina>().toList();

    for (var item in data) {
      print(item);
    }
    return data;
  }

  Future<void> clear() async {
    await _gestaoDisciplinaBox.clear();
  }

  Future<List<GestaoDisciplina>> getGestaoDisciplinaPeloId(
      {required String? id}) async {
    final data = _gestaoDisciplinaBox.values
        .cast<GestaoDisciplina>()
        .where((item) => item.id == id)
        .toList();

    return data;
  }

  Future<List<dynamic>?> getFranquiaPeloId({required String? id}) async {
    final data = _gestaoDisciplinaBox.values
        .cast<GestaoDisciplina>()
        .where((item) => item.id == id)
        .toList();

    List<dynamic>? lista = data.isNotEmpty ? List<dynamic>.from(data) : null;

    return lista;
  }

  Future<List<dynamic>> getFranquias() async {
    try {
      final data =
          _gestaoDisciplinaBox.values.cast<GestaoDisciplina>().toList();

      Map<String, dynamic> disciplinaMap = {};

      for (var gestaoDisciplina in data) {
        for (var disciplina in gestaoDisciplina.disciplinas) {
          // Use o operador de coalescência nula para garantir que você tenha um valor padrão
          String disciplinaId = disciplina['id']?.toString() ??
              ''; // Certifique-se de que é uma string
          String descricao = disciplina['descricao']?.toString() ??
              ''; // Certifique-se de que é uma string

          // Verifique se 'quantidade' não é nulo antes de tentar convertê-lo
          dynamic quantidadeValue = disciplina['quantidade'];
          int quantidade = 0; // Inicialize com 0

          if (quantidadeValue != null) {
            // Tente converter para inteiro
            if (quantidadeValue is int) {
              quantidade = quantidadeValue; // Já é int
            } else if (quantidadeValue is double) {
              quantidade =
                  quantidadeValue.toInt(); // Converta de double para int
            } else {
              quantidade = int.parse(quantidadeValue
                  .toString()); // Converta de string ou outro tipo
            }
          }

          if (disciplinaMap.containsKey(disciplinaId)) {
            disciplinaMap[disciplinaId]['quantidade'] += quantidade;
          } else {
            disciplinaMap[disciplinaId] = {
              'id': disciplinaId,
              'descricao': descricao,
              'quantidade': quantidade,
            };
          }
        }
      }

      List<dynamic> lista = disciplinaMap.values.toList();

      return lista;
    } catch (e) {
      print('get-franquias: $e');
      return [];
    }
  }
}
