import '../../models/ano_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AnoController {
  late Box<Ano> box;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(AnoAdapter().typeId)) {
      Hive.registerAdapter(AnoAdapter());
    }

    box = await Hive.openBox<Ano>('anos');
  }

  Future<List<Ano>> getAll() async {
    return box.values.toList();
  }

  Future<void> create(Ano model) async {
    await box.add(model);
  }

  Future<void> close() async {
    await box.close();
  }

  Future<void> clear() async {
    await box.clear();
  }

  Future<Ano> getAnoId({required int anoId}) async {
    try {
      Ano ano = box.values.firstWhere(
        (ano) => ano.id.toString() == anoId.toString(),
        orElse: () => throw Exception('Ano não encontrado'),
      );
      return ano;
    } catch (e) {
      print('Erro ao buscar o Ano: $e');
      rethrow;
    }
  }

  Future<Ano> getAnoDescricao({required String descricao}) async {
    try {
      Ano ano = box.values.firstWhere(
        (ano) => ano.descricao.toString() == descricao.toString(),
        orElse: () => throw Exception('Ano não encontrado'),
      );
      return ano;
    } catch (e) {
      print('Erro ao buscar o Ano: $e');
      rethrow;
    }
  }
}
