import 'package:hive_flutter/hive_flutter.dart';
import '../../models/tipo_aula_model.dart';

class TipoAulaController {
  late Box<TipoAula> box;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(TipoAulaAdapter().typeId)) {
      Hive.registerAdapter(TipoAulaAdapter());
    }

    box = await Hive.openBox<TipoAula>('tipos_aulas');
  }

  Future<bool> add(TipoAula model) async {
    try {
      await box.add(model);
      return true;
    } catch (e) {
      print('Erro ao adicionar tipo da aula: $e');
      return false;
    }
  }

  Future<List<TipoAula>> getAll() async {
    try {
      final tipos = await box.values.toList();
      return tipos;
    } catch (e) {
      print('error-tipo-de-aula: $e');
      return [];
    }
  }

  Future<List<String>> getDescricaoAll() async {
    try {
      final tipos = box.values.toList();

      List<String> descricoes = [];
      for (var tipo in tipos) {
        descricoes.add(tipo.descricao);
      }

      return descricoes;
    } catch (e) {
      print('error-tipo-de-aula: $e');
      return [];
    }
  }

  Future<TipoAula?> getPelaDescricao({required String descricao}) async {
    try {
      final tipo = box.values.firstWhere(
        (item) => item.descricao == descricao,
        orElse: () => TipoAula.vazio(),
      );
      return tipo;
    } catch (e) {
      print('error-tipo-de-aula: $e');
      return null;
    }
  }

  Future<int> clear() {
    return box.clear();
  }
}
